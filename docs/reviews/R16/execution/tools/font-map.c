#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>
static void run(void){
 struct stat st;fstat(0,&st);struct vt_stat vs={0};unsigned char kt=0;int mode=-1;errno=0;int vr=ioctl(0,VT_GETSTATE,&vs);int ve=errno;errno=0;int kr=ioctl(0,KDGKBTYPE,&kt);int ke=errno;errno=0;int mr=ioctl(0,KDGETMODE,&mode);int me=errno;
 printf("IDENT uid=%u euid=%u gid=%u tty=%s owner=%u group=%u mode=%o VT_GETSTATE=%d errno=%d active=%u KDGKBTYPE=%d errno=%d type=%u KDGETMODE=%d errno=%d mode=%d\n",getuid(),geteuid(),getgid(),ttyname(0),st.st_uid,st.st_gid,st.st_mode&0777,vr,ve,vs.v_active,kr,ke,kt,mr,me,mode);
 struct unimapdesc d={0,NULL};errno=0;int rc=ioctl(0,GIO_UNIMAP,&d);int er=errno;printf("GIO_UNIMAP sizing capacity=0 rc=%d errno=%d name=%s returned_count=%u\n",rc,er,strerror(er),d.entry_ct);
 struct unipair *pairs=calloc(65535,sizeof *pairs);d.entry_ct=65535;d.entries=pairs;errno=0;rc=ioctl(0,GIO_UNIMAP,&d);er=errno;printf("GIO_UNIMAP table capacity=65535 rc=%d errno=%d name=%s returned_count=%u sizeof_pair=%zu BMP_only=1\n",rc,er,strerror(er),d.entry_ct,sizeof *pairs);
 if(rc==0){
  char path[80];snprintf(path,sizeof path,"/evidence/unimap-%u.bin",getuid());int fd=open(path,O_WRONLY|O_CREAT|O_TRUNC,0666);ssize_t n=fd<0?-1:write(fd,pairs,(size_t)d.entry_ct*sizeof *pairs);if(fd>=0)close(fd);printf("TABLE_BINARY path=%s bytes=%zd\n",path,n);
  unsigned samples[]={0x41,0x65,0x2500,0x2502,0x250c,0x256d,0xe9,0x301,0x4e2d,0x6587,0x25a0,0xfffd,0x1f600,0x1f469,0x1f4bb,0x200d};
  for(unsigned s=0;s<sizeof samples/sizeof samples[0];s++){unsigned cp=samples[s];int count=0;if(cp>0xffff){printf("SAMPLE U+%06X result=unrepresentable_in_GIO_UNIMAP_u16_ABI\n",cp);continue;}for(unsigned i=0;i<d.entry_ct;i++)if(pairs[i].unicode==cp){printf("SAMPLE U+%04X fontpos=%u\n",cp,pairs[i].fontpos);count++;}if(!count)printf("SAMPLE U+%04X result=absent\n",cp);}
  for(unsigned i=0;i<d.entry_ct;i++)printf("UNIMAP_ENTRY unicode=%04x fontpos=%04x\n",pairs[i].unicode,pairs[i].fontpos);
 }free(pairs);fflush(stdout);
}
int main(void){run();if(setgid(1000)||setuid(1000)){perror("setuid");return 2;}run();return 0;}
