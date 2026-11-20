/* Bounded active work, not a hard wall-clock/disk latency guarantee. A regular
 * archive write can still stall in the OS. Serial backlog cannot block this
 * pump, and active native log text shares one queue to preserve whole frames. */
#include <stdarg.h>
enum {TR_TRACE_CHUNK=2048,TR_ACTIVE_STEPS=8};
static unsigned char tr_bytes[TR_TRACE_CHUNK];
static size_t tr_bytes_used,tr_archived;
static char *tr_output;static size_t tr_output_at,tr_output_used,tr_output_capacity;
static int tr_trace_active,tr_trace_eof,tr_log_flags;
static void tr_output_add(const char *bytes,size_t length){
 if(!length)return;
 if(length>SIZE_MAX-tr_output_used){errno=EOVERFLOW;tr_die("trace-log-size");}
 size_t needed=tr_output_used+length;
 if(needed>tr_output_capacity){
  if(tr_output_at){memmove(tr_output,tr_output+tr_output_at,tr_output_used-tr_output_at);tr_output_used-=tr_output_at;tr_output_at=0;needed=tr_output_used+length;}
  if(needed>tr_output_capacity){size_t capacity=tr_output_capacity<=SIZE_MAX/2?tr_output_capacity*2:needed;if(capacity<needed)capacity=needed;char *next=realloc(tr_output,capacity);if(!next)tr_die("trace-log-allocate");tr_output=next;tr_output_capacity=capacity;}
 }
 memcpy(tr_output+tr_output_used,bytes,length);tr_output_used+=length;
}
static int tr_log_printf(int fd,const char *format,...) __attribute__((format(printf,2,3)));
static int tr_log_printf(int fd,const char *format,...){
 va_list args;va_start(args,format);
 if(!tr_trace_active||fd!=logfd){int result=vdprintf(fd,format,args);va_end(args);return result;}
 va_list copy;va_copy(copy,args);int length=vsnprintf(NULL,0,format,copy);va_end(copy);
 if(length<0){va_end(args);errno=EIO;tr_die("trace-log-format");}
 char *bytes=malloc((size_t)length+1);if(!bytes){va_end(args);tr_die("trace-log-allocate");}
 int result=vsnprintf(bytes,(size_t)length+1,format,args);va_end(args);
 if(result!=length){free(bytes);errno=EIO;tr_die("trace-log-format");}
 tr_output_add(bytes,(size_t)length);free(bytes);return length;
}
static void tr_trace_child_close(void){close(tr_fifo);close(tr_fifo_keep);close(tr_archive);close(logfd);}
static void tr_trace_start(void){
 tr_log_flags=fcntl(logfd,F_GETFL);if(tr_log_flags<0)tr_die("trace-log-flags");
 /* Independent output open description keeps the already-forked tracer's
  * startup log descriptor/flags intact. No UART/control configuration. */
 char path[64];snprintf(path,sizeof path,"/proc/self/fd/%d",logfd);
 int serial=open(path,O_WRONLY|O_NOCTTY|O_NONBLOCK);if(serial<0)tr_die("trace-log-nonblock-open");
 close(logfd);logfd=serial;tr_trace_active=1;
}
static int tr_drain(void){
 int progressed=0;
 for(unsigned step=0;step<TR_ACTIVE_STEPS;step++){
  ssize_t n;
  if(tr_output_at<tr_output_used){
   size_t remaining=tr_output_used-tr_output_at;if(remaining>4096)remaining=4096;
   n=write(logfd,tr_output+tr_output_at,remaining);
   if(n>0){tr_output_at+=(size_t)n;progressed=1;if(tr_output_at==tr_output_used)tr_output_at=tr_output_used=0;continue;}
   if(n<0&&errno==EINTR)continue;
   if(n<0&&(errno==EAGAIN||errno==EWOULDBLOCK))break;
   if(n==0)errno=EIO;
   tr_die("trace-log-write");
  }
  if(tr_bytes_used){
   n=write(tr_archive,tr_bytes+tr_archived,tr_bytes_used-tr_archived);
   if(n>0){tr_archived+=(size_t)n;progressed=1;
    if(tr_archived==tr_bytes_used){
     static const char hex[]="0123456789abcdef";char frame[2*TR_TRACE_CHUNK+11];memcpy(frame,"TRACE hex=",10);
     for(size_t j=0;j<tr_bytes_used;j++){frame[10+j*2]=hex[tr_bytes[j]>>4];frame[11+j*2]=hex[tr_bytes[j]&15];}
     frame[10+tr_bytes_used*2]='\n';tr_output_add(frame,11+tr_bytes_used*2);tr_bytes_used=tr_archived=0;
    }continue;
   }
   if(n<0&&errno==EINTR)continue;
   if(n<0&&(errno==EAGAIN||errno==EWOULDBLOCK))break;
   if(n==0)errno=EIO;
   tr_die("trace-archive-write");
  }
  if(tr_trace_eof)break;
  n=read(tr_fifo,tr_bytes,sizeof tr_bytes);
  if(n>0){tr_bytes_used=(size_t)n;tr_archived=0;progressed=1;continue;}
  if(n==0){tr_trace_eof=1;progressed=1;break;}
  if(errno==EINTR)continue;
  if(errno==EAGAIN||errno==EWOULDBLOCK)break;
  tr_die("trace-read");
 }
 return progressed;
}
static void tr_trace_finish(void){
 /* Reaped tracer: drop our keeper, then drain to real EOF, not one quota. */
 if(close(tr_fifo_keep))tr_die("trace-keeper-close");
 tr_fifo_keep=-1;
 while(!tr_trace_eof||tr_bytes_used||tr_output_at<tr_output_used){
  if(tr_drain())continue;
  struct pollfd pending={tr_output_at<tr_output_used?logfd:tr_bytes_used?tr_archive:tr_fifo,tr_output_at<tr_output_used||tr_bytes_used?POLLOUT:POLLIN,0};
  if(poll(&pending,1,-1)<0&&errno!=EINTR)tr_die("trace-final-poll");
 }
 if(fcntl(logfd,F_SETFL,tr_log_flags)<0)tr_die("trace-log-restore-flags");
 tr_trace_active=0;free(tr_output);tr_output=NULL;tr_output_capacity=0;
}
