#define _GNU_SOURCE
#include <dlfcn.h>
#include <poll.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
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
    return next_poll(fds,n,timeout);
}
