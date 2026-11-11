#define _GNU_SOURCE
#include <linux/seccomp.h>
#include <linux/filter.h>
#include <sys/prctl.h>
#include <sys/syscall.h>
#include <stddef.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
int main(void){
 struct sock_filter code[]={BPF_STMT(BPF_LD|BPF_W|BPF_ABS,offsetof(struct seccomp_data,nr)),BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K,__NR_ioctl,0,3),BPF_STMT(BPF_LD|BPF_W|BPF_ABS,offsetof(struct seccomp_data,args[1])),BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K,0x4B66,0,1),BPF_STMT(BPF_RET|BPF_K,SECCOMP_RET_ERRNO|EACCES),BPF_STMT(BPF_RET|BPF_K,SECCOMP_RET_ALLOW)};
 struct sock_fprog p={sizeof(code)/sizeof(code[0]),code};
 if(prctl(PR_SET_NO_NEW_PRIVS,1,0,0,0)||prctl(PR_SET_SECCOMP,SECCOMP_MODE_FILTER,&p)){perror("controlled-map-policy");return 125;}
 char *target=getenv("VT_EXEC_TARGET");if(!target)return 124;execl(target,target,(char*)0);perror("exec");return 127;
}
