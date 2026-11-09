# TASK-051 固定首片独立代码审核

受审版本：2794136e45aee98300f4b16456dfa6b605cfdf74。基线：868a3f6722e89e03232785469940a0e510a12103。轮次 FIRST-SLICE-051-R1，2026-11-09。预算：本轮最多60分钟有效工作/3次有效修复复核；本报告为初审，修复复核0次。

**spec-compliance: failed。code-quality: failed。** 已复现5个major、1个minor；必需契约失败必须统一交原实现者修复，不能凭既有正常测试通过关闭。findings状态open，待协调者确认/分派；并非声称所有产品能力已验收。

## 输入、角色及范围

执行型审核，契约与路线已冻结，不设计新功能。独立no-hardlinks clone，detached固定SHA；未读取作者隔离目录、报告、自评或过程推理，未编辑产品源码、正式测试或规范，未提交/推送/派代理。只写本目录review.md、findings.json作为交付；临时诊断在/tmp。已读AGENTS、BATTLE、ENGINEERING_TASK_DECOMPOSITION、整体提案/需求/架构/构造设计及绑定有限切片design/tasks，尤其TASK050/051与Global Constraints。OpenSpec权威仍为implement-linux-first-slice，不另建任务状态。读取并按角色使用requesting-code-review、verification-before-completion；using-superpowers明确豁免被派子代理；环境诊断使用cloud-environment-runtime。不得把审核技能的调度模板解释成审核者再派子代理。

审核范围：src/frame/component/application/unicode、native C/build.sh、build.cj、cjpm.toml、minimal、tests/contract及integration断言和设施、CI→check-product.sh slice→run-slice.sh all、bundle边界。第三方原始许可不重审或改写，不把许可声明矛盾或原文空白当阻塞。响应式、编辑/主题/覆盖层/M2和其他平台是后续需求，不记本片缺陷。

工程DQ按本片输入检查：L3 048–053的角色/依赖/交付/验收归属在tasks.md可定位；本审核目标、边界、依赖、输入固定，DQ05/09以公开API及独立执行/验收任务闭合；未把计划中的验收当作已通过。全项目DQ和未来里程碑不属于本报告的完成声明。纯新增实现无旧产品退役对象。

## 结论及已检查路径

- 构造/渲染结构清晰：公开Text/Row/Column→render→Frame→差分→Linux桥；示例无业务ANSI、全屏坐标或flush特判。Component返回值在构造时attach，常规返回Component的自定义函数沿同一收集路径。parents栈由Mutex保护，body退出使用finally弹栈；未发现无保护构造stack。
- 分段只用unicode，宽度只用unicodewidth；Frame覆盖续格会清理旧整簇，右/左裁剪不写半簇。style按值比较，继承按逐属性子显式优先；低层与高层使用同一Frame。文本完整校验在裁剪前，拒绝C0/C1/ESC，LF与CRLF例外。
- M1每轮生成完整Frame，逐行差分包括style/彩色空白/continuation；无变化不write，resize清baseline。writeScreen失败抛出，baseline赋值在成功写后；失败走finally，没有在失同步后继续下一帧。本轮未发现提前提交baseline或失败后盲重绘。
- C ABI为int32/void，平台结构仅C侧；字符串转换为字节逐一拷入C自有buffer，没有Cangjie裸指针跨生命周期。增长乘法有wrap检查，realloc失败不覆盖旧指针。nonTTY检查先于模式或屏幕写。
- 重大质量缺陷是会话所有权与输入状态机：C会话全局及Cangjie解析全局没有原子独占保障；输入分支先后顺序使取消和UTF8跨块丢失，且漏掉SOS字符串类别。
- build hook使用官方固定包/UCD SHA，缓存位于本包，随包带源C和构建脚本；不改共享cache源码。构建依赖和可选离线输入有说明。CJPM include/exclude排除.a/.o/构建缓存；CI slice确实调用独立测试入口。release检查仍要求后续composition/benchmark，因此本片不宣称完整发行验收。

## 验证证据与限制

环境：Linux x86_64；cjc/cjpm 1.2.0（实际--version）。SDK=/workspace/work/validation/sdk/cangjie/envsetup.sh。只读官方依赖cache=/workspace/work/validation/replay-dependencies/cache；UCD=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip。环境registry代理http://127.0.0.1:18972仅转发官方原字节，不是产品依赖。

独立副本执行普通cjpm build，设置CJTUI_UCD_ARCHIVE后退出0，输出“cjpm build success”。随后临时公开消费者使用本次构建的cjtui及依赖档案链接；未给产品修补源码/测试。限定诊断如下。未代替TASK052跑整套native/contract/PTY测试，也未签用户验收。

### E1

附录A公开消费者和真实PTY刺激，命令source SDK后node /tmp/cjtui-review-input.mjs，退出0。观察：

```text
{"mode":"osc-ctrl-c","exitedAfterInput":false,"events":[]}
restored=true
{"mode":"utf8-split","exitedAfterInput":false,"events":[]}
restored=true
{"mode":"sos-text","exitedAfterInput":false,"events":["KEY=text:s","KEY=text:e","KEY=text:c","KEY=text:r","KEY=text:e","KEY=text:t"]}
restored=true
{"mode":"utf8-ctrl-c","exitedAfterInput":false,"events":[]}
restored=true
```

restored=true仅证明诊断最后另发SIGTERM后的清理；绝不代表Ctrl-C场景通过。消费者println只用于诊断可观察事件，非产品例程，也未修改产品输出路径。

### E2

附录B链接固定原C，使用pthread及syscall包装固定交错；gcc退出0，诊断退出0，输出：

`open1=0 open2=0 close=0 original_lflag=11 restored_lflag=0`

这是会话原实现的确定反例，包装的是系统调用环境，并非重写会话逻辑。证明静态全局所有权缺陷；未宣称已在真实TTY随机压力运行中复现。

### E3

附录C链接固定原C，在tcsetattr期间真实raise(SIGTERM)，其余TTY外部环境模拟，gcc/诊断均退出0：

`open=0 read_after_SIGTERM=-1 close=0 (expected read=-2)`

### E4

附录D公开API消费者，编译与运行退出0：

```text
put x=9223372036854775807: OverflowException: add
put x=-9223372036854775808: clipped
resource product rejected
large cursor exact=true
```

Frame(Int64.Max,2)准确抛IllegalArgumentException，非截断。Frame(1,65536).toAnsi包含ESC[65536;1H；产品使用ansies.core.CUP(Array<String>)，其依赖实现直接编码字符串，并未走UInt16 Cursor API，所以不得误报UInt16窄化。

### E5

附录E固定原C写循环注入：先写2字节后EIO，及首次EINTR再每次最多2字节，gcc/诊断均退出0：

```text
partial_then_EIO: result=-1 calls=2
EINTR_then_partial_success: result=0 calls=4
```

已验证C写循环返回与重试。Application失败后的baseline/finally结论来自固定源码路径检查；**尚未进行完整Application写故障下的真实TTY parser同步/termios证据**，不把本C注入夸称整栈故障验收。

产品/测试/构建代码git diff --check通过；整体diff的空白警告仅来自原样保存的第三方材料，依授权不作为缺陷。gcc -std=c11 -Wall -Wextra -Wconversion -fsyntax-only完成，仅掩码取反的sign-conversion提示，不据此制造语义缺陷。最终git diff为空；普通构建生成cjpm.lock已删除，源码保持固定SHA。

## 发现摘要

- **SLICE-051-001 / major** — Ctrl-C在控制串丢弃状态或UTF-8补字节期间被消费，应用不会默认退出。 位置：src/application.cj:20–29,35–43,75–80。正式反例与契约见findings.json。
- **SLICE-051-002 / major** — 有效UTF-8输入在字节间隔超过100ms时被静默丢弃，解码状态没有跨读超时保存。 位置：src/application.cj:68–81。正式反例与契约见findings.json。
- **SLICE-051-003 / major** — SOS控制串ESC X未进入有界丢弃状态，其payload被伪造为普通文本事件。 位置：src/application.cj:32–46。正式反例与契约见findings.json。
- **SLICE-051-004 / major** — 会话active检查和占有不是原子的；并发Application.run可同时启动，覆盖唯一saved/old_signal快照，关闭成功却留下raw模式；共享buffer及解析状态也无独立所有权。 位置：native/cjtui_terminal.c:10–20,21–35,37–44；src/application.cj:18–19,99–102。正式反例与契约见findings.json。
- **SLICE-051-005 / major** — 安装信号处理器后才把interrupted清零，启动期间已接收的SIGINT/SIGTERM被抹掉，run继续工作。 位置：native/cjtui_terminal.c:23–35。正式反例与契约见findings.json。
- **SLICE-051-006 / minor** — 完全位于右侧边界外的Int64.Max坐标仍递增，产生OverflowException，而不是无害裁剪。 位置：src/frame.cj:88–103。正式反例与契约见findings.json。

下一步：由协调者将本轮完整列表交原实现作者统一修复，独立测试作者维护正式回归；审核者仅对固定修复版本复核。验收者仍需独立执行正常、失败与公开消费者证据，不可用本报告替代TASK052/053。

## 可重现诊断附录

以下文件均为临时审核设施，未进入源码或测试树。固定repo作为cwd，先source上述SDK，cjpm build成功。编译附录A/D消费者统一命令（将input换为frame用于D）：

```sh
cjc /tmp/cjtui-review-input.cj --import-path target/release/cjtui --import-path target/release/ansies --import-path target/release/unicode --import-path target/release/unicodewidth --import-path target/release/bitarray -L target/release/cjtui -L target/release/ansies -L target/release/unicode -L target/release/unicodewidth -L target/release/bitarray -L native -lcjtui -lansies.core -lansies.api -lansies.utils -lunicode -lunicode.types -lunicode.constants -lunicode.utf -lunicodewidth -lunicodewidth.gen -lbitarray -lunicodedata -lcjtui_terminal -o /tmp/cjtui-review-input
```

### A 消费者

文件 /tmp/cjtui-review-input.cj

```text
import cjtui.*
main(): Int64 {
 let app = Application(Text("ready"))
 app.onKey { event =>
   println("KEY=" + event.code + ":" + event.text)
   if(event.text == "q") { app.stop() }
 }.run()
 return 0
}
```

### A PTY刺激

文件 /tmp/cjtui-review-input.mjs

```js
import {spawn} from 'node:child_process';
import {mkdtemp,readFile,rm} from 'node:fs/promises';
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
for (const mode of ['osc-ctrl-c','utf8-split','sos-text','utf8-ctrl-c']) {
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
 await sleep(350);
 console.log(JSON.stringify({mode,exitedAfterInput:ended,events:output.match(/KEY=[^\r\n]*/g)||[]}));
 if(!ended) process.kill(pid,'SIGTERM');
 for(let i=0;i<100&&!ended;i++) await sleep(20);
 if(!ended) throw Error('cleanup timeout');
 console.log('restored='+((await readFile(dir+'/before','utf8'))===(await readFile(dir+'/after','utf8'))));
 p.stdin.destroy(); await rm(dir,{recursive:true});
}
```

```sh
node /tmp/cjtui-review-input.mjs
```

### B 并发会话

文件 /tmp/cjtui-review-race.c

```c
#define _POSIX_C_SOURCE 200809L
#include <pthread.h>
#include <termios.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
extern int cjt_open(void), cjt_close(void);
static pthread_barrier_t both;
static pthread_mutex_t guard=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t started=PTHREAD_COND_INITIALIZER;
static _Thread_local int role;
static int first_opened;
static struct termios device;
int __wrap_isatty(int fd) { if(fd==STDOUT_FILENO) pthread_barrier_wait(&both); return 1; }
int __wrap_tcgetattr(int fd, struct termios *value) {
 (void)fd; pthread_mutex_lock(&guard);
 while(role==2 && !first_opened) pthread_cond_wait(&started,&guard);
 *value=device; pthread_mutex_unlock(&guard); return 0;
}
int __wrap_tcsetattr(int fd,int mode,const struct termios *value) {
 (void)fd; (void)mode; pthread_mutex_lock(&guard); device=*value; pthread_mutex_unlock(&guard); return 0;
}
int __wrap_sigaction(int sig,const struct sigaction *action,struct sigaction *old) {
 (void)sig; (void)action; if(old) memset(old,0,sizeof(*old)); return 0;
}
static void *run(void *arg) {
 role=(int)(long)arg; int result=cjt_open();
 if(role==1) { pthread_mutex_lock(&guard); first_opened=1; pthread_cond_broadcast(&started); pthread_mutex_unlock(&guard); }
 return (void *)(long)result;
}
int main(void) {
 device.c_lflag=ECHO|ICANON|ISIG; tcflag_t original=device.c_lflag;
 pthread_barrier_init(&both,0,2); pthread_t a,b; void *ra,*rb;
 pthread_create(&a,0,run,(void *)1); pthread_create(&b,0,run,(void *)2);
 pthread_join(a,&ra); pthread_join(b,&rb); int closed=cjt_close();
 printf("open1=%ld open2=%ld close=%d original_lflag=%lu restored_lflag=%lu\n",(long)ra,(long)rb,closed,(unsigned long)original,(unsigned long)device.c_lflag);
 return 0;
}
```

```sh
gcc -std=c11 -Wall -Wextra -pthread native/cjtui_terminal.c /tmp/cjtui-review-race.c -Wl,--wrap=isatty -Wl,--wrap=tcgetattr -Wl,--wrap=tcsetattr -Wl,--wrap=sigaction -o /tmp/cjtui-review-race && /tmp/cjtui-review-race
```

### C 启动信号

文件 /tmp/cjtui-review-signal.c

```c
#define _POSIX_C_SOURCE 200809L
#include <signal.h>
#include <termios.h>
#include <poll.h>
#include <stdio.h>
#include <string.h>
extern int cjt_open(void),cjt_close(void),cjt_read(int);
static int applies;
int __wrap_isatty(int fd) {(void)fd;return 1;}
int __wrap_tcgetattr(int fd,struct termios *v) {(void)fd;memset(v,0,sizeof(*v));return 0;}
int __wrap_tcsetattr(int fd,int mode,const struct termios *v) {
 (void)fd;(void)mode;(void)v;if(++applies==1) raise(SIGTERM);return 0;
}
int __wrap_poll(struct pollfd *fds,nfds_t n,int timeout) {(void)fds;(void)n;(void)timeout;return 0;}
int main(void) {int opened=cjt_open();int read=cjt_read(0);int closed=cjt_close();printf("open=%d read_after_SIGTERM=%d close=%d (expected read=-2)\n",opened,read,closed);return 0;}
```

```sh
gcc -std=c11 -Wall -Wextra native/cjtui_terminal.c /tmp/cjtui-review-signal.c -Wl,--wrap=isatty -Wl,--wrap=tcgetattr -Wl,--wrap=tcsetattr -Wl,--wrap=poll -o /tmp/cjtui-review-signal && /tmp/cjtui-review-signal
```

### D 坐标与资源

文件 /tmp/cjtui-review-frame.cj

```text
import cjtui.*
main(): Int64 {
 for (value in [Int64.Max, Int64.Min]) {
  try { Frame(1,1).put(value,0,"a"); println("put x=${value}: clipped") }
  catch (e: Exception) {println("put x=${value}: " + e.toString())}
 }
 try {Frame(Int64.Max,2); println("overflow accepted")}
 catch(e: IllegalArgumentException) {println("resource product rejected")}
 let snapshot=Frame(1,65536).toAnsi()
 println("large cursor exact=" + snapshot.contains("\u{1b}[65536;1H").toString())
 return 0
}
```

```sh
/tmp/cjtui-review-frame
```

### E 写故障

文件 /tmp/cjtui-review-write.c

```c
#define _POSIX_C_SOURCE 200809L
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
extern void cjt_buffer_clear(void);
extern int cjt_buffer_add(int),cjt_buffer_write(void);
static int calls,mode;
ssize_t __wrap_write(int fd,const void *buf,size_t n) {
 (void)fd;(void)buf;calls++;
 if(mode==0 && calls==1) return 2;
 if(mode==0) {errno=EIO;return -1;}
 if(calls==1) {errno=EINTR;return -1;}
 return n>2?2:(ssize_t)n;
}
int main(void) {
 cjt_buffer_clear(); for(int i=0;i<5;i++) cjt_buffer_add('x');
 int result=cjt_buffer_write();printf("partial_then_EIO: result=%d calls=%d\n",result,calls);
 mode=1;calls=0;result=cjt_buffer_write();printf("EINTR_then_partial_success: result=%d calls=%d\n",result,calls);
 return 0;
}
```

```sh
gcc -std=c11 -Wall -Wextra native/cjtui_terminal.c /tmp/cjtui-review-write.c -Wl,--wrap=write -o /tmp/cjtui-review-write && /tmp/cjtui-review-write
```
