# TASK-051 第1次修复复核

**spec-compliance: failed。code-quality: failed。** 原SLICE-051-001/002/004/005/006 verified；003简单反例修复，但同一控制串过滤契约仍有可复现残余失败，保持confirmed，不可关闭。

原受审版本2794136e45aee98300f4b16456dfa6b605cfdf74；产品修复49edfc5f971788ca05f24989462245cc1f2a79fc。固定测试增强版本5f9694bc31c7dc8aca65c617484ad8699db2f4d5及32010ce47c71d4aadebd9c25288721c84e2f18b3；git diff证明后两者对49edfc5的src/native/build.cj/cjpm.toml没有变更。最终独立副本checkout32010ce。修复复核预算已用1/3；本报告保留初审review.md/findings.json原样作为历史，以下是最新状态。

仅查固定差异、绑定design契约与独立测试源码，未读取作者报告/自测结论。没有改产品、正式测试或规范，没有提交推送。依旧采用requesting-code-review/verification-before-completion角色原则；不重跑无关全量，未代替TASK052/053。

## 原发现逐项裁决

| Finding | 状态 | 新证据及源码 |
|---|---|---|
| 001 Ctrl-C丢失 | verified | InputDecoder.feed第一步处理0x03；原未结束OSC及E4 03真实PTY反例均自动退出、termios相同。 |
| 002 慢UTF8丢字 | verified | remaining/code/minimum跨poll保留；E4与B8 AD间隔160ms后只产生KEY=text:中。 |
| 003 SOS伪造文本 | confirmed | ESC X secret ESC\简单反例已修；下述SOS/ESC/UTF8组合仍泄漏secret。 |
| 004 会话所有权 | verified | C原子CAS在任何快照/设备修改前占有；失败回滚占有，清理完成后release。第二open拒绝、首owner原模式完整恢复，并能再次open/close。解析器改为run局部实例，无共享解码状态。 |
| 005 启动信号 | verified | interrupted初始化移到安装信号处理器前；tcsetattr阶段raise(SIGTERM)后read=-2，关闭恢复原模式。 |
| 006 极值坐标 | verified | cx/cy递增饱和处理；原Int64.Max/Min短文本均裁剪无异常。资源乘法拒绝及65536行CUP精确输出继续通过。 |

003的残余属于当前fixdiff的输入解析变更，未扩大到未来响应式、完整编辑、主题或M2，也不涉及许可。

## 003残余失败的可复现证据

revision=49edfc5f971788ca05f24989462245cc1f2a79fc；等价产品源32010ce47c71d4aadebd9c25288721c84e2f18b3。target=src/application.cj:33–52，尤其49–52。contract_ref=design.md Public slice contract“未知控制序列有界忽略，不执行或伪造文本”；AGENTS.md §9跨块解析和畸形/未知输入确定处理。severity=major，status=confirmed（原003修复未闭合）。

最小刺激为SOS中的ESC非ST前缀再接一个UTF8字符：

- bytes: 1b 58 1b e4 b8 9c 73 65 63 72 65 74 1b 5c。
- 字符表示：ESC X ESC 东secret ESC \。东=U+4E1C，UTF8=E4 B8 9C。
- expected：控制串payload被忽略，无业务text回调；不能把Unicode续字节当作C1结束符。
- observed：产生text:s、text:e、text:c、text:r、text:e、text:t。

源码链：state3看到ESC进入state4；state4遇E4既非ST也非ESC，切回state3但丢掉该UTF8 lead byte；B8没有建立续字节计数，9C随后被state3误认作独立C1 ST。后续secret进入normal并分发业务回调。作为对照，同一SOS去掉payload里的ESC，即ESC X 东secret ESC\，不会产生事件；这将错误定位到state4回退时没有保存当前字节的UTF8状态。

用初审附录A的同一公开API诊断程序、重新链接本次固定构建库，在真实PTY执行附录F，输出如下（过程退出0；诊断最后SIGTERM仅清理，不是成功证明）：

```text
{"mode":"basic","exitedAfterInput":false,"events":["KEY=text:a","KEY=enter:","KEY=backspace:","KEY=up:","KEY=down:","KEY=right:","KEY=left:"]}
restored=true
{"mode":"sos-unicode","exitedAfterInput":false,"events":[]}
restored=true
{"mode":"sos-esc-unicode","exitedAfterInput":false,"events":["KEY=text:s","KEY=text:e","KEY=text:c","KEY=text:r","KEY=text:e","KEY=text:t"]}
restored=true
```

## 已执行的复验证据

环境沿用初审：SDK1.2.0，固定官方cache/UCD，独立clone。source SDK并设置CJTUI_UCD_ARCHIVE运行cjpm build，退出0、输出cjpm build success。随后按review.md附录编译命令重新构建临时公开消费者（输入/Frame）到/tmp，再运行原A/D反例；不借用作者二进制。

```text
{"mode":"osc-ctrl-c","exitedAfterInput":true,"events":[]}
restored=true
{"mode":"utf8-split","exitedAfterInput":false,"events":["KEY=text:中"]}
restored=true
{"mode":"sos-text","exitedAfterInput":false,"events":[]}
restored=true
{"mode":"utf8-ctrl-c","exitedAfterInput":true,"events":[]}
restored=true
put x=9223372036854775807: clipped
put x=-9223372036854775808: clipped
resource product rejected
large cursor exact=true
```

原并发barrier不用于修复版，避免因正确第二owner提前拒绝导致夹具死锁；附录G采用首owner停在getter→第二open返回→放行首owner的交错。gcc和timeout 5运行退出0：

```text
first=0 second=-1 close=0 original_lflag=11 restored_lflag=11
reopen=0 reclose=0
open=0 read_after_SIGTERM=-2 close=0 (expected read=-2)
partial_then_EIO: result=-1 calls=2
EINTR_then_partial_success: result=0 calls=4
```

后3行分别来自初审C/E固定原C诊断重新编译；C的setup信号条件不变，E确认修复未破坏写循环已有partial/error/EINTR语义。Application baseline写成功后提交及finally路径未被这轮差异改变。仍未以C级故障证据冒充完整Application写失败下真实TTY端到端验收。

独立阅读5f9694b测试差异：新增慢UTF8/SOS公共事件断言、坐标极值消费者；原正常/失败断言未削弱；run-slice从cjpm run改为cjpm build后直执二进制，set -e传播失败，方向正确。未在本轮代替测试执行者运行全部正式公开套件。

独立阅读32010ce的native-session源码后实际执行./tests/native-session/run.sh，退出0：

```text
owner: open1=0 open2=-1 successes=1 close=0 restored=1 original_lflag=32779 restored_lflag=32779
PASS owner
setup-signal: open=0 read_after_SIGTERM=-2 close=0 restored=1
PASS setup-signal
```

正式测试确实链接原C、包装外部syscall，并用真实raise；完整termios快照比较及返回值断言均保留。owner夹具可接受早期拒绝/内部串行，不再依赖第二线程一定到达被拒绝前的内部阶段。git diff --check在修复/测试差异上通过。

## 下一步

只需原作者继续修复003的字符串回退路径，独立测试作者沉淀上述字节反例。其他5项已有通过证据；下轮仅复核受影响解析路径及新反例，不应无依据重跑全量或重开已解决契约。

## 附录F：真实PTY附加刺激

文件/tmp/cjtui-review-input-extra.mjs；命令source SDK后node该文件，使用重编译的/tmp/cjtui-review-input。

```js
import {spawn} from 'node:child_process';
import {mkdtemp,readFile,rm} from 'node:fs/promises';
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
for (const mode of ['basic','sos-unicode','sos-esc-unicode']) {
 const dir=await mkdtemp('/tmp/cjtui-input-');
 const command=`stty rows 2 cols 12; stty -g > '${dir}/before'; /tmp/cjtui-review-input < /dev/tty & p=$!; echo $p > '${dir}/pid'; wait $p; stty -g > '${dir}/after'`;
 const p=spawn('script',['-q','-e','-f','-c',command,'/dev/null'],{stdio:['pipe','pipe','pipe']});
 let output='',ended=false; p.stdout.on('data',b=>output+=b.toString()); p.on('exit',()=>ended=true);
 for(let i=0;i<100&&!output.includes('ready');i++) await sleep(20);
 if(!output.includes('ready')) throw Error('startup failed: '+output);
 const pid=Number(await readFile(dir+'/pid','utf8'));
 if(mode==='osc-ctrl-c') {p.stdin.write(Buffer.from([27,93])); await sleep(150); p.stdin.write(Buffer.from([3]));}
 if(mode==='utf8-split') {p.stdin.write(Buffer.from([0xe4])); await sleep(160); p.stdin.write(Buffer.from([0xb8,0xad]));}
 if(mode==='sos-text') p.stdin.write(Buffer.from('\x1bXsecret\x1b\\'));
 if(mode==='utf8-ctrl-c') p.stdin.write(Buffer.from([0xe4,3]));
 if(mode==='basic')p.stdin.write(Buffer.from('a\r\x7f\x1b[A\x1b[B\x1b[C\x1b[D'));
 if(mode==='sos-unicode')p.stdin.write(Buffer.from('\x1bX东secret\x1b\\'));
 if(mode==='sos-esc-unicode')p.stdin.write(Buffer.from('\x1bX\x1b东secret\x1b\\'));
 await sleep(350);
 console.log(JSON.stringify({mode,exitedAfterInput:ended,events:output.match(/KEY=[^\r\n]*/g)||[]}));
 if(!ended) process.kill(pid,'SIGTERM');
 for(let i=0;i<100&&!ended;i++) await sleep(20);
 if(!ended) throw Error('cleanup timeout');
 console.log('restored='+((await readFile(dir+'/before','utf8'))===(await readFile(dir+'/after','utf8'))));
 p.stdin.destroy(); await rm(dir,{recursive:true});
}
```

## 附录G：不会因正确早拒绝而卡住的owner夹具

```c
#define _POSIX_C_SOURCE 200809L
#include <pthread.h>
#include <termios.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
extern int cjt_open(void),cjt_close(void);
static pthread_mutex_t lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t cond=PTHREAD_COND_INITIALIZER;
static int entered,release;
static struct termios device;
int __wrap_isatty(int fd) {(void)fd;return 1;}
int __wrap_tcgetattr(int fd,struct termios *value) {
 (void)fd;pthread_mutex_lock(&lock);entered=1;pthread_cond_broadcast(&cond);
 while(!release)pthread_cond_wait(&cond,&lock);
 *value=device;pthread_mutex_unlock(&lock);return 0;
}
int __wrap_tcsetattr(int fd,int mode,const struct termios *value) {(void)fd;(void)mode;device=*value;return 0;}
int __wrap_sigaction(int sig,const struct sigaction *action,struct sigaction *old) {(void)sig;(void)action;if(old)memset(old,0,sizeof(*old));return 0;}
static void *run(void *arg) {(void)arg;return (void *)(long)cjt_open();}
int main(void) {
 device.c_lflag=ECHO|ICANON|ISIG;tcflag_t original=device.c_lflag;
 pthread_t first;pthread_create(&first,0,run,0);
 pthread_mutex_lock(&lock);while(!entered)pthread_cond_wait(&cond,&lock);pthread_mutex_unlock(&lock);
 int second=cjt_open();
 pthread_mutex_lock(&lock);release=1;pthread_cond_broadcast(&cond);pthread_mutex_unlock(&lock);
 void *result;pthread_join(first,&result);int closed=cjt_close();
 printf("first=%ld second=%d close=%d original_lflag=%lu restored_lflag=%lu\n",(long)result,second,closed,(unsigned long)original,(unsigned long)device.c_lflag);
 assert((long)result==0 && second==-1 && closed==0 && device.c_lflag==original);
 int reopened=cjt_open(),reclosed=cjt_close();printf("reopen=%d reclose=%d\n",reopened,reclosed);assert(reopened==0 && reclosed==0);
 return 0;
}
```

```sh
gcc -std=c11 -Wall -Wextra -pthread native/cjtui_terminal.c /tmp/cjtui-review-owner-fixed.c -Wl,--wrap=isatty -Wl,--wrap=tcgetattr -Wl,--wrap=tcsetattr -Wl,--wrap=sigaction -o /tmp/cjtui-review-owner-fixed
timeout 5 /tmp/cjtui-review-owner-fixed
```
