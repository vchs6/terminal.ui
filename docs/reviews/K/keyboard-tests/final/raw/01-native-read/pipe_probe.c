#define _POSIX_C_SOURCE 200809L
#include <assert.h>
#include <errno.h>
#include <poll.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
int cjt_read(int);
int cjt_open(void);
int cjt_close(void);
static void bind_pipe(int fds[2]) { assert(pipe(fds)==0);assert(dup2(fds[0],0)==0);close(fds[0]); }
int main(int argc,char **argv) {
    if(argc==2 && !strcmp(argv[1],"positive")) {
        int f[2];bind_pipe(f);unsigned char bytes[]={0,255};assert(write(f[1],bytes,2)==2);
        int zero=cjt_read(0),high=cjt_read(0),idle=cjt_read(0);
        printf("POSITIVE byte0=%d byte255=%d timeout=%d\n",zero,high,idle);close(f[1]);
        return !(zero==0 && high==255 && idle==-1);
    }
    if(argc==2 && !strcmp(argv[1],"contract")) {
        int f[2];bind_pipe(f);assert(write(f[1],"ABC",3)==3);close(f[1]);
        struct pollfd p={0,POLLIN,0};assert(poll(&p,1,0)==1);
        int first=cjt_read(0);unsigned char tail[3]={0};ssize_t n=read(0,tail,3);unsigned char byte;ssize_t eof=read(0,&byte,1);int native_eof=cjt_read(0);
        printf("CONTRACT actual_poll=%x POLLIN=%d HUP=%d native_first=%d actual_tail_n=%zd tail=%.*s actual_read0=%zd native_eof=%d expected_first=65 expected_eof=-4\n",p.revents,!!(p.revents&POLLIN),!!(p.revents&POLLHUP),first,n,(int)(n>0?n:0),tail,eof,native_eof);
        assert((p.revents&(POLLIN|POLLHUP))==(POLLIN|POLLHUP));assert(n==3 && !memcmp(tail,"ABC",3) && eof==0);
        return !(first==65 && native_eof==-4);
    }
    if(argc==2 && (!strcmp(argv[1],"tty-control") || !strcmp(argv[1],"tty-product"))) {
        int opened=cjt_open();printf("TTY open=%d\n",opened);fflush(stdout);assert(opened==0);
        int ok=0;
        if(!strcmp(argv[1],"tty-control")) {
            unsigned char bytes[3]={0};ssize_t n=read(0,bytes,3);unsigned char c;ssize_t eof=read(0,&c,1);
            printf("TTY_CONTROL actual_pipe_read=%zd tail=%.*s actual_pipe_read0=%zd\n",n,(int)(n>0?n:0),bytes,eof);ok=n==3 && !memcmp(bytes,"ABC",3) && eof==0;
        } else {
            int first=cjt_read(0);printf("TTY_PRODUCT native_first=%d expected65\n",first);ok=first==65;
        }
        int closed=cjt_close();printf("TTY close=%d\n",closed);return !(ok && closed==0);
    }
    return 2;
}
