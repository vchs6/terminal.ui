#define _POSIX_C_SOURCE 200809L
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
// Test-infrastructure peer, NOT a cjtui replacement or product behavior oracle.
// It exercises raw PTY delivery, exact recording, termios snapshots and failure injection.
int main(int argc, char **argv) {
    struct termios original, raw;
    if (tcgetattr(0,&original)!=0) return 10;
    raw=original; raw.c_lflag &= (tcflag_t)~(ECHO|ICANON); raw.c_cc[VMIN]=1; raw.c_cc[VTIME]=0;
    if (tcsetattr(0,TCSANOW,&raw)!=0) return 11;
    const char *output="\033[?25$pFIXTURE-READY";
    if (write(1,output,strlen(output))<0) { (void)tcsetattr(0,TCSANOW,&original); return 12; }
    if (argc>1 && strcmp(argv[1],"illegal-mode")==0) (void)write(1,"\033[?25h",6);
    char c;
    while (read(0,&c,1)==1) {
        if (c=='q') break;
        (void)write(1,&c,1);
    }
    if (!(argc>1 && strcmp(argv[1],"leak-termios")==0)) (void)tcsetattr(0,TCSANOW,&original);
    return 0;
}
