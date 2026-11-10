#define _GNU_SOURCE
#include <dlfcn.h>
#include <unistd.h>
#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
// Fault only stdout writes to a real TTY, selected by 1-based call index.
// Tracing is on a separate file descriptor and never traverses the shim.
static uint64_t calls;
static ssize_t (*real_write)(int,const void *,size_t);
ssize_t write(int fd, const void *buffer, size_t length) {
    if (real_write == NULL) {
        void *symbol = dlsym(RTLD_NEXT,"write");
        *(void **)(&real_write) = symbol;
        if (real_write == NULL) { errno=EIO; return -1; }
    }
    if (fd != STDOUT_FILENO || !isatty(fd)) return real_write(fd,buffer,length);
    ++calls;
    const char *trace = getenv("CJTUI_A_WRITE_TRACE");
    if (trace != NULL) {
        int out = open(trace,O_WRONLY|O_CREAT|O_APPEND,0600);
        if (out >= 0) { char row[100]; int n=snprintf(row,sizeof row,"%llu %zu\n",(unsigned long long)calls,length); (void)real_write(out,row,(size_t)n); close(out); }
    }
    const char *at=getenv("CJTUI_A_WRITE_FAIL_AT");
    if (at != NULL && calls == strtoull(at,NULL,10)) {
        const char *mode=getenv("CJTUI_A_WRITE_FAULT");
        if (mode != NULL && mode[0]=='p' && length>1) return real_write(fd,buffer,1);
        errno=EIO; return -1;
    }
    // In partial mode the next call fails, causing exactly one delivered byte.
    if (at != NULL && calls == strtoull(at,NULL,10)+1) {
        const char *mode=getenv("CJTUI_A_WRITE_FAULT");
        if (mode != NULL && mode[0]=='p') { errno=EIO; return -1; }
    }
    return real_write(fd,buffer,length);
}
