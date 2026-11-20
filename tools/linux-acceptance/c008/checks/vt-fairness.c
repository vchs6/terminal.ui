#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <poll.h>
#include <signal.h>
#include <stdint.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <time.h>
static int logfd,tr_fifo,tr_fifo_keep,tr_archive,feedfd;
static pid_t serial_reader=-1,archive_reader=-1,owned_child=-1;
static unsigned char *source;static size_t source_size,generated;
static const char *mode;static unsigned io_calls,read_calls,archive_calls,serial_calls;
static int interrupt_forever;
static int observed_eof;
#ifdef NATIVE_FATAL
static char fatal_path[4096];
static int fatal_open(const char *path,int flags,mode_t permissions){return open(strcmp(path,"/evidence/trace-transport-error.txt")==0?fatal_path:path,flags,permissions);}
#define open fatal_open
#include "native-fatal.h"
#undef open
#else
static void tr_die(const char *what){
 int error=errno;fprintf(stderr,"TRANSPORT_ERROR operation=%s errno=%d\n",what,error);
 for(unsigned i=0;i<3;i++){pid_t p=i==0?serial_reader:i==1?archive_reader:owned_child;if(p>0){kill(p,SIGKILL);while(waitpid(p,NULL,0)<0&&errno==EINTR){}}}
 exit(3);
}
#endif
static void exact_write(int fd,const void *bytes,size_t n){
 const char *p=bytes;while(n){ssize_t count=write(fd,p,n);if(count<0&&errno==EINTR)continue;if(count<=0)tr_die("harness-write");p+=count;n-=(size_t)count;}
}
static ssize_t checked_read(int fd,void *bytes,size_t n){
 if(fd!=tr_fifo)return read(fd,bytes,n);
 io_calls++;read_calls++;
 if(interrupt_forever||(strcmp(mode,"partial")==0&&read_calls%5==1&&read_calls<100)){errno=EINTR;return -1;}
 if(strcmp(mode,"read-error")==0&&read_calls>3){errno=EIO;return -1;}
 int available=0;if(ioctl(fd,FIONREAD,&available))tr_die("harness-fifo-count");
 if(!available&&generated<source_size){
  size_t count=source_size-generated;if(count>2048)count=2048;
  ssize_t sent=write(feedfd,source+generated,count);if(sent<=0)tr_die("harness-feed");generated+=(size_t)sent;
  if(generated==source_size){close(feedfd);feedfd=-1;}
 }
 if(strcmp(mode,"partial")==0&&n>23)n=23;
 ssize_t got=read(fd,bytes,n);if(got==0)observed_eof=1;return got;
}
static ssize_t checked_write(int fd,const void *bytes,size_t n){
 io_calls++;
 unsigned *calls=fd==tr_archive?&archive_calls:&serial_calls;(*calls)++;
 if(strcmp(mode,"partial")==0){if(*calls%7==1&&*calls<100){errno=EINTR;return -1;}if(n>31)n=31;}
 if(strcmp(mode,"archive-error")==0&&fd==tr_archive&&*calls>2){errno=EIO;return -1;}
 if(strcmp(mode,"serial-error")==0&&fd==logfd&&*calls>2){errno=EIO;return -1;}
 if(strcmp(mode,"zero-write")==0&&fd==tr_archive)return 0;
 return write(fd,bytes,n);
}
#define read checked_read
#define write checked_write
#ifdef OLD_BASE
static void tr_write(int fd,const void *buffer,size_t length){const char *p=buffer;while(length){ssize_t n=write(fd,p,length);if(n<0&&errno==EINTR)continue;if(n<=0)tr_die("write");p+=n;length-=(size_t)n;}}
#include "old-drain.h"
static void tr_trace_start(void){}
static void tr_trace_child_close(void){close(tr_fifo);close(tr_fifo_keep);close(tr_archive);close(logfd);}
static void tr_trace_finish(void){close(tr_fifo_keep);tr_fifo_keep=-1;tr_drain();}
#define tr_log_printf dprintf
#else
#include "vt-trace-pump.h"
#endif
#undef read
#undef write
static void collect(int fd,const char *path){
 int output=open(path,O_WRONLY|O_CREAT|O_EXCL,0600);if(output<0)tr_die("harness-collect-open");
 usleep(200000);unsigned char bytes[512];ssize_t n;
 while((n=read(fd,bytes,sizeof bytes))>0){exact_write(output,bytes,(size_t)n);usleep(100);}
 if(n<0)tr_die("harness-collect-read");
 close(output);close(fd);_exit(0);
}
static long long now_ms(void){struct timespec now;clock_gettime(CLOCK_MONOTONIC,&now);return (long long)now.tv_sec*1000+now.tv_nsec/1000000;}
int main(int argc,char **argv){
 if(argc!=4)return 2;
 mode=argv[1];signal(SIGPIPE,SIG_IGN);
#ifdef NATIVE_FATAL
 snprintf(fatal_path,sizeof fatal_path,"%s/fatal.raw",argv[3]);
#endif
 int input=open(argv[2],O_RDONLY);if(input<0)tr_die("harness-input");struct stat st;if(fstat(input,&st))tr_die("harness-input-stat");source_size=(size_t)st.st_size;source=malloc(source_size);if(!source)tr_die("harness-source-allocate");
 size_t at=0;while(at<source_size){ssize_t n=read(input,source+at,source_size-at);if(n<=0)tr_die("harness-source-read");at+=(size_t)n;}close(input);
 char path[4096],serial_path[4096],archive_path[4096];snprintf(path,sizeof path,"%s/trace.fifo",argv[3]);snprintf(serial_path,sizeof serial_path,"%s/serial.raw",argv[3]);snprintf(archive_path,sizeof archive_path,"%s/archive.raw",argv[3]);
 if(mkfifo(path,0600))tr_die("harness-mkfifo");
 tr_fifo=open(path,O_RDONLY|O_NONBLOCK);tr_fifo_keep=open(path,O_WRONLY|O_NONBLOCK);feedfd=open(path,O_WRONLY|O_NONBLOCK);if(tr_fifo<0||tr_fifo_keep<0||feedfd<0)tr_die("harness-fifo-open");
 int serial[2];if(pipe(serial)||fcntl(serial[1],F_SETPIPE_SZ,4096)<0)tr_die("harness-serial-pipe");logfd=serial[1];
 serial_reader=fork();if(serial_reader<0)tr_die("harness-serial-fork");if(!serial_reader){close(serial[1]);close(tr_fifo);close(tr_fifo_keep);close(feedfd);collect(serial[0],serial_path);}close(serial[0]);
 if(strcmp(mode,"archive-backpressure")==0){int archive[2];if(pipe(archive)||fcntl(archive[1],F_SETPIPE_SZ,4096)<0)tr_die("harness-archive-pipe");tr_archive=archive[1];if(fcntl(tr_archive,F_SETFL,O_NONBLOCK)<0)tr_die("harness-archive-flags");archive_reader=fork();if(archive_reader<0)tr_die("harness-archive-fork");if(!archive_reader){close(archive[1]);close(logfd);close(tr_fifo);close(tr_fifo_keep);close(feedfd);collect(archive[0],archive_path);}close(archive[0]);}
 else {tr_archive=open(archive_path,O_WRONLY|O_CREAT|O_EXCL|O_NONBLOCK,0600);if(tr_archive<0)tr_die("harness-archive-open");}
 owned_child=fork();if(owned_child<0)tr_die("harness-owned-fork");if(!owned_child){tr_trace_child_close();close(feedfd);usleep(50000);_exit(17);}
 int control[2];if(pipe(control))tr_die("harness-control");exact_write(control[1],"c",1);close(control[1]);
 tr_trace_start();interrupt_forever=strcmp(mode,"eintr-budget")==0;
 int control_before_eof=0,reap_before_eof=0,serviced=0,reaped=0,child_status=0;unsigned maximum=0;long long begin=now_ms(),control_ms=-1,reap_ms=-1;
 while(!serviced||!reaped){
  unsigned before=io_calls;tr_drain();unsigned used=io_calls-before;if(used>maximum)maximum=used;
  struct pollfd p={serviced?-1:control[0],POLLIN,0};if(poll(&p,1,50)<0)tr_die("harness-control-poll");
  if(!serviced&&(p.revents&POLLIN)){char ch;if(read(control[0],&ch,1)!=1||ch!='c')tr_die("harness-control-read");serviced=1;control_before_eof=generated<source_size;control_ms=now_ms()-begin;tr_log_printf(logfd,"CONTROL_SERVICED\n");}
  if(!reaped){pid_t got=waitpid(owned_child,&child_status,WNOHANG);if(got<0)tr_die("harness-reap");if(got==owned_child){owned_child=-1;reaped=1;reap_before_eof=generated<source_size;reap_ms=now_ms()-begin;tr_log_printf(logfd,"REAP_SERVICED\n");}}
  if(now_ms()-begin>10000){errno=ETIMEDOUT;tr_die("harness-safety-deadline");}
 }
 interrupt_forever=0;close(control[0]);
 size_t before_finish=generated;unsigned calls_before_finish=io_calls;
 tr_trace_finish();unsigned finish_calls=io_calls-calls_before_finish;
 if(close(tr_fifo)||close(tr_archive)||close(logfd))tr_die("harness-close");
 int status;if(waitpid(serial_reader,&status,0)!=serial_reader||status!=0)tr_die("harness-serial-reap");serial_reader=-1;
 if(archive_reader>0){if(waitpid(archive_reader,&status,0)!=archive_reader||status!=0)tr_die("harness-archive-reap");archive_reader=-1;}
 if(!WIFEXITED(child_status)||WEXITSTATUS(child_status)!=17)tr_die("harness-child-status");
 printf("{\"controlBeforeTraceEOF\":%s,\"reapBeforeTraceEOF\":%s,\"controlMs\":%lld,\"reapMs\":%lld,\"maxActiveIOAttempts\":%u,\"generatedBeforeFinish\":%zu,\"finalIOAttempts\":%u,\"observedFinalEOF\":%s,\"generatedBytes\":%zu,\"trueChildExit\":17}\n",control_before_eof?"true":"false",reap_before_eof?"true":"false",control_ms,reap_ms,maximum,before_finish,finish_calls,observed_eof?"true":"false",generated);
 free(source);return control_before_eof&&reap_before_eof?0:1;
}
