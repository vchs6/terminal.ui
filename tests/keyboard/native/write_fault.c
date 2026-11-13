#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
static int selected,partial_pending;
static int contains(const void *p,size_t n,const char *s){size_t k=strlen(s);for(size_t i=0;i+k<=n;i++)if(!memcmp((const char*)p+i,s,k))return 1;return 0;}
ssize_t write(int fd,const void *data,size_t n){
 ssize_t(*real_write)(int,const void*,size_t)=dlsym(RTLD_NEXT,"write");const char *target=getenv("CJTUI_KEYBOARD_WRITE_BOUNDARY");const char *mode=getenv("CJTUI_KEYBOARD_WRITE_MODE");const char *path=getenv("CJTUI_KEYBOARD_WRITE_TRACE");
 if(fd!=1 || !target || !mode || !path)return real_write(fd,data,n);
 int hit=!selected && contains(data,n,!strcmp(target,"init")?"\033[?2004h":"\033[?2004l");ssize_t result;const char *action="pass";
 if(partial_pending){partial_pending=0;errno=EIO;result=-1;action="partial-fatal";}
 else if(hit){selected=1;if(!strcmp(mode,"partial")){result=real_write(fd,data,1);partial_pending=result==1;action="partial";}else{errno=EIO;result=-1;action="zero";}}
 else result=real_write(fd,data,n);
 int saved=errno;int trace=open(path,O_CREAT|O_WRONLY|O_APPEND,0600);if(trace>=0){char b[512];int at=snprintf(b,sizeof b,"%s length=%zu result=%zd hex=",action,n,result);size_t limit=n<96?n:96;for(size_t i=0;i<limit;i++)at+=snprintf(b+at,sizeof b-(size_t)at,"%02x",((const unsigned char*)data)[i]);b[at++]='\n';real_write(trace,b,(size_t)at);close(trace);}errno=saved;return result;
}
