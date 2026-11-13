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
#include <dirent.h>
#include <sys/sysmacros.h>
static int logfd;static int seq;
static void save(const char *name,const void *data,size_t count){char path[256];snprintf(path,sizeof path,"/evidence/%s",name);int fd=open(path,O_WRONLY|O_CREAT|O_TRUNC,0666);if(fd<0 || write(fd,data,count)!=(ssize_t)count)exit(74);close(fd);}

static void dump(const char *phase){
 const char *paths[]={"/dev/vcsa1","/dev/vcsu1"};
 for(int k=0;k<(!strcmp(phase,"PROFILE")?0:2);k++){unsigned char b[16384];int f=open(paths[k],O_RDONLY);int n=f<0?-1:read(f,b,sizeof b);if(f>=0)close(f);dprintf(logfd,"GRID seq=%d phase=%s path=%s n=%d hex=",seq,phase,paths[k],n);for(int i=0;i<n;i++)dprintf(logfd,"%02x",b[i]);dprintf(logfd,"\n");}const char *names[]={"M","P","C","trace","prevent","escape","C-clean","P-clean","M-clean"};
 for(int k=0;k<9;k++){char path[128],value[4096];snprintf(path,sizeof path,"/evidence/%s",names[k]);int af=open(path,O_RDONLY);int an=af<0?0:read(af,value,sizeof value);if(af>=0)close(af);if(an>0){dprintf(logfd,"ACK seq=%d name=%s hex=",seq,names[k]);for(int j=0;j<an;j++)dprintf(logfd,"%02x",(unsigned char)value[j]);dprintf(logfd,"\n");}}seq++;
}
static int resize_vt(int cols,int rows){struct vt_sizes size={(unsigned short)rows,(unsigned short)cols,0};int result=ioctl(0,VT_RESIZE,&size),saved=errno;struct winsize actual={0};int readback=ioctl(0,TIOCGWINSZ,&actual);dprintf(logfd,"VT_RESIZE request=%dx%d rc=%d errno=%d readback_rc=%d actual=%dx%d\n",cols,rows,result,saved,readback,actual.ws_col,actual.ws_row);return result==0 && readback==0 && actual.ws_col==cols && actual.ws_row==rows?0:-1;}
int main(int argc,char **argv){
 if(argc!=2)return 2;
 logfd=open("/dev/ttyS0",O_WRONLY|O_NOCTTY);int control=open("/dev/ttyS1",O_RDWR|O_NOCTTY|O_NONBLOCK);struct termios ct;if(control>=0 && !tcgetattr(control,&ct)){cfmakeraw(&ct);tcsetattr(control,TCSANOW,&ct);}
 struct stat st;fstat(1,&st);dprintf(logfd,"OBSERVER_ID uid=%u euid=%u stdout_tty=%s mode=%o dev=%u:%u\n",getuid(),geteuid(),ttyname(1),st.st_mode,major(st.st_rdev),minor(st.st_rdev));
 struct utsname u;uname(&u);dprintf(logfd,"KERNEL %s %s %s\n",u.sysname,u.release,u.version);
 struct winsize w={0};struct vt_stat v={0};unsigned char kt=0;int wr=ioctl(0,TIOCGWINSZ,&w),vr=ioctl(0,VT_GETSTATE,&v),kr=ioctl(0,KDGKBTYPE,&kt);dprintf(logfd,"TTY=%s TERM=%s GRID=%ux%u winsize_rc=%d VT_GETSTATE_rc=%d active=%u KDGKBTYPE_rc=%d keyboard=%u SCENE=%s\n",ttyname(0),getenv("TERM"),w.ws_col,w.ws_row,wr,vr,v.v_active,kr,kt,argv[1]);
 if(resize_vt(40,10)){dprintf(logfd,"HOST_PHYSICAL_RESIZE_UNSUPPORTED\n");return 77;}struct termios before={0},after={0};tcgetattr(0,&before);save("termios-before.bin",&before,sizeof before);const char *initial=!strcmp(argv[1],"hidden")?"\033[?25l":"\033[?25h";write(1,initial,6);dprintf(logfd,"INITIAL_CURSOR=%s external_control_before_product=1\n",argv[1]);dump("BEFORE");
 pid_t child=fork();if(!child){char trace[128];snprintf(trace,sizeof trace,"/evidence/%s.strace",argv[1]);char app[128];snprintf(app,sizeof app,"/apps/%s","overlay-c");
 {if(setgid(1000)||setuid(1000)){perror("dropuid");_exit(126);}}
 dprintf(logfd,"PRODUCT_ID uid=%u euid=%u gid=%u stdout=%s scene=%s\n",getuid(),geteuid(),getgid(),ttyname(1),argv[1]);

 int errorfd=open("/evidence/product.stderr",O_WRONLY|O_CREAT|O_TRUNC,0666);if(errorfd<0 || dup2(errorfd,2)<0)_exit(74);close(errorfd);
 execl("/usr/bin/strace","strace","-f","-xx","-s","65535","-e","trace=read,write,ioctl,newfstatat,fstat,openat,execve,prctl,rt_sigaction,poll","-o",trace,app,(char*)0);perror("exec");_exit(127);}
 dprintf(logfd,"PRODUCT_STARTED tracer_pid=%d\n",child);int status=0;int ready=0;char tracepath[128];snprintf(tracepath,sizeof tracepath,"/evidence/%s.strace",argv[1]);
 while(waitpid(child,&status,WNOHANG)==0){
 if(!ready){int tf=open(tracepath,O_RDONLY);if(tf>=0){char tail[65537];off_t size=lseek(tf,0,SEEK_END);lseek(tf,size>65536?size-65536:0,SEEK_SET);int n=read(tf,tail,65536);close(tf);if(n>0){tail[n]=0;if(strstr(tail,"write(1, ")){ready=1;dprintf(logfd,"PRODUCT_OUTPUT_READY from_actual_stdout_trace=1\n");}}}}
 struct pollfd p={control,POLLIN,0};poll(&p,1,50);if(p.revents&POLLIN){char b[128];int n=read(control,b,sizeof b);for(int i=0;i<n;i++){if(b[i]=='s')dump("RUNNING");if(b[i]=='p')dump("PROFILE");if(b[i]=='i'){DIR *pd=opendir("/proc");struct dirent *pe;int delivered=0;while(pd && (pe=readdir(pd))){int pid=atoi(pe->d_name);if(pid<=0)continue;char ep[128],target[512];snprintf(ep,sizeof ep,"/proc/%d/exe",pid);int count=readlink(ep,target,sizeof(target)-1);if(count<0)continue;target[count]=0;if(!strcmp(target,"/apps/overlay-c")){int rc=kill(pid,SIGINT);dprintf(logfd,"ACTUAL_SIGNAL pid=%d signal=SIGINT rc=%d errno=%d\n",pid,rc,errno);delivered=rc==0;break;}}if(pd)closedir(pd);if(!delivered)dprintf(logfd,"ACTUAL_SIGNAL_FAILED\n");}}}}
 tcgetattr(0,&after);save("termios-after.bin",&after,sizeof after);dprintf(logfd,"RESTORE iflag=%lx/%lx oflag=%lx/%lx cflag=%lx/%lx lflag=%lx/%lx cc_equal=%d termios_equal=%d\n",(long)before.c_iflag,(long)after.c_iflag,(long)before.c_oflag,(long)after.c_oflag,(long)before.c_cflag,(long)after.c_cflag,(long)before.c_lflag,(long)after.c_lflag,memcmp(before.c_cc,after.c_cc,NCCS)==0,memcmp(&before,&after,sizeof before)==0);dump("EXIT");
 int rc=WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);dprintf(logfd,"PRODUCT_EXIT=%d raw_status=%d\n",rc,status);dprintf(logfd,"EXIT_CAPTURE_BARRIER\n");struct pollfd release={control,POLLIN,0};int released=0;for(int i=0;i<600 && !released;i++){if(poll(&release,1,50)>0){char command;released=read(control,&command,1)==1 && command=='e';}}if(!released)return 75;return rc;
}
