#define _DEFAULT_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <poll.h>
#include <time.h>
#include <errno.h>

static const char *dir;
static FILE *outlog, *inlog, *results, *events;
static int serial;
static void utc(FILE *f) { struct timespec t; struct tm tm; clock_gettime(CLOCK_REALTIME,&t); gmtime_r(&t.tv_sec,&tm); char b[64]; strftime(b,sizeof b,"%FT%T",&tm); fprintf(f,"%s.%09ldZ",b,t.tv_nsec); }
static FILE *file(const char *name,const char *mode) { char p[2048];snprintf(p,sizeof p,"%s/%s",dir,name); FILE *f=fopen(p,mode);if(!f){perror(p);exit(2);}return f; }
static void emit(const void *s,size_t n) { fwrite(s,1,n,outlog);fflush(outlog); const char *p=s;while(n){ssize_t k=write(1,p,n);if(k<0){if(errno==EINTR)continue;exit(3);}p+=k;n-=k;} }
static void text(const char *s){emit(s,strlen(s));}
/* This process accepts no ordinary keyboard input. Every read is retained and
 * a complete CSI digits ; digits R is required, with no fallback substring. */
static void dsr(const char *name) {
 text("\033[6n"); char b[1024];size_t n=0;int row=0,col=0,matched=0;long deadline;
 struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);deadline=t.tv_sec*1000+t.tv_nsec/1000000+3000;
 while(n<sizeof(b)-1){ clock_gettime(CLOCK_MONOTONIC,&t);long left=deadline-(t.tv_sec*1000+t.tv_nsec/1000000);if(left<=0)break;struct pollfd p={.fd=0,.events=POLLIN};if(poll(&p,1,(int)left)<=0)break;ssize_t k=read(0,b+n,sizeof(b)-1-n);if(k<=0)break;fwrite(b+n,1,k,inlog);fflush(inlog);n+=k;b[n]=0;int used=0;if(sscanf(b,"\033[%d;%dR%n",&row,&col,&used)==2 && used==(int)n){matched=1;break;} }
 fprintf(results,"{\"n\":%d,\"name\":\"%s\",\"utc\":\"",++serial,name);utc(results);fprintf(results,"\",\"matched_full_csi\":%s,\"row\":%d,\"col\":%d,\"output_end_offset\":%ld,\"input_end_offset\":%ld,\"raw_hex\":\"",matched?"true":"false",row,col,ftell(outlog),ftell(inlog));for(size_t j=0;j<n;j++)fprintf(results,"%02x",(unsigned char)b[j]);fprintf(results,"\"}\n");fflush(results);if(!matched)exit(4);
}
static void stage(const char *name) {
 FILE *f=file("stage","w");fprintf(f,"%s\n",name);fclose(f);
 for(int i=0;i<600;i++){FILE *a=file("ack","a+");rewind(a);char b[128]={0};fgets(b,sizeof b,a);fclose(a);b[strcspn(b,"\n")]=0;if(!strcmp(b,name))return;usleep(50000);}exit(5);
}
static void replay(const char *path){FILE *f=fopen(path,"rb");if(!f){perror(path);exit(6);}char b[8192];size_t n;while((n=fread(b,1,sizeof b,f)))emit(b,n);fclose(f);}
static void term(const char *name){struct termios t;tcgetattr(0,&t);struct winsize w;ioctl(0,TIOCGWINSZ,&w);fprintf(events,"%s termios=%lx:%lx:%lx:%lx",name,(unsigned long)t.c_iflag,(unsigned long)t.c_oflag,(unsigned long)t.c_cflag,(unsigned long)t.c_lflag);for(size_t i=0;i<NCCS;i++)fprintf(events,":%x",t.c_cc[i]);fprintf(events," ispeed=%u ospeed=%u rows=%d cols=%d tty=%s utc=",(unsigned)cfgetispeed(&t),(unsigned)cfgetospeed(&t),w.ws_row,w.ws_col,ttyname(0));utc(events);fputc('\n',events);fflush(events);}
int main(int argc,char **argv){if(argc!=3)return 1;dir=argv[1];outlog=file("output.bin","wb");inlog=file("input.bin","wb");results=file("dsr.jsonl","w");events=file("events.txt","w");term("ready");fprintf(events,"TERM=%s COLORTERM=%s LANG=%s LC_ALL=%s\n",getenv("TERM"),getenv("COLORTERM")?getenv("COLORTERM"):"",getenv("LANG"),getenv("LC_ALL")?getenv("LC_ALL"):"");
 struct termios saved,raw;tcgetattr(0,&saved);raw=saved;cfmakeraw(&raw);tcsetattr(0,TCSANOW,&raw);term("raw");
 const char *labels[]={"ascii","cjk","combining","woman","laptop","zwj","flag","heart_text","heart_vs16","sun_text","sun_vs16","keycap","zwj_suffix","flag_suffix","vs16_suffix","combined_suffix"};
 const char *values[]={"A","界","é","👩","💻","👩‍💻","🇨🇳","❤","❤️","☀","☀️","1️⃣","👩‍💻Z","🇨🇳Z","❤️Z","é and 界 👩‍💻Z"};
 text("\033[2J");
 for(size_t i=0;i<sizeof(labels)/sizeof(*labels);i++){char cup[32];snprintf(cup,sizeof cup,"\033[%zu;1H",i+1);text(cup);dsr("before");text(values[i]);dsr(labels[i]);}
 for(int c=96;c<=100;c++){char cup[32],name[64];snprintf(cup,sizeof cup,"\033[18;%dH",c);text(cup);text("👩‍💻Z");snprintf(name,sizeof name,"zwj_suffix_start_%d",c);dsr(name);}
 stage("width-matrix");
 const char *variants[]={"original","replace_zwj_cjk","remove_zwj_only","padding_minus2"};
 for(size_t v=0;v<4;v++){for(int repeat=0;repeat<(v==0?2:1);repeat++){
 text("\033[2J\033[H");char path[2048],name[128];snprintf(path,sizeof path,"%s/initial.bin",argv[2]);replay(path);snprintf(name,sizeof name,"%s-%d-initial",variants[v],repeat);dsr(name);stage(name);
 for(int delta=0;delta<2;delta++){snprintf(path,sizeof path,"%s/%s-%s.bin",argv[2],variants[v],delta?"red":"green");replay(path);snprintf(name,sizeof name,"%s-%d-%s",variants[v],repeat,delta?"red":"green");dsr(name);stage(name);}
 }}
 text("\033[2J\033[3;1H");dsr("delta-before");text("é");dsr("delta-after-combining");text(" and ");dsr("delta-after-and");text("界 ");dsr("delta-before-zwj");text("👩‍💻");dsr("delta-after-zwj");for(int i=0;i<89;i++)text(" ");dsr("delta-after-padding89");stage("delta-boundaries");
 tcsetattr(0,TCSANOW,&saved);term("restored");FILE *f=file("exit.txt","w");fprintf(f,"0\n");fclose(f);return 0;
}
