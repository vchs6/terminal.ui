# TASK-062 独立代码审核

## 结论

- **Spec verdict：passed**
- **Quality verdict：passed**
- **AC062：passed**（仅限颜色与样式输出切片；不是完整产品或发布结论）

受审技术补丁为 /workspace/work/terminal.ui/.superpowers/sdd/color-style/technical-review.diff，
对应固定受审版本 187e126fc20b13a4f5526a28a9189cc0acb4037f，基线为
96bdb9b7c5b1f58c5ec223a0475be3d86cfae660。补丁反向检查通过；它是该提交中
23 个技术文件、1070 行新增/58 行删除的可应用子集。提交中审核范围以外的
OpenSpec 过程和依赖调查材料没有作为本结论的依据。

## BATTLE 记录

| 字段 | 值 |
|---|---|
| round_id | TASK-062-color-style-review |
| revision | 187e126fc20b13a4f5526a28a9189cc0acb4037f |
| baseline | 96bdb9b7c5b1f58c5ec223a0475be3d86cfae660 |
| classification / basis | execution；D028–D030 和 design.md 已冻结，本任务只核验实现及固定测试消费者 |
| change / task / AC | implement-color-style-output / TASK-062 / AC062 |
| scope | Color、Style、ColorMode、投影/ansies 编码、Frame 有效差分、组件继承、Application 模式、colors 示例及公共消费者/PTY 工具 |
| exclusions | 主题、ANSI 输入解析、M2、其他 OS、composition、benchmark、完整发布 |
| budget | 0/3 定点复核；未出现具体反例，故未重复运行同源套件或启动探针 |

## 契约审核

Color 保留原 8 个构造器并新增完整 Bright/Indexed/Rgb 形式；Style 的六项只读属性、默认值和等值比较完整。ColorMode 已从根包公开导出，新增类型各自在小写下划线文件中；公开 examples/colors 将其状态类放在独立 color_demo.cj。

color_mapping.cj 只使用契约规定的名义 16 色、6 级立方和灰阶公式。三通道整数平方距离从索引 0 顺序扫描，严格小于才替换候选，因此平局保留较小索引。未找到依赖 converter 或可变 colorTable 的读取。投影仅传给编码；Frame/Cell 继续保存原始 Style，而 toPlainText 不读取模式。

Frame 对同模式的相同原始样式跳过投影；跨模式时分别投影旧、新单元后才判定行变化。编码按相邻原始样式 run 重用投影，固定为 reset、前景、背景、六属性的顺序，并仍由 ansies 的 AnsiColor、Color.foreground/background、Style.set 产生 SGR。默认 Basic16 的旧 8 色/bold 路径保持原字节边界；宽字符 continuation 仍跳过输出。

paint 将六个可选组件字段逐项按“显式值优先，否则父值”解析，因此 false 是继承复位。文本、显式背景和边框接受完整有效样式；borderColor 仅替换前景；阴影仍严格使用调用方传入的完整 Style。布局、padding、gap 和阴影空间没有获得新的继承规则。

Application 在成功 writeScreen 返回后才一起提交 Frame 与已显示 mode；写入抛错时不会执行这两项赋值，沿用 D027 的停止、报错和终端恢复路径。模式变化不导致无条件全屏写入；尺寸变化仍走完整帧。不存在第二持久 Frame、投影权威或 ANSI 编码器。

## 测试消费者和 PTY 审核

tests/colors 是公开 cjtui.* 消费者，期望值以字面 SGR 和独立计算的 golden 写出，覆盖 RGB/Indexed/命名颜色、平局、原始单元保留、前景/背景、六属性、显式 false、边框、阴影、宽字符和旧字节回归。原有 R8/R9/060 入口未被弱化，all 只在既有入口之后追加 color 项。

PTY fixture 使用第二个真实 onKey 事件写确认文件并改变独立的 EVENT-FENCE 行；测试等待该完整行的 CUP/SGR/整行/reset 字节，并比较该动作之后的全部原始字节。静默断言不依赖 sleep。实际 colors 示例也在真实 PTY 中检查模式循环、六属性、resize、正常退出和 termios。屏幕读取器仅接受 CUP/SGR，逐行检查列宽和 reset 完整性。

按任务允许的同源原始证据复用：
 /workspace/work/color-implementation/final-colors-third.log 末尾显示颜色公共消费者通过；
 /workspace/work/color-implementation/integration.log 显示两个普通构建成功、14 个握手动作和实际 examples/colors PTY 均成功（退出码 0）。本审核未把这些作者证据替代代码检查，也没有重复该套件。没有发现新的、具体且可复现的反例，因此未启动额外 probe。

## 证据

| id | 方法 / 命令 | 结果 |
|---|---|---|
| E-062-01 | source /workspace/work/validation/sdk/cangjie/envsetup.sh；cjc --version；cjpm --version；检查 UCD archive 与只读 replay cache | SDK/CJPM 均为 1.2.0，审核环境可实际运行 |
| E-062-02 | git apply --reverse --check technical-review.diff | 成功；固定补丁可从受审版本干净反向应用 |
| E-062-03 | 审读 color.cj、color_mode.cj、style.cj、color_mapping.cj、ansi_encoding.cj、frame.cj、component.cj、layout.cj、application.cj、示例及 consumers | 上述契约路径一致，无必需缺陷 |
| E-062-04 | git diff --check baseline..revision、实体文件扫描、rg converter/colorTable/输出调用方 | 无 whitespace 错误；类型文件和唯一编码路径符合范围 |
| E-062-05 | 允许读取的 raw final-colors-third.log 与 integration.log | 公共消费者/PTY 原始执行成功；未重复运行 |

工作树在审核结束时干净。findings.json 为空，表示没有符合 BATTLE Protocol §6 的可复现未决发现。

## 边界

本结论不签署 TASK-063 的 cold/all/bundle/clean 执行，也不签署完整 release；composition 和 benchmark 仍不在本切片中，不能标为通过。

