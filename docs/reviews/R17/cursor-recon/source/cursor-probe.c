#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <poll.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/utsname.h>
#include <sys/stat.h>
#include <linux/vt.h>
#include <linux/kd.h>
static int logfd, outfd, stage;static const char *dir;static int vt;
static void all(int fd,const void *p,size_t n){const char *c=p;while(n){ssize_t w=write(fd,c,n);if(w<0){if(errno==EINTR)continue;_exit(9);}c+=w;n-=w;}}
static void emit(const char *p){all(outfd,p,strlen(p));all(1,p,strlen(p));}
static void dump(const char *phase){if(!vt)return;const char *ps[]={"/dev/vcsa1","/dev/vcsu1"};for(int k=0;k<2;k++){unsigned char b[16384];int fd=open(ps[k],O_RDONLY);int n=fd<0?-1:read(fd,b,sizeof b);if(fd>=0)close(fd);dprintf(logfd,"GRID seq=%d phase=%s path=%s n=%d hex=",stage,phase,ps[k],n);for(int i=0;i<n;i++)dprintf(logfd,"%02x",b[i]);dprintf(logfd,"\n");}}
static void query(const char *phase){char path[512];snprintf(path,sizeof path,"%s/%d-%s-response.bin",dir,stage,phase);int fd=open(path,O_WRONLY|O_CREAT|O_TRUNC,0644);emit("\033[?25$p");struct pollfd p={0,POLLIN,0};unsigned char b[512];int total=0;for(int i=0;i<6;i++){int r=poll(&p,1,100);if(r>0){int n=read(0,b,sizeof b);if(n>0){all(fd,b,n);total+=n;dprintf(logfd,"RESPONSE stage=%d phase=%s hex=",stage,phase);for(int j=0;j<n;j++)dprintf(logfd,"%02x",b[j]);dprintf(logfd,"\n");}}}close(fd);dprintf(logfd,"QUERY stage=%d phase=%s total=%d timeout_ms=600\n",stage,phase,total);}
static void hold(const char *phase){dump(phase);dprintf(logfd,"READY stage=%d phase=%s\n",stage,phase);if(vt){unsigned char b;int n=read(0,&b,1);dprintf(logfd,"ADVANCE stage=%d n=%d hex=%02x\n",stage,n,b);}else{char p[512];snprintf(p,sizeof p,"%s/ack-%d",dir,stage);while(access(p,F_OK))usleep(20000);}stage++;}
int main(int argc,char **argv){if(argc!=4)return 2;dir=argv[1];vt=!strcmp(argv[3],"vt");int visible=!strcmp(argv[2],"visible");char p[512];snprintf(p,sizeof p,"%s/events.log",dir);logfd=vt?open("/dev/ttyS0",O_WRONLY|O_NOCTTY):open(p,O_WRONLY|O_CREAT|O_TRUNC,0644);snprintf(p,sizeof p,"%s/output.ansi",dir);outfd=open(p,O_WRONLY|O_CREAT|O_TRUNC,0644);struct utsname u;uname(&u);struct winsize w={0};struct vt_stat v={0};unsigned char kb=0;int wr=ioctl(0,TIOCGWINSZ,&w),vr=ioctl(0,VT_GETSTATE,&v),kr=ioctl(0,KDGKBTYPE,&kb);dprintf(logfd,"START pid=%d tty=%s TERM=%s kernel=%s grid=%ux%u winsize_rc=%d vt_rc=%d active=%u kb_rc=%d kb=%u initial=%s\n",getpid(),ttyname(0),getenv("TERM"),u.release,w.ws_col,w.ws_row,wr,vr,v.v_active,kr,kb,argv[2]);struct termios before={0},raw={0},after={0};if(tcgetattr(0,&before))return 3;raw=before;cfmakeraw(&raw);if(tcsetattr(0,TCSANOW,&raw))return 4;
 emit("\033[0m\033[2J\033[HNative cursor mode 25 capability probe\r\nSame marker and same caret cell in every phase\r\nMARKER | | END\033[3;9H");emit(visible?"\033[?25h":"\033[?25l");query("baseline");hold("baseline");
 emit("\033[?25s");emit(visible?"\033[?25l":"\033[?25h");query("changed");hold("changed");
 emit("\033[?25r");query("restored");hold("restored");
 int rr=tcsetattr(0,TCSANOW,&before);tcgetattr(0,&after);dprintf(logfd,"RESTORE_TERMIOS rc=%d equal=%d\n",rr,memcmp(&before,&after,sizeof before)==0);dump("exit");dprintf(logfd,"FIXTURE_EXIT=0\n");close(outfd);close(logfd);return 0;
}
