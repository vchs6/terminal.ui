#define _GNU_SOURCE
#include <dlfcn.h>
#include <unistd.h>
#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
/* Test-only TTY syscall fault. Select by legacy physical index, or by an
 * explicitly armed literal transaction marker. Never guess a product call count. */
static uint64_t calls;
static int fired, partial_pending;
static ssize_t (*real_write)(int,const void *,size_t);
static int contains(const void *p,size_t n,const char *needle) {
    return memmem(p,n,needle,strlen(needle)) != NULL;
}
static int selected(const void *p,size_t n) {
    const char *arm=getenv("CJTUI_A_WRITE_ARM_FILE");
    if (arm && access(arm,F_OK)) return 0;
    const char *kind=getenv("CJTUI_A_WRITE_MATCH");
    if (!kind) {
        const char *at=getenv("CJTUI_A_WRITE_FAIL_AT");
        return at && calls==strtoull(at,NULL,10);
    }
    if (!strcmp(kind,"query")) return n==7 && !memcmp(p,"\033[?25$p",7);
    if (!strcmp(kind,"frame")) return contains(p,n,"AAAA") || contains(p,n,"BBBB");
    if (!strcmp(kind,"caret-only")) return contains(p,n,"\033[1;3H") && !contains(p,n,"AAAA") && !contains(p,n,"BBBB");
    if (!strcmp(kind,"cleanup")) return contains(p,n,"\033[?25l");
    return 0;
}
static void record(const void *p,size_t n,const char *action,ssize_t result) {
    const char *path=getenv("CJTUI_A_WRITE_TRACE");
    if (!path) return;
    int fd=open(path,O_WRONLY|O_CREAT|O_APPEND,0600);
    if (fd<0) return;
    char row[2300];
    int used=snprintf(row,sizeof row,"%llu %zu %s %lld ",(unsigned long long)calls,n,action,(long long)result);
    const unsigned char *bytes=p;
    for(size_t i=0;i<n && i<1024 && used+3<(int)sizeof row;++i) used+=snprintf(row+used,sizeof row-(size_t)used,"%02x",bytes[i]);
    row[used++]='\n';(void)real_write(fd,row,(size_t)used);close(fd);
}
ssize_t write(int fd,const void *p,size_t n) {
    if (!real_write) { void *symbol=dlsym(RTLD_NEXT,"write");*(void **)(&real_write)=symbol;if(!real_write){errno=EIO;return -1;} }
    if(fd!=STDOUT_FILENO || !isatty(fd)) return real_write(fd,p,n);
    ++calls;
    if(partial_pending) { partial_pending=0;record(p,n,"partial-fatal",-1);errno=EIO;return -1; }
    if(!fired && selected(p,n)) {
        fired=1;const char *mode=getenv("CJTUI_A_WRITE_FAULT");
        if(mode && mode[0]=='p' && n>1) {
            ssize_t got=real_write(fd,p,1);partial_pending=got>0;record(p,n,"partial",got);return got;
        }
        record(p,n,"zero",-1);errno=EIO;return -1;
    }
    ssize_t got=real_write(fd,p,n);int saved=errno;record(p,n,"ok",got);errno=saved;return got;
}
