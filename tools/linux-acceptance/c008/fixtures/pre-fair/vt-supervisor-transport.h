/* External operator transport overlay for the unchanged vt-product-supervisor.
 * Only owned guest tty1 configuration, real QMP keyboard delivery, and copies
 * of original strace read/write/ioctl records. No exec/env tracing or renderer.
 */
#include <sys/stat.h>
#include <linux/keyboard.h>
#include <time.h>
#include <limits.h>
#include <sys/syscall.h>
static int tr_fifo=-1,tr_archive=-1,tr_mapped=0;
static char tr_fifo_path[128];
static struct kbsentry tr_original_string;
static struct kbentry tr_original_key;
static unsigned tr_map_seq;static unsigned tr_fixture_seq;
static char tr_command[16386];static size_t tr_command_used;
static void tr_die(const char *what){dprintf(logfd,"TRANSPORT_ERROR operation=%s errno=%d\n",what,errno);exit(3);}
static void tr_write(int fd,const void *buffer,size_t length){
 const char *p=buffer;while(length){ssize_t n=write(fd,p,length);if(n<0&&errno==EINTR)continue;if(n<=0)tr_die("write");p+=n;length-=(size_t)n;}
}
static void tr_termios(const char *phase){
 struct termios value={0};int rc=tcgetattr(1,&value),error=errno;char path[128];snprintf(path,sizeof path,"/evidence/stdout-termios-%s.bin",phase);
 if(rc==0){int fd=open(path,O_WRONLY|O_CREAT|O_EXCL,0600);if(fd<0)tr_die("stdout-termios-file");tr_write(fd,&value,sizeof value);close(fd);}
 dprintf(logfd,"STDOUT_TERMIOS phase=%s rc=%d errno=%d size=%zu iflag=%lx oflag=%lx cflag=%lx lflag=%lx line=%u ispeed=%u ospeed=%u cc_hex=",phase,rc,rc?error:0,sizeof value,(long)value.c_iflag,(long)value.c_oflag,(long)value.c_cflag,(long)value.c_lflag,value.c_line,value.c_ispeed,value.c_ospeed);
 for(size_t i=0;i<NCCS;i++){dprintf(logfd,"%02x",value.c_cc[i]);}dprintf(logfd,"\n");
}
/* Literal existing host_probe.py query/poll/raw-restore mechanics, native guest
 * port only because the admitted minimal guest contains no Python runtime. */
static void tr_cursor(const char *phase){
 struct termios before={0},raw={0},after={0};if(tcgetattr(0,&before))tr_die("cursor-termios");raw=before;cfmakeraw(&raw);
 if(tcsetattr(0,TCSANOW,&raw))tr_die("cursor-setraw");
 struct timespec start,now;clock_gettime(CLOCK_REALTIME,&start);unsigned char reply[129];size_t used=0;
 const char query[]="\033[?25$p";tr_write(1,query,sizeof query-1);clock_gettime(CLOCK_MONOTONIC,&now);long long deadline=(long long)now.tv_sec*1000+now.tv_nsec/1000000+650;
 for(;;){clock_gettime(CLOCK_MONOTONIC,&now);long long remaining=deadline-((long long)now.tv_sec*1000+now.tv_nsec/1000000);if(remaining<=0)break;
  struct pollfd p={0,POLLIN,0};int ready=poll(&p,1,(int)remaining);if(ready<0&&errno==EINTR)continue;if(ready<0)tr_die("cursor-poll");if(ready&&p.revents&POLLIN){ssize_t n=read(0,reply+used,sizeof reply-used);if(n<0&&errno==EINTR)continue;if(n<0)tr_die("cursor-read");used+=(size_t)n;if(used>128)break;}
 }
 if(tcsetattr(0,TCSANOW,&before)||tcgetattr(0,&after)||memcmp(&before,&after,sizeof before))tr_die("cursor-raw-restore");
 struct timespec end;clock_gettime(CLOCK_REALTIME,&end);
 dprintf(logfd,"CURSOR_OBSERVATION phase=%s tty=%s query_hex=1b5b3f32352470 response_hex=",phase,ttyname(0));for(size_t i=0;i<used;i++)dprintf(logfd,"%02x",reply[i]);
 dprintf(logfd," deadline_ms=650 start_ns=%lld end_ns=%lld probe_termios_restored=1 source=actual_tty_no_injection\n",(long long)start.tv_sec*1000000000+start.tv_nsec,(long long)end.tv_sec*1000000000+end.tv_nsec);
}
static void tr_stdout_identity(void){
 struct stat st={0};struct vt_stat vt={0};struct winsize size={0};int mode=-1;
 int fr=fstat(1,&st),vr=ioctl(1,VT_GETSTATE,&vt),mr=ioctl(1,KDGETMODE,&mode),wr=ioctl(1,TIOCGWINSZ,&size);
 dprintf(logfd,"STDOUT_IDENTITY fd=1 tty=%s fstat_rc=%d dev=%lu ino=%lu rdev=%lu VT_GETSTATE_rc=%d active=%u KDGETMODE_rc=%d mode=%d TIOCGWINSZ_rc=%d cols=%u rows=%u\n",ttyname(1),fr,(unsigned long)st.st_dev,(unsigned long)st.st_ino,(unsigned long)st.st_rdev,vr,vt.v_active,mr,mode,wr,size.ws_col,size.ws_row);
 struct unipair *pairs=calloc(65535,sizeof *pairs);if(!pairs)tr_die("unimap-allocate");struct unimapdesc map={.entry_ct=65535,.entries=pairs};errno=0;int rc=ioctl(1,GIO_UNIMAP,&map),error=errno;
 if(!rc){int fd=open("/evidence/stdout-unimap.bin",O_WRONLY|O_CREAT|O_EXCL,0600);if(fd<0)tr_die("unimap-file");tr_write(fd,pairs,(size_t)map.entry_ct*sizeof *pairs);close(fd);}
 dprintf(logfd,"STDOUT_UNIMAP fd=1 rc=%d errno=%d count=%u pair_size=%zu hex=",rc,rc?error:0,map.entry_ct,sizeof *pairs);
 if(!rc){unsigned char *bytes=(unsigned char*)pairs;for(size_t i=0;i<(size_t)map.entry_ct*sizeof *pairs;i++)dprintf(logfd,"%02x",bytes[i]);}dprintf(logfd,"\n");free(pairs);tr_termios("before");tr_cursor("before");
}
/* Inherit the original controlling-terminal foreground group. Never isolate
 * the tracee group, change tty foreground ownership, or ignore job control. */
static void tr_require_foreground(const char *phase){
 pid_t group=getpgrp(),input=tcgetpgrp(0),output=tcgetpgrp(1);
 dprintf(logfd,"FOREGROUND phase=%s pid=%ld pgrp=%ld stdin_tpgid=%ld stdout_tpgid=%ld\n",phase,(long)getpid(),(long)group,(long)input,(long)output);
 if(group<=0||input!=group||output!=group)tr_die("legitimate-tty-foreground");
}
/* The known unreaped strace child owns the traced app. Open a stable pidfd,
 * check direct-parent membership, then signal that process only. The inherited
 * tty foreground group includes this supervisor and must never be signalled. */
static void tr_owned_terminate(pid_t tracer){
 if(tracer<=1)tr_die("cleanup-tracer-identity");
 char path[128];snprintf(path,sizeof path,"/proc/%ld/task/%ld/children",(long)tracer,(long)tracer);
 FILE *children=fopen(path,"r");if(!children){dprintf(logfd,"CLEANUP_CHILDREN tracer=%ld errno=%d signalled=0\n",(long)tracer,errno);return;}
 long tracee;while(fscanf(children,"%ld",&tracee)==1){
  if(tracee<=1||tracee>INT_MAX)tr_die("cleanup-tracee-range");
  int stable=(int)syscall(SYS_pidfd_open,(pid_t)tracee,0);if(stable<0){dprintf(logfd,"CLEANUP_PIDFD tracee=%ld errno=%d signalled=0\n",tracee,errno);continue;}
  snprintf(path,sizeof path,"/proc/%ld/status",tracee);FILE *status=fopen(path,"r");long parent=-1;char line[256];
  if(status){while(fgets(line,sizeof line,status)){if(sscanf(line,"PPid: %ld",&parent)==1)break;}fclose(status);}
  if(parent!=(long)tracer){close(stable);dprintf(logfd,"CLEANUP_MEMBERSHIP tracee=%ld parent=%ld expected=%ld signalled=0\n",tracee,parent,(long)tracer);continue;}
  errno=0;int rc=(int)syscall(SYS_pidfd_send_signal,stable,SIGTERM,NULL,0),error=errno;close(stable);
  dprintf(logfd,"CLEANUP_TRACEE_SIGTERM tracer=%ld tracee=%ld rc=%d errno=%d group_signal=0\n",(long)tracer,tracee,rc,rc?error:0);
 }fclose(children);
}
static void tr_init(const char *scene){
 tr_require_foreground("before-launch");tr_stdout_identity();char archive[128];snprintf(tr_fifo_path,sizeof tr_fifo_path,"/evidence/%s.tracefifo",scene);snprintf(archive,sizeof archive,"/evidence/%s.strace",scene);
 if(mkfifo(tr_fifo_path,0600))tr_die("mkfifo");
 tr_fifo=open(tr_fifo_path,O_RDWR|O_NONBLOCK);tr_archive=open(archive,O_WRONLY|O_CREAT|O_EXCL,0600);
 if(tr_fifo<0||tr_archive<0)tr_die("trace-open");
 dprintf(logfd,"TRANSPORT_TRACE read_write_ioctl_only=1 exec_env_tracing=0 fifo=%s archive=%s\n",tr_fifo_path,archive);
 if(system("/bin/sh /operator/guest-facts.sh"))tr_die("same-guest-raw-facts");
}
static void tr_drain(void){
 unsigned char bytes[2048];ssize_t n;
 while((n=read(tr_fifo,bytes,sizeof bytes))>0){
  tr_write(tr_archive,bytes,(size_t)n);
  dprintf(logfd,"TRACE hex=");for(ssize_t j=0;j<n;j++)dprintf(logfd,"%02x",bytes[j]);dprintf(logfd,"\n");
 }
 if(n<0&&errno!=EAGAIN&&errno!=EINTR)tr_die("trace-read");
}
static int tr_nibble(char c){if(c>='0'&&c<='9')return c-'0';if(c>='a'&&c<='f')return c-'a'+10;return -1;}
static void tr_map(void){
 size_t n=tr_command_used;struct kbsentry next={.kb_func=11},readback={.kb_func=11};
 if(n<1||tr_command[0]!='m'||(n-1)%2||(n-1)/2>511)tr_die("map-length");
 for(size_t i=1;i<n;i+=2){int a=tr_nibble(tr_command[i]),b=tr_nibble(tr_command[i+1]);if(a<0||b<0||!(a*16+b))tr_die("map-byte");next.kb_string[(i-1)/2]=(unsigned char)(a*16+b);}
 if(!tr_mapped){
  int mode=-1;if(ioctl(0,KDGKBMODE,&mode)||(mode!=K_XLATE&&mode!=K_UNICODE))tr_die("keyboard-mode");
  tr_original_string.kb_func=11;tr_original_key.kb_table=0;tr_original_key.kb_index=88;
  if(ioctl(0,KDGKBSENT,&tr_original_string)||ioctl(0,KDGKBENT,&tr_original_key))tr_die("keyboard-original");
  int fd=open("/evidence/keyboard-original.bin",O_WRONLY|O_CREAT|O_EXCL,0600);if(fd<0)tr_die("keyboard-save");
  tr_write(fd,&tr_original_key,sizeof tr_original_key);tr_write(fd,&tr_original_string,sizeof tr_original_string);close(fd);
  struct kbentry key={.kb_table=0,.kb_index=88,.kb_value=K_F12};
  if(ioctl(0,KDSKBENT,&key)){tr_die("keyboard-f12-map");}tr_mapped=1;
 }
 if(ioctl(0,KDSKBSENT,&next)||ioctl(0,KDGKBSENT,&readback)||memcmp(next.kb_string,readback.kb_string,512))tr_die("keyboard-string-readback");
 struct kbentry key_readback={.kb_table=0,.kb_index=88};if(ioctl(0,KDGKBENT,&key_readback)||key_readback.kb_value!=K_F12)tr_die("keyboard-map-readback");
 dprintf(logfd,"MAP_READY seq=%u tty=%s keycode=88 func=11 controlled_bytes_hex=%s\n",++tr_map_seq,ttyname(0),tr_command+1);
}
static void tr_fixture(void){
 size_t count=(tr_command_used-1)/2;if((tr_command_used-1)%2||count>8192)tr_die("fixture-length");
 unsigned char bytes[8192];for(size_t i=0;i<count;i++){int a=tr_nibble(tr_command[1+i*2]),b=tr_nibble(tr_command[2+i*2]);if(a<0||b<0)tr_die("fixture-hex");bytes[i]=(unsigned char)(a*16+b);}
 int fd=open("/evidence/selected.toml.next",O_WRONLY|O_CREAT|O_TRUNC|O_NOFOLLOW,0600);if(fd<0)tr_die("fixture-open");tr_write(fd,bytes,count);if(fsync(fd)||close(fd)||rename("/evidence/selected.toml.next","/evidence/selected.toml"))tr_die("fixture-publish");
 dprintf(logfd,"FIXTURE_READY seq=%u bytes=%zu hex=%s\n",++tr_fixture_seq,count,tr_command+1);
}
static int tr_control(char ch){
 if(tr_command_used||ch=='m'||ch=='f'){
  if(ch=='\n'){tr_command[tr_command_used]='\0';if(tr_command[0]=='m')tr_map();else tr_fixture();tr_command_used=0;}
  else{if(tr_command_used+1>=sizeof tr_command)tr_die("control-overflow");tr_command[tr_command_used++]=ch;}
  return 1;
 }
 return 0;
}
static void tr_fixture_boot(const char *scene,int control){
 if(strcmp(scene,"showcase-file")){return;}dprintf(logfd,"FIXTURE_WAIT target=/evidence/selected.toml\n");
 struct timespec begin,now;clock_gettime(CLOCK_MONOTONIC,&begin);
 while(!tr_fixture_seq){struct pollfd p={control,POLLIN,0};poll(&p,1,50);if(p.revents&POLLIN){char bytes[128];ssize_t n=read(control,bytes,sizeof bytes);for(ssize_t i=0;i<n;i++)if(!tr_control(bytes[i]))tr_die("fixture-boot-command");}
  clock_gettime(CLOCK_MONOTONIC,&now);if(now.tv_sec-begin.tv_sec>30)tr_die("fixture-boot-timeout");}
}
static void tr_finish(void){
 tr_drain();tr_termios("after");tr_cursor("after");if(tr_mapped){
  struct kbsentry string_readback={.kb_func=11};struct kbentry key_readback={.kb_table=0,.kb_index=88};
  if(ioctl(0,KDSKBSENT,&tr_original_string)||ioctl(0,KDSKBENT,&tr_original_key)||ioctl(0,KDGKBSENT,&string_readback)||ioctl(0,KDGKBENT,&key_readback))tr_die("keyboard-restore");
  if(memcmp(tr_original_string.kb_string,string_readback.kb_string,512)||key_readback.kb_value!=tr_original_key.kb_value)tr_die("keyboard-restore-readback");
  dprintf(logfd,"KEYBOARD_RESTORED original_string_equal=1 original_key_equal=1\n");
 }close(tr_fifo);close(tr_archive);
}
