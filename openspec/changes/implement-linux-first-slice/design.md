# Design

## Context

见proposal。R5/R7已证明原生尾随Lambda和三依赖路线，仓库仍无产品源码。本切片落实既有架构，不重新讨论用户已确认的目标；公开API为0.0.0首个受检切片。

## Goals / Non-Goals

Goals：独立消费者正常cjpm build/run，声明式Text/Row/Column可在Linux实际尺寸全屏呈现，Unicode安全网格可测试，键盘退出及resize可用，ANSI/plain快照可消费。
Non-Goals：本切片不完成编辑组件、主题配置、覆盖层、响应式或M2；这些保留既有必需任务，不能用本切片通过替代。

## Decisions

D-019（工程决定）：先交付同一字符网格/样式路径的低层与高层切片，不另建演示渲染器。替代为先只建底层库不能实际运行应用；直接实现全组件则反馈过晚。首片保留后续扩展边界，禁止示例特判。

D-020：正式build.cj调用产品随附的原生构建支持，cjtui自身[ffi.c]持有Unicode和Linux会话库。复用外部包生成器/C/ASM，不改共享CJPM缓存；固定包/UCD摘要、失败明确报错。可用已校验离线UCD路径，但路径仅为构建输入，最终应用不能依赖开发目录。正式构建工具使用仓颉和C/现有Linux工具，不引入Node/Python运行依赖。生成物位于可再生的本包构建缓存；原生源及必要构建入口随cjp交付。

D-021：termios/ioctl/poll/read/write/sigaction由小型Linux C桥封装，避免仓颉复制平台结构ABI。业务/组件不调用C或发ANSI。原终端模式保存成功后才能修改；失败/取消回到统一finally清理；SIGKILL/设备永久故障不承诺恢复。TTY检查失败时不发屏幕控制码。

D-022：构造上下文必须串行/按线程隔离并在异常时清理，不能照抄探针的无保护全局stack。节点在Application内持有，尺寸重排不重建业务回调。此片仅静态构造，后续动态身份/状态任务仍必需。

## Public slice contract

所有公开接口由`import cjtui.*`使用；具体仓颉源码以真实SDK编译为准，签名变化必须先同步独立测试作者。

- `public func graphemeClusters(value: String): Array<String>`与`public func displayWidth(value: String, ambiguousWide!: Bool = false): Int64`为正式字符薄适配API；空输入返回空数组/0，宽度只调用unicodewidth。原生构建任务先交付该可独立消费的最小库，后续Frame复用它们。
- `public enum Color { Default | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White }`。
- `public struct Style`，`init(foreground!: Color = Color.Default, background!: Color = Color.Default, bold!: Bool = false)`，同名只读字段。样式相等按值。
- `public struct Cell`只读`grapheme: String`、`width: Int64`、`continuation: Bool`、`style: Style`；空白为带样式空格/width1，宽字符续格width0且continuation=true。
- `public class Frame`：`init(width: Int64, height: Int64, ambiguousWide!: Bool = false)`；只读width/height；`put(x: Int64, y: Int64, text: String, style!: Style = Style()): Unit`；`cellAt(x: Int64, y: Int64): Cell`；`toPlainText(): String`；`toAnsi(): String`。
- 非法负尺寸/越界cellAt报IllegalArgumentException，零尺寸合法。put越界裁剪；不能留下半个宽簇或孤立续格，覆盖续格清理旧整簇。宽度仅unicodewidth，分段仅unicode；空输入0簇，独立零宽簇忽略。LF换行到原x下一行；CRLF等同LF；其余C0/C1及ESC拒绝，不能从文字注入设备控制。
- plain每行保留完整列的空格（续格不重复输出），行间LF，末尾无额外LF，无ESC；ANSI是完整独立画面，以SGR reset和绝对定位起始，逐行绝对定位，结束reset，不通过换行触发终端滚屏。颜色由ansies编码，不用第二套编码器。空帧ANSI为空。
- `public class Component`支持链`foreground(Color): Component`、`background(Color): Component`、`bold(): Component`；`public func Text(value: String): Component`、`Column(body: () -> Unit): Component`、`Row(body: () -> Unit): Component`，块内if/for/用户函数均正常收集；单独Text为合法根。此片暂不提供padding/border/flex参数，后续按既有任务实现。
- `public func render(root: Component, width: Int64, height: Int64): Frame`；Column依内容高度纵向排列，Row依内容宽度横向排列，Text含LF；祖先裁剪、actual size为最终边界。默认样式可继承文字颜色/粗体，子显式属性优先。不自动美化文本。
- `public class KeyEvent`只读`code: String`、`text: String`；本片code为text/enter/escape/backspace/up/down/left/right/interrupt，text仅文本事件有Unicode文本。未知控制序列有界忽略，不执行或伪造文本；不能把UTF8字节当多个字符。
- `public class Application`：`init(root: Component)`、`onKey(handler: (KeyEvent) -> Unit): Application`、`run(): Unit`、`stop(): Unit`；run使用实际TTY尺寸，尺寸变化自动重排刷新，默认Ctrl-C退出，其他键交回调；回调异常清理后向调用方报告。stop由UI回调调用。默认不设置标题/剪贴板/图标。
- M1完整目标帧+缓冲差分：首帧完整、无变化不发屏幕更新；缩放使基线失效。设备写完整后提交基线；失败不清脏、不复用已失效基线，无法安全重同步时停止并报错。写端禁止直接由组件使用。

示例源必须真实编译，形态为`let app = Application(Column { Text("cjtui").foreground(Color.Cyan); Row { Text("中文 "); Text("👩‍💻") } })`，用`app.onKey { event => if (event.text == "q") { app.stop() } }.run()`运行；普通用户不传全屏坐标/ANSI/flush。示例文档必须写明q退出、Ctrl-C取消、Linux ANSI TTY及当前能力边界。

## Risks / Trade-offs

原生构建下载失败→固定摘要/离线已校验输入/明确诊断；不能退回探针绝对路径。主库API不能链接→独立消费者验证。Unicode边界→独立字符/覆盖反例及官方分段证据复用。会话退出/resize→独立PTY测试记录termios；PTY仅测试设施。声明上下文异常→测试异常后重建树不串入旧树。许可信息→保留真实归属，按用户最新要求不将声明矛盾设为项目阻塞，不代改上游声明。

## Migration Plan

新增代码，无旧产品路径需退役；历史R5/R7保持原始结论，当前许可处理以最新用户指令优先。首先测试契约，再实现并审核，独立执行后验收，完成后直接推送main；不上传发行包。
