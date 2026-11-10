#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/utsname.h>
#include <linux/kd.h>
#include <linux/vt.h>
static int logfd;
static void dump_screen(const char *phase){unsigned char b[8192];int f=open("/dev/vcsa1",O_RDONLY);int n=read(f,b,sizeof b);close(f);dprintf(logfd,"VCSA_%s n=%d hex=",phase,n);for(int i=0;i<n;i++)dprintf(logfd,"%02x",b[i]);dprintf(logfd,"\n");}
int main(void){
logfd=open("/dev/ttyS0",O_WRONLY|O_NOCTTY);struct utsname u;uname(&u);dprintf(logfd,"KERNEL %s %s %s\n",u.sysname,u.release,u.version);
struct winsize w={0};struct vt_stat v={0};unsigned char kt=0;int wr=ioctl(0,TIOCGWINSZ,&w),vr=ioctl(0,VT_GETSTATE,&v),kr=ioctl(0,KDGKBTYPE,&kt);dprintf(logfd,"TTY=%s TERM=%s GRID=%ux%u winsize_rc=%d VT_GETSTATE_rc=%d active=%u KDGKBTYPE_rc=%d keyboard=%u\n",ttyname(0),getenv("TERM"),w.ws_col,w.ws_row,wr,vr,v.v_active,kr,kt);
struct termios before,raw,after;if(tcgetattr(0,&before))return 3;raw=before;cfmakeraw(&raw);if(tcsetattr(0,TCSANOW,&raw))return 4;
printf("\033[2J\033[HLinux kernel VT readiness (virtual VGA / PS2)\r\n\033[1;36m80x25 fixed grid | cyan bold\033[0m\r\n\033[31mred\033[0m \033[4munderline\033[0m \033[7minverse\033[0m\r\nAwaiting keyboard: p, Up, q\r\n");fflush(stdout);dump_screen("READY");dprintf(logfd,"READY\n");
unsigned char c;int n;while((n=read(0,&c,1))==1){dprintf(logfd,"INPUT %02x\n",c);printf("key=%02x\r\n",c);fflush(stdout);if(c=='q')break;}
int rr=tcsetattr(0,TCSANOW,&before);tcgetattr(0,&after);dprintf(logfd,"RESTORE rc=%d iflag=%lx/%lx oflag=%lx/%lx cflag=%lx/%lx lflag=%lx/%lx cc_equal=%d\n",rr,(long)before.c_iflag,(long)after.c_iflag,(long)before.c_oflag,(long)after.c_oflag,(long)before.c_cflag,(long)after.c_cflag,(long)before.c_lflag,(long)after.c_lflag,memcmp(before.c_cc,after.c_cc,NCCS)==0);
printf("PROBE normal exit 0; input modes restored\n");fflush(stdout);dump_screen("EXIT");dprintf(logfd,"PROBE_EXIT=0\n");return 0;}
