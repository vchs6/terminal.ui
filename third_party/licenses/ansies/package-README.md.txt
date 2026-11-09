# ansies — ANSI 转义序列生成库（仓颉语言）

![版本](https://img.shields.io/badge/版本-1.3.105-blue)
![语言](https://img.shields.io/badge/语言-仓颉-orange)
![平台](https://img.shields.io/badge/平台-Linux%20%7C%20Windows-lightgrey)
![构建](https://img.shields.io/badge/构建-cjpm%20build-success)
![测试](https://img.shields.io/badge/测试-116%2F116%20通过-brightgreen)
![许可证](https://img.shields.io/badge/许可证-MulanPSL2-green)

基于 ECMA-48 / ISO 6429 标准，为仓颉控制台程序提供文本颜色、样式、光标控制、屏幕擦除等功能。支持 16 色/256 色/24 位真彩色、15 种文本样式、DEC/xterm/kitty 等终端扩展、终端响应解析。

---

## 特性

- **颜色**：标准 16 色 + 256 色索引 + 24 位真彩色
- **样式**：粗体、斜体、下划线、双下划线、上划线、删除线、隐藏、闪烁、边框、圈、上标、下标等 15 种
- **光标**：移动、定位、显隐、制表
- **屏幕**：擦除、滚动
- **多段文本**：`StyledText` 支持链式设置不同颜色/样式的多段落
- **样式聚合**：`TextStyle` 通过 64 位位域管理颜色与样式组合，支持 `toInteger()/fromInteger()` 串行化
- **终端扩展**：DEC（备用屏、滚动区、光标形状，api 层）、xterm（括号粘贴、焦点、鼠标、窗口）、kitty（下划线风格）、Windows Terminal（进度条）、iTerm2（Shell 集成、内联图片）、foot
- **响应解析**：纯函数解析器，解析终端回复（CPR、DA、DSR、SecondaryDA、DECRQSS、OSC 颜色、窗口大小等）；`Query` 生成查询请求、`Response` 解析回复，一一对偶
- **零硬编码**：所有转义序列通过 `core/csi.cj` 的 95 个 CSI lambda 函数生成（含 DECRQM）

---

## 颜色

### 标准 16 色

```cangjie
for (c in [AnsiColor.Red, AnsiColor.Green, AnsiColor.Blue, AnsiColor.White, ...]) {
    env.getStdOut().write(Color.background(c) + "  " + SGR("0") + " ")
}
```

### 256 色

```cangjie
for (cv in 0 .. 256) {
    env.getStdOut().write(Color.background(AnsiColor.IndexedColor(UInt8(cv))) + " " + cv.toString() + " " + SGR("0"))
}
```

### 真彩色

```cangjie
env.getStdOut().write(Color.background(AnsiColor.parse("#00868B")) + " 0x00868B " + SGR("0"))
env.getStdOut().write(Color.foreground(AnsiColor.parse("#FF4500")) + " 0xFF4500 " + SGR("0"))
```

### 前景/背景

```cangjie
Color.foreground(AnsiColor.Red)        // → \033[31m
Color.background(AnsiColor.Red)        // → \033[41m
Color.foreground(AnsiColor.TrueColor(r, g, b)) // → \033[38;2;R;G;Bm
Color.setDefault()                     // → \033[39;49m
```

---

## 文本样式

### 15 种样式

```cangjie
for (s in [AnsiStyle.BOLD, AnsiStyle.ITALIC, AnsiStyle.UNDERLINE,
           AnsiStyle.OVERLINE, AnsiStyle.DOUBLEUNDERLINE, ...]) {
    env.getStdOut().write(Style.set(s) + s.toString() + Style.reset(s))
}
```

### 组合样式

```cangjie
env.getStdOut().write(SGR(["1", "31", "44"]) + " 粗体+红字+蓝底 " + SGR(["0"]))
```

---

## StyledText — 多段样式化文本

每个段落独立设置颜色和样式：

```cangjie
let st = StyledText(" 红色粗体 ")
    .color("white", "red").bold()
    .then(" 蓝色斜体 ")
    .color("white", "blue").italic()
    .then(" 默认 ")
env.getStdOut().write(st.toString())
```

支持样式快捷方法：

```cangjie
StyledText("粗体").bold()
    .then("斜体").italic()
    .then("下划线").underline()
    .printAt(1, 1)      // 定位输出
```

---

## TextStyle — 样式聚合与编码

64 位位域同时管理颜色和样式，支持整数串行化：

```cangjie
let ts = TextStyle(fg: Some(AnsiColor.Red), bg: Some(AnsiColor.White),
                   styles: [AnsiStyle.BOLD, AnsiStyle.ITALIC])
println(ts.toEscapedString())          // → \033[31;47;3;1m

let v = ts.toInteger()                 // → UInt64
let ts2 = TextStyle.fromInteger(v)    // → 还原
println(ts == ts2)                     // → true
```

---

## 光标控制

```cangjie
Cursor.to(10, 5)        // 定位到第10行第5列
Cursor.up(3)            // 上移3行
Cursor.down(2)          // 下移2行
Cursor.forward(5)       // 右移5列
Cursor.back(3)          // 左移3列
Cursor.show()           // 显示光标
Cursor.hide()           // 隐藏光标
```

---

## 屏幕控制

```cangjie
Screen.clearLine(AnsiCleanModel.TOEND)   // 擦除光标到行尾
Screen.clear(AnsiCleanModel.ENTIRE)      // 擦除整屏
Screen.scrollUp(3)                       // 上滚3行
Screen.scrollDown(3)                     // 下滚3行
```

---

## DEC 扩展

```cangjie
Screen.alternateScreen()                                  // 切换到备用屏
Screen.mainScreen()                                       // 返回主屏
Screen.setScrollRegion(5, 20)                             // 设置滚动区
Cursor.setCursorStyle(AnsiCursorStyle.SteadyBlock)        // 设置光标形状
Cursor.showCursor()                                       // 显示光标
Cursor.hideCursor()                                       // 隐藏光标
```

---

## 终端兼容性

以下列出各功能在不同终端中的支持情况。

### 核心 ECMA-48（通用功能）

| 功能 | xterm | kitty | iTerm2 | Windows Terminal | foot | VSCode |
|------|-------|-------|--------|-----------------|------|--------|
| 16 色 / 256 色 / 真彩色 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 粗体 / 斜体 / 下划线 / 闪烁 / 反转 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 删除线 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 隐藏文字 (CONCEAL) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 光标移动/定位 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 屏幕擦除/滚动 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### 扩展样式（终端支持差异较大）

| 功能 | xterm | kitty | iTerm2 | Windows Terminal | foot | VSCode |
|------|-------|-------|--------|-----------------|------|--------|
| 双下划线 (SGR 21) | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| 上划线 (SGR 53) | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |
| 边框/圈 (SGR 51/52) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 上标/下标 (SGR 73/74) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Kitry 下划线风格 (4:0–5) | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |
| 下划线颜色 (SGR 58) | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |

### 终端特殊扩展

| 功能 | 来源 | xterm | kitty | iTerm2 | WinTerm | foot |
|------|------|-------|-------|--------|---------|------|
| 备用屏幕 (DEC 1049) | DEC | ✅ | ✅ | ✅ | ✅ | ✅ |
| 光标形状 (DECSCUSR) | DEC | ✅ | ✅ | ✅ | ✅ | ✅ |
| 滚动区域 (DECSTBM) | DEC | ✅ | ✅ | ✅ | ✅ | ✅ |
| 括号粘贴 | xterm | ✅ | ✅ | ✅ | ✅ | ✅ |
| 同步输出 | xterm | ✅ | ✅ | ✅ | ✅ | ✅ |
| 鼠标追踪 | xterm | ✅ | ✅ | ✅ | ✅ | ✅ |
| 窗口操作 | xterm | ✅ | ❌ | ❌ | ❌ | ❌ |
| 超链接 (OSC 8) | 通用 | ❌* | ✅ | ✅ | ✅ | ✅ |
| 任务栏进度条 | WinTerm | ❌ | ❌ | ❌ | ✅ | ❌ |
| Shell 集成 (OSC 133) | iTerm2 | ❌ | ❌ | ✅ | ❌ | ❌ |
| 内联图片 | iTerm2 | ❌ | ✅ | ✅ | ❌ | ❌ |

> *xterm 需编译启用 `--enable-osc8` 选项

### 判断依据

本库的 `extensions/` 目录按终端来源分类：

```
extensions/
├── xterm.cj      — xterm 特定扩展 (括号粘贴/鼠标/窗口)
├── kitty.cj      — kitty 扩展 (下划线风格/上划线)
├── iterm2.cj     — iTerm2 扩展 (shell 集成/内联图片)
├── winterm.cj    — Windows Terminal 扩展 (进度条)
└── foot.cj       — foot 扩展 (光标推入/OSC 7)
```

OSC 8 超链接（`Hyperlink.decorate`）为跨终端标准协议，归 api 层（`api/hyperlink.cj`），不在此目录。

使用 `core/` 和 `api/` 层的功能（颜色、样式、光标、屏幕、响应解析）在所有主流终端中兼容。使用 `extensions/` 层的功能建议根据目标终端选择性调用。

---

## 运行完整演示

```shell
cd examples/demo
cjpm run
```

`examples/demo/` 是一个独立的 cjpm 项目，涵盖全部上述功能。

---

## 模块架构

```
src/
├── core/           ECMA-48 + DEC 术语符号：类型/枚举/CSI 95 函数/OSC 10 函数/DCS 函数/响应基础工具与结果类型
├── api/            语义化封装：Cursor, Screen, Color, Style, TextStyle, Query, Response, Hyperlink, Window
├── utils/          有状态工具类：StyledText
└── extensions/     其他终端支持：XTerm, Kitty, WinTerm, Iterm2, Foot + 单一终端解析
```

---

## 文档

| 文档 | 位置 |
|------|------|
| 设计文档 | [`doc/design.md`](doc/design.md) |
| API 参考 | [`doc/feature_api.md`](doc/feature_api.md) |
| 测试报告 | [`doc/test_report.md`](doc/test_report.md) |

---

## 依赖

- 仓颉标准库
- `bitarray`（[libbitarray](https://atomgit.com/vchuoshen6/libbitarray)）— TextStyle 内部位域存储

---

## 许可证

本项目基于 MulanPSL2 许可证。

---

## 开发者

- **vchuoshen6** — 项目创建者与主要维护者
  - GitHub/AtomGit：[vchuoshen6](https://atomgit.com/vchuoshen6)
  - 其他贡献者：欢迎加入！

---

## Issues

使用中遇到问题或有功能建议，欢迎提交 Issue：

- [提交 Issue](https://atomgit.com/vchuoshen6/ansies4cj/issues/new)

提交时请尽量包含：
- 环境信息（操作系统、终端类型、仓颉版本）
- 复现步骤与最小示例代码
- 预期行为与实际行为

---

## 贡献方式

欢迎通过以下方式参与贡献：

1. **报告问题**：在 Issues 中描述你遇到的问题或建议
2. **提交代码**：
   - Fork 本仓库
   - 创建特性分支（`git checkout -b feature/xxx`）
   - 提交改动（遵循 Conventional Commits 规范）
   - 推送分支并提交 Pull Request
3. **完善文档**：修正文档错误、补充示例、改进注释
4. **补充测试**：为 `src/test/` 增加测试用例，保证 `cjpm test` 全部通过

### 开发流程

```shell
cjpm build     # 编译
cjpm test      # 运行测试（116 用例需全部通过）
cjpm test --coverage && cjcov -r . -o doc/cjcov --html-details -s src   # 覆盖率
cd examples/demo && cjpm run   # 运行演示
```

### 代码规范

- 遵循仓颉语言规范与项目文档（`doc/design.md`）中的分层约定
- 文件名使用下划线风格，内容与 `@file` 注释一致
- 除核心层外不硬编码转义序列，一律引用 `core/` 定义
