#define _POSIX_C_SOURCE 200809L
#include <poll.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
/* Infrastructure-only: literal syscall payloads, no cjtui or protocol model. */
int main(int argc,char **argv) {
    if(argc!=2)return 2;
    struct termios before,raw;
    if(tcgetattr(0,&before))return 3;
    raw=before;raw.c_lflag&=(tcflag_t)~(ECHO|ICANON);raw.c_cc[VMIN]=1;raw.c_cc[VTIME]=0;
    if(tcsetattr(0,TCSANOW,&raw))return 4;
    int result=0;
    if(!strcmp(argv[1],"hup")) {
        (void)write(1,"READY",5);
        for(int i=0;i<30;++i){struct pollfd p={.fd=0,.events=POLLIN};if(poll(&p,1,100)>0 && (p.revents&POLLHUP)){result=0;goto done;}}
        result=5;
    } else {
        const char *data=!strcmp(argv[1],"query")?"\033[?25$p":!strcmp(argv[1],"frame")?"AAAA":!strcmp(argv[1],"caret-only")?"\033[1;3H":"\033[?25l";
        size_t offset=0,length=strlen(data);
        while(offset<length){ssize_t got=write(1,data+offset,length-offset);if(got<=0){result=14;break;}offset+=(size_t)got;}
    }
 done:
    if(tcsetattr(0,TCSANOW,&before))return 6;
    return result;
}
