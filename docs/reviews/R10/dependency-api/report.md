# TASK-006 颜色与样式依赖 API 调查

日期：2026-11-10。只读主仓库基线 `96bdb9b7c5b1f58c5ec223a0475be3d86cfae660`；主仓库 `git status --short` 前后均空。所有新增文件位于 `/workspace/work/color-api-recon`。本调查未修改产品、正式测试、共享依赖缓存，也未运行旧全套测试。

## 结论与适用边界

**已实际验证：ansies 1.3.113 的公开 API 足以薄封装生成默认色、16 色、256 索引色、24 位 RGB 的前/背景，以及 bold、dim、italic、underline、inverse、strike。无需新造 ANSI 生成内核。**

**不能直接采用它的颜色降级结果：`AnsiColorConverter` 的最近邻实现存在已复现错误。** 这不影响直接颜色/样式序列生成。能力模式选择、映射策略、Monochrome 语义仍是框架契约，依赖的生成 API 不会自动处理这些策略。

本报告是隔离开发探针证据，不代替后续独立测试/审核/验收，不代表 TASK-006 产品通过。没有验证真实终端显示效果、终端检测、ANSI 解析或 GUI/主题文件。

## 环境与复现

- SDK：`/workspace/work/validation/sdk/cangjie/envsetup.sh`；`cjc -v` 为 `Cangjie Compiler: 1.2.0 (cjnative)`，target `x86_64-unknown-linux-gnu`。
- 项目骨架由 `cjpm init --path /workspace/work/color-api-recon/probe --name color_probe --type executable` 创建。
- 依赖：ansies 1.3.113，传递依赖 bitarray 0.1.0；使用从原始缓存私有复制的 `/workspace/work/color-api-recon/cache`，registry relay 为 `http://127.0.0.1:18972`。
- 原始源只读：`/workspace/work/validation/replay-dependencies/cache/repository/source/default/ansies-1.3.113`。
- 原始 ansies archive SHA256：`396ead6ab841eddd12b196fb657848587c4514a435c536146810ee5675344940`。
- 该探针仅依赖 ansies/bitarray，不触及 unicode 原生构建或 UCD 下载。

```sh
cd /workspace/work/color-api-recon/probe
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cjpm build > ../logs/build.log 2>&1
./target/release/bin/main > ../logs/output.txt
python ../check_output.py > ../logs/check.log
```

以上有效命令退出码均为 0。build 成功，有 3 条探针自身 warning（两条换行连接表达式、一条编译器知道构造器后判定的不可达兜底）；没有依赖构建失败。初始化时曾按包名尝试 `target/release/bin/color_probe` 得到文件不存在，实际 CJPM 二进制名称为 `target/release/bin/main`，随后按上面命令直接运行成功。

检查结果：`571 exact ANSI byte assertions passed; 4 enum syntax/runtime assertions passed`，原始日志共 584 条记录（其余为 converter 诊断和公共调色表读取）。完整可复现源码为 `probe/src/main.cj` 与 `probe/src/color.cj`；断言脚本为 `check_output.py`。

## 精确公开 API（源代码与实际编译均确认）

来自 `ansies.api`：

```cangjie
public class Color {
    public static func foreground(color: AnsiColor): String
    public static func background(color: AnsiColor): String
    public static func setColor(bg: AnsiColor, fg: AnsiColor): String
    public static func setDefaultForeground(): String
    public static func setDefaultBackground(): String
    public static func setDefault(): String
}
public class Style {
    public static func set(style: AnsiStyle): String
    public static func reset(style: AnsiStyle): String
}
```

所有上述普通参数按位置传递；`setColor` 顺序为 **背景、前景**。探针导入采用 `Color as AnsiColors` 和 `Style as AnsiStyles`，与框架自身类型名称隔离。

来自 `ansies.core`：

```cangjie
public enum AnsiColor <: Equatable<AnsiColor> & Parsable<AnsiColor> & ToString {
    | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
    | BrightBlack | BrightRed | BrightGreen | BrightYellow
    | BrightBlue | BrightMagenta | BrightCyan | BrightWhite
    | Default | IndexedColor(UInt8) | TrueColor(UInt8, UInt8, UInt8)
    // 另有判等、toString、解析等成员，本次只探测所需生成链。
}
// AnsiStyle 的本次必要构造器：
// BOLD, DIM, ITALIC, UNDERLINE, REVERSE, STRIKETHROUGH
public let SGR: (args: Array<String>) -> String
```

`inverse` 对应 `AnsiStyle.REVERSE`，`strike` 对应 `AnsiStyle.STRIKETHROUGH`；不要使用已废弃的 `DELETEDLINE`。`SGR(["0"])` 是现有框架使用的全复位路径，已验证输出。

源定位：`src/api/color.cj`、`src/api/style.cj`、`src/core/ansi_color.cj`、`src/core/ansi_style.cj`、`src/core/ansi_parameter_provider.cj`、`src/core/csi.cj`。

## 输出字节

下文 `ESC` 始终是单字节 27 (`0x1b`)，不是字面量反斜杠字符串。全部输出无额外换行；日志中的换行仅由探针 `println` 添加。

| 输入 | 实际输出 |
|---|---|
| 基础 8 色前景 Black..White | `ESC[30m` .. `ESC[37m` |
| 基础 8 色背景 Black..White | `ESC[40m` .. `ESC[47m` |
| 亮 8 色前景 BrightBlack..BrightWhite | `ESC[90m` .. `ESC[97m` |
| 亮 8 色背景 BrightBlack..BrightWhite | `ESC[100m` .. `ESC[107m` |
| Default 前/背景 | `ESC[39m` / `ESC[49m` |
| IndexedColor(n) 前/背景，全部 n=0..255 已断言 | `ESC[38;5;nm` / `ESC[48;5;nm` |
| TrueColor(r,g,b) 前/背景 | `ESC[38;2;r;g;bm` / `ESC[48;2;r;g;bm` |
| BOLD / DIM / ITALIC / UNDERLINE / REVERSE / STRIKETHROUGH set | `ESC[1m` / `ESC[2m` / `ESC[3m` / `ESC[4m` / `ESC[7m` / `ESC[9m` |
| 同顺序 reset | `ESC[21m` / `ESC[22m` / `ESC[23m` / `ESC[24m` / `ESC[27m` / `ESC[29m` |
| SGR(["0"]) | `ESC[0m` |
| setDefault() | `ESC[39;49m` |
| setColor(BrightBlue, TrueColor(1,2,3)) | `ESC[104;38;2;1;2;3m` |

RGB 实测组为 `(0,0,0)`、`(255,255,255)`、`(1,128,254)`、`(255,0,128)`，分别验证前/背景。示例精确十进制 bytes：

```text
foreground(BrightRed)         = [27,91,57,49,109]
background(BrightWhite)       = [27,91,49,48,55,109]
foreground(IndexedColor(255)) = [27,91,51,56,59,53,59,50,53,53,109]
background(TrueColor(1,128,254)) = [27,91,52,56,59,50,59,49,59,49,50,56,59,50,53,52,109]
Style.set(REVERSE)            = [27,91,55,109]
SGR(["0"])                   = [27,91,48,109]
```

**reset 限制：** `Style.reset(BOLD)` 的 `21` 字节已实测，不能把它当成现代终端普遍使用的粗体/弱化关闭 `22`；21 常用于双下划线。继续使用框架既有的“全复位然后重发完整样式”即可绕开它，且不会新造 ANSI 核心。此处只验证字节，不承诺各终端对视觉属性的支持。

## 颜色降级：公开接口与已复现缺陷

公开 API：

```cangjie
public class AnsiColorConverter {
    public static var colorTable: VArray<(UInt8, UInt8, UInt8), $256>
    public func toTrueColor(color: AnsiColor): AnsiColor
    public func toIndexedColor(color: AnsiColor): AnsiColor
    public func toBaseColor(color: AnsiColor): AnsiColor
}
```

`AnsiColorConverter()` 默认构造、以上三个实例方法及 `AnsiColorConverter.colorTable[196]` 的跨包访问均经本次 SDK 实编译。表 196 实读为 `(255,0,0)`。不需要复制依赖的 256 项常量表；但该表是 **public static var**，不是不可变契约，后续设计需明确框架是否/何时读取它，以及外部修改的边界。

实际输出（`#ff` 表示索引 255，`#09` 表示索引 9；这是依赖 `toString()` 的形式）：

| 输入 | toBaseColor | toIndexedColor | toTrueColor |
|---|---|---|---|
| RGB(1,128,254) | BrightWhite | Indexed(255) | RGB(1,128,254) |
| RGB(250,0,0) | BrightWhite | Indexed(255) | RGB(250,0,0) |
| RGB(255,0,0) | BrightRed | Indexed(9) | RGB(255,0,0) |
| RGB(0,0,255) | BrightBlue | Indexed(12) | RGB(0,0,255) |
| RGB(128,128,128) | BrightBlack | Indexed(8) | RGB(128,128,128) |
| Indexed(17) | BrightWhite | Indexed(17) | RGB(0,0,95) |
| Indexed(196) | BrightRed | Indexed(196) | RGB(255,0,0) |
| Default | Default | Default | Default |

源码原因位于 `src/core/ansi_color_converter.cj` 的私有 `getNearestColor`：每轮先执行 `best = i`，仅更新 `minDist`，没有在距离更小时才更新 `best`，因此没有遇到零距离的遍历最终返回最后索引。它还对接近灰色输入改用亮度距离，与“统一 RGB 平方距离近邻”的潜在框架契约不同。基于本次证据，不应声称该 converter 已满足确定性最近邻要求。

**待主代理决定，尚未实施/验证的建议：** 在框架薄适配策略层用依赖公开表提供的值执行冻结的近邻算法，明确平方 RGB 距离、候选集合及平局规则；继续由 ansies 生成全部序列。若采用这种最小适配，应在依赖缺口记录中关联本报告，并说明可变表的读取策略。这里没有编写或测试任何替代映射实现。

## SDK 1.2 的关联值语法

先读取用户指定 `/workspace/work/CangjieSkills/.agents/skills/cangjie-coding/SKILL.md`，再通过其 `scripts/search_docs.py` 一个进程批查 `enum 关联值 UInt8`、`UInt8 转换`、`String toArray`；随后按最小索引读取 `language.enum` 与定义叶子。未直接读取知识库正文文件。

以下定义已在 `probe/src/color.cj` 实际编译：

```cangjie
public enum Color <: Equatable<Color> {
    | Default | Indexed(UInt8) | RGB(UInt8, UInt8, UInt8)
    public operator func ==(other: Color): Bool {
        match ((this, other)) {
            case (Default, Default) => true
            case (Indexed(a), Indexed(b)) => a == b
            case (RGB(a,b,c), RGB(x,y,z)) => a == x && b == y && c == z
            case _ => false
        }
    }
}
```

已运行确认：`let idx: UInt8 = 255; Color.Indexed(idx)`，`Color.Indexed(255)`，`Color.RGB(0,128,255)`，`Color.RGB(UInt8(0),UInt8(128),UInt8(255))`，`case Color.RGB(r,g,b)` 解构；相等与不等结果均符合预期。仅实现 `==` 的 enum 在当前 SDK 1.2 能使用 `!=`，与 skill 知识页“显式实现两个操作符”的泛化说明不同；这里以实际 SDK 证据为准，与主仓库现有写法一致。未探测非法范围字面量诊断，不能把 UInt8 范围错误消息视为已验证。

## 对当前产品契约的直接影响

当前 `src/style/color.cj` 只有 Default+8色，`style.cj` 只有前景、背景和bold；`ansi_encoding.cj` 已使用 ansies foreground/background/set(BOLD) 及全复位。扩展 bright/Indexed/RGB 与其余 bool 属性可沿这条薄适配路径，无需触碰 OSC 调色板控制。保持原默认8色输入的序列形式（30..37/40..47），不应为了能力模式统一而强行重编码成38;5或RGB。

`Frame.toAnsi()` / `changesSince()` 通过结构化 Style 比较控制重新编码；能力配置若进入编码路径，其传递、变化时的基线失效及导出入口一致性应由 TASK-006 契约明确。这些是代码阅读所得的集成关注点，本探针未实现或验收。

REQ-005.1/.4 要求 ansies 薄适配、编码矩阵及颜色能力映射；TASK-006/AC-006 现有文字要求默认/16/256/真彩色按能力映射。Basic16/Indexed256/TrueColor/Monochrome 显式配置、近邻规则与是否保留属性等最终契约由主代理冻结，本报告没有扩大范围。

## 固定探针摘要

```text
probe/src/color.cj SHA256 4088ce4e0b3cbec306709f527a8ef93badb070a80ab801820c3d8238eee0cc6d
probe/src/main.cj SHA256 46c714978e1fcbc2c7d1b2fbf8c0ea4fa7bc2f9d000841ef54832f7d9ab19784
probe/target/release/bin/main SHA256 7d683f1fdbd7fc1045aaa78c2021bebcfa8c6d11a147add2e9f8fca0d0a9d5db
```
