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
#include <sys/stat.h>
#include <sys/sysmacros.h>
static int logfd;static int seq;
static void dump(const char *phase){
 const char *paths[]={"/dev/vcsa1","/dev/vcsu1"};
 for(int k=0;k<2;k++){unsigned char b[16384];int f=open(paths[k],O_RDONLY);int n=f<0?-1:read(f,b,sizeof b);if(f>=0)close(f);dprintf(logfd,"GRID seq=%d phase=%s path=%s n=%d hex=",seq,phase,paths[k],n);for(int i=0;i<n;i++)dprintf(logfd,"%02x",b[i]);dprintf(logfd,"\n");}char profile[4096];int pf=open("/evidence/profile.txt",O_RDONLY);int pn=pf<0?0:read(pf,profile,sizeof(profile)-1);if(pf>=0)close(pf);if(pn>0){profile[pn]=0;dprintf(logfd,"PROFILE seq=%d BEGIN\n%sPROFILE_END\n",seq,profile);}seq++;
}
int main(int argc,char **argv){
 if(argc!=2)return 2;
 logfd=open("/dev/ttyS0",O_WRONLY|O_NOCTTY);int control=open("/dev/ttyS1",O_RDWR|O_NOCTTY|O_NONBLOCK);struct termios ct;if(control>=0 && !tcgetattr(control,&ct)){cfmakeraw(&ct);tcsetattr(control,TCSANOW,&ct);}
 struct stat st;fstat(1,&st);dprintf(logfd,"OBSERVER_ID uid=%u euid=%u stdout_tty=%s mode=%o dev=%u:%u\n",getuid(),geteuid(),ttyname(1),st.st_mode,major(st.st_rdev),minor(st.st_rdev));
 struct utsname u;uname(&u);dprintf(logfd,"KERNEL %s %s %s\n",u.sysname,u.release,u.version);
 struct winsize w={0};struct vt_stat v={0};unsigned char kt=0;int wr=ioctl(0,TIOCGWINSZ,&w),vr=ioctl(0,VT_GETSTATE,&v),kr=ioctl(0,KDGKBTYPE,&kt);dprintf(logfd,"TTY=%s TERM=%s GRID=%ux%u winsize_rc=%d VT_GETSTATE_rc=%d active=%u KDGKBTYPE_rc=%d keyboard=%u SCENE=%s\n",ttyname(0),getenv("TERM"),w.ws_col,w.ws_row,wr,vr,v.v_active,kr,kt,argv[1]);
 struct termios before={0},after={0};tcgetattr(0,&before);dump("BEFORE");
 pid_t child=fork();if(!child){char trace[128];snprintf(trace,sizeof trace,"/evidence/%s.strace",argv[1]);char app[128];snprintf(app,sizeof app,"/apps/%s",strncmp(argv[1],"session",7)==0?"session":"glyph");
 if(strstr(argv[1],"uid1000")){if(setgid(1000)||setuid(1000)){perror("dropuid");_exit(126);}}
 dprintf(logfd,"PRODUCT_ID uid=%u euid=%u gid=%u stdout=%s scene=%s\n",getuid(),geteuid(),getgid(),ttyname(1),argv[1]);
 if(strstr(argv[1],"deny")){setenv("VT_EXEC_TARGET",app,1);strcpy(app,"/deny-map");}
 execl("/usr/bin/strace","strace","-f","-xx","-s","65535","-e","trace=read,write,ioctl,newfstatat,fstat,openat,execve,prctl","-o",trace,app,(char*)0);perror("exec");_exit(127);}
 dprintf(logfd,"PRODUCT_STARTED pid=%d\n",child);int status=0;int ready=0;char tracepath[128];snprintf(tracepath,sizeof tracepath,"/evidence/%s.strace",argv[1]);
 while(waitpid(child,&status,WNOHANG)==0){
 if(!ready){int tf=open(tracepath,O_RDONLY);if(tf>=0){char tail[65537];off_t size=lseek(tf,0,SEEK_END);lseek(tf,size>65536?size-65536:0,SEEK_SET);int n=read(tf,tail,65536);close(tf);if(n>0){tail[n]=0;if(strstr(tail,"write(1, ")){ready=1;dprintf(logfd,"PRODUCT_OUTPUT_READY from_actual_stdout_trace=1\n");}}}}
 struct pollfd p={control,POLLIN,0};poll(&p,1,50);if(p.revents&POLLIN){char b[128];int n=read(control,b,sizeof b);for(int i=0;i<n;i++){if(b[i]=='s')dump("RUNNING");if(b[i]=='k')kill(child,SIGTERM);}}}
 tcgetattr(0,&after);dprintf(logfd,"RESTORE iflag=%lx/%lx oflag=%lx/%lx cflag=%lx/%lx lflag=%lx/%lx cc_equal=%d termios_equal=%d\n",(long)before.c_iflag,(long)after.c_iflag,(long)before.c_oflag,(long)after.c_oflag,(long)before.c_cflag,(long)after.c_cflag,(long)before.c_lflag,(long)after.c_lflag,memcmp(before.c_cc,after.c_cc,NCCS)==0,memcmp(&before,&after,sizeof before)==0);dump("EXIT");
 int rc=WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);dprintf(logfd,"PRODUCT_EXIT=%d raw_status=%d\n",rc,status);sleep(5);return rc;
}
