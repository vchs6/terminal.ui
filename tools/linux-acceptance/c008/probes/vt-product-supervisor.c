#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <poll.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/utsname.h>
#include <sys/wait.h>
#include <linux/kd.h>
#include <linux/vt.h>
static int logfd;static int seq;
static void dump(const char *phase){
 const char *paths[]={"/dev/vcsa1","/dev/vcsu1"};
 for(int k=0;k<2;k++){unsigned char b[16384];int f=open(paths[k],O_RDONLY);int n=f<0?-1:read(f,b,sizeof b);if(f>=0)close(f);dprintf(logfd,"GRID seq=%d phase=%s path=%s n=%d hex=",seq,phase,paths[k],n);for(int i=0;i<n;i++)dprintf(logfd,"%02x",b[i]);dprintf(logfd,"\n");}seq++;
}
int main(int argc,char **argv){
 if(argc!=2)return 2;
 logfd=open("/dev/ttyS0",O_WRONLY|O_NOCTTY);int control=open("/dev/ttyS1",O_RDWR|O_NOCTTY|O_NONBLOCK);struct termios ct;if(control>=0 && !tcgetattr(control,&ct)){cfmakeraw(&ct);tcsetattr(control,TCSANOW,&ct);}
 struct utsname u;uname(&u);dprintf(logfd,"KERNEL %s %s %s\n",u.sysname,u.release,u.version);
 struct winsize w={0};struct vt_stat v={0};unsigned char kt=0;int wr=ioctl(0,TIOCGWINSZ,&w),vr=ioctl(0,VT_GETSTATE,&v),kr=ioctl(0,KDGKBTYPE,&kt);dprintf(logfd,"TTY=%s TERM=%s GRID=%ux%u winsize_rc=%d VT_GETSTATE_rc=%d active=%u KDGKBTYPE_rc=%d keyboard=%u SCENE=%s\n",ttyname(0),getenv("TERM"),w.ws_col,w.ws_row,wr,vr,v.v_active,kr,kt,argv[1]);
 struct termios before={0},after={0};tcgetattr(0,&before);dump("BEFORE");
 pid_t child=fork();if(!child){char trace[128];snprintf(trace,sizeof trace,"/evidence/%s.strace",argv[1]);char app[128];snprintf(app,sizeof app,"/apps/%s",argv[1]);execl("/usr/bin/strace","strace","-f","-xx","-s","65535","-e","trace=read,write,ioctl","-o",trace,app,(char*)0);perror("exec");_exit(127);}
 dprintf(logfd,"PRODUCT_STARTED pid=%d\n",child);int status=0;
 while(waitpid(child,&status,WNOHANG)==0){struct pollfd p={control,POLLIN,0};poll(&p,1,50);if(p.revents&POLLIN){char b[128];int n=read(control,b,sizeof b);for(int i=0;i<n;i++){if(b[i]=='s')dump("RUNNING");if(b[i]=='k')kill(child,SIGTERM);}}}
 tcgetattr(0,&after);dprintf(logfd,"RESTORE iflag=%lx/%lx oflag=%lx/%lx cflag=%lx/%lx lflag=%lx/%lx cc_equal=%d termios_equal=%d\n",(long)before.c_iflag,(long)after.c_iflag,(long)before.c_oflag,(long)after.c_oflag,(long)before.c_cflag,(long)after.c_cflag,(long)before.c_lflag,(long)after.c_lflag,memcmp(before.c_cc,after.c_cc,NCCS)==0,memcmp(&before,&after,sizeof before)==0);dump("EXIT");
 int rc=WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);dprintf(logfd,"PRODUCT_EXIT=%d raw_status=%d\n",rc,status);sleep(5);return rc;
}
