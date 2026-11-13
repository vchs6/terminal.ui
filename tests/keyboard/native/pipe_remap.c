#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdatomic.h>
#include <unistd.h>
#include <fcntl.h>
static _Atomic unsigned long long total;
static int mapped(void){const char *p=getenv("CJTUI_KEYBOARD_PIPE_FD");return p?atoi(p):-1;}
static void note(const char *kind,int fd,long result,int revents,const unsigned char *data){
 const char *path=getenv("CJTUI_KEYBOARD_PIPE_TRACE");if(!path)return;int saved=errno;
 int f=open(path,O_WRONLY|O_CREAT|O_APPEND,0600);if(f>=0){char b[512];int n=snprintf(b,sizeof b,"%s real_fd=%d actual_result=%ld revents=%x total=%llu data=",kind,fd,result,revents,atomic_load(&total));
 if(data && result>0){long limit=result<64?result:64;for(long i=0;i<limit;i++)n+=snprintf(b+n,sizeof b-(size_t)n,"%02x",data[i]);}b[n++]='\n';write(f,b,(size_t)n);close(f);}errno=saved;
}
ssize_t read(int fd,void *buf,size_t n){
 ssize_t(*real_read)(int,void*,size_t)=dlsym(RTLD_NEXT,"read");int target=fd==STDIN_FILENO&&mapped()>=0?mapped():fd;
 ssize_t result=real_read(target,buf,n);if(target!=fd){if(result>0)atomic_fetch_add(&total,(unsigned long long)result);note("read",target,result,0,buf);}return result;
}
int poll(struct pollfd *fds,nfds_t n,int timeout){
 int(*real_poll)(struct pollfd*,nfds_t,int)=dlsym(RTLD_NEXT,"poll");
 if(n==1 && fds[0].fd==STDIN_FILENO && mapped()>=0){struct pollfd target=fds[0];target.fd=mapped();int result=real_poll(&target,1,timeout);fds[0].revents=target.revents;note("poll",target.fd,result,target.revents,0);return result;}
 return real_poll(fds,n,timeout);
}
