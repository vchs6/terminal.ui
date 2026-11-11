#define _GNU_SOURCE
#include <dlfcn.h>
#include <poll.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>
/* A's existing -3 read-error path, not future Keyboard -4 EOF semantics.
 * Real PTY, real native reader; only inject the underlying poll HUP after arm. */
int poll(struct pollfd *fds,nfds_t n,int timeout) {
    static int (*next_poll)(struct pollfd *,nfds_t,int);
    if(!next_poll){void *symbol=dlsym(RTLD_NEXT,"poll");*(void **)(&next_poll)=symbol;}
    const char *arm=getenv("CJTUI_A_HUP_ARM_FILE");
    if(arm && !access(arm,F_OK)) {
        for(nfds_t i=0;i<n;++i) if(fds[i].fd==STDIN_FILENO && isatty(fds[i].fd)) {
            for(nfds_t j=0;j<n;++j) fds[j].revents=0;
            fds[i].revents=POLLHUP;
            const char *path=getenv("CJTUI_A_HUP_TRACE");
            if(path){FILE *out=fopen(path,"a");if(out){fputs("POLLHUP fd=0\n",out);fclose(out);}}
            return 1;
        }
    }
    const char *trace=getenv("CJTUI_A_POLL_TRACE");
    if(!trace)return next_poll(fds,n,timeout);
    struct timespec begin,end;
    clock_gettime(CLOCK_MONOTONIC,&begin);
    const char *enter=getenv("CJTUI_A_POLL_ENTER");
    if(enter) for(nfds_t i=0;i<n;++i) if(fds[i].fd==STDIN_FILENO) {
        FILE *out=fopen(enter,"a");
        if(out){fprintf(out,"%lld %d\n",(long long)begin.tv_sec*1000000000LL+begin.tv_nsec,timeout);fclose(out);}
    }
    int result=next_poll(fds,n,timeout);
    int saved_errno=errno;
    clock_gettime(CLOCK_MONOTONIC,&end);
    if(trace) for(nfds_t i=0;i<n;++i) if(fds[i].fd==STDIN_FILENO) {
        FILE *out=fopen(trace,"a");
        if(out){fprintf(out,"%lld %lld %d %d %u\n",
            (long long)begin.tv_sec*1000000000LL+begin.tv_nsec,
            (long long)end.tv_sec*1000000000LL+end.tv_nsec,timeout,result,(unsigned)fds[i].revents);fclose(out);}
    }
    errno=saved_errno;
    return result;
}
