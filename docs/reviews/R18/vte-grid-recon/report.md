# VTE 原生当前文本导出设施调查

2026-11-10 UTC。结论：**设施候选可用**。在真实 XFCE Terminal **1.1.4-1** / VTE **0.80.1** 进程内，开发测试专用 GTK module 从宿主自身的 `TerminalWidget` 读取 `vte_terminal_get_text()`，已得到真实当前 viewport 的 UTF-8 文本文件。它不是独立 ANSI 解析器、截图 OCR、另一个终端或 tmux 网格。**这是有插装的真实宿主证据；不冒称未插装宿主提供了同一导出接口，也不构成产品或 TASK148/151 PASS。**

没有修改产品、正式测试、main 或 TASK148 oracle；未读取 TASK149 作者报告/交流；未派生代理；未安装或下载包。只使用已存在的 Xorg、XFCE/VTE、GTK、GCC、Python、XTEST 和 ImageMagick。输入契约及宿主工具的路径/版本/哈希在 `raw/provenance.json`。

## 冻结证据

最终插装运行：`raw/final-module/`，UTC `23:03:26.605787` 至 `23:03:28.957909`，新建私有 Xorg **:181**，`-nolisten tcp`，真实窗口 **0x200003**，XFCE PID **1476117**，PTY 和 TERM 见 `child.json`。实际网格 **100 列 × 28 行**，窗口 **1017×561 px**，字体 DejaVu Sans Mono 12。独立未插装对照：`raw/final-baseline/`。二者均是同一现有 `/usr/bin/xfce4-terminal`，使用私有 HOME、XDG 目录和 `dbus-run-session -- ... --disable-server`。新建显示前拒用已存在的 socket/lock；只查询自己新建的显示和窗口。

原生对象取得路径是：

```text
gtk_window_list_toplevels
  -> gtk_container_foreach (递归，记录实际运行时类型)
  -> /TerminalWindow/GtkBox/GtkNotebook/TerminalScreen/GtkScrolledWindow/TerminalWidget
  -> g_type_check_instance_is_a(vte_terminal_get_type()) == true
```

夹具要求恰好一个 VTE 候选，不接触其他进程。`native-*-meta.json` 保存实际 widget 路径、候选数、进程、UTC、原生行列、cursor 和 Gtk adjustment。`terminal-maps.txt` 证明实际加载的 XFCE、VTE 和模块；未复制这些 ELF 文件。

| 阶段 | 原生当前文本 | 已证实的行为 |
|---|---|---|
| normal | `native-0-visible.txt`，102 bytes | 28 行；覆盖/擦除后的 CURRENT_NORMAL；中文、emoji、组合字符保持 UTF-8；STALE_NORMAL 不在文本中 |
| alternate | `native-1-visible.txt`，109 bytes | 真实 `1049h` 后的 alternate screen；底行 BOTTOM_ROW28_ALT；无 normal 文本、无 STALE_ALT |
| restored | `native-2-visible.txt`，102 bytes | `1049l` 后与 normal 原生文件逐字节相同 |
| scrollback | `native-3-visible.txt`，271 bytes | 当前 28 行是 SCROLL_14…SCROLL_40 加空白底行；不混入 SCROLL_01…13 的历史 |

每一阶段都有原始 `normal/alternate/restored/scrollback.png`、读取后的原始 PNG、真实 `xwininfo`、读取前后 `xprop`、截图命令/窗口/UTC/hash。截图由 `import -window <真实id>` 取得，没有重绘。`outer-ansi.bin` 是真实 `script` PTY 全流，保留头尾和 exit；`emitted.bin` 是固定测试 child 实际写入的独立日志，不被用来产生原生文本。`ack-*` 保存每段实际固定输出，`child.json` / `exit.json` 保存 termios 与 TTY。配置输入、迁移后的 `effective-xfconf.xml` 和源文件快照也保留在最终运行目录。

## 格式和不能混同的路径

`vte_terminal_get_text(terminal, NULL, NULL, NULL)` 返回宿主维护的当前显示文本；夹具仅原样写出返回的 NUL 终止 UTF-8 字符串。这份文件是 **native viewport text**，不是包含颜色、字重、宽字符续单元、空单元所有属性或完整逐 cell 坐标的 grid 序列化。原生 API 在本样本中去除了行尾空格，保留 28 个换行。颜色仍由同阶段原始 PNG 佐证；不能从此文本恢复完整样式。

另两条原生 API 路径也有原始返回文件，故可直接比较：

- `vte_terminal_write_contents_sync`：`native-*-contents.txt`，原生调用和 GOutputStream close 均成功，无 GError。**包含 scrollback 历史及 NUL 空单元**，不是当前 viewport 等价物，不能默默当作当前网格文件。`native-3-contents.txt` 包含旧 normal 内容和 SCROLL_01…40，而 visible 文件仅有当前屏幕。
- `vte_terminal_get_text_range`：`native-*-range.txt`。本探针把 Gtk adjustment value 当作起始行，这在 normal/scrollback 得到相应文本，但 **alternate screen 返回空行范围**；原生 cursor row 与 adjustment 坐标不一致。负证据保留，禁止将这种 naive 范围算法用于151。

XFCE 二进制的动态符号及调用反汇编指向 `vte_terminal_write_contents_sync`；其真实 “Save contents...” 对话框已通过私有 `accels.scm` 的 F6 动作打开。`raw/attempt2` 至 `attempt5` 保留对话框树、PNG、全流和失败状态。当前无 WM 的 GUI 自动保存流程没有完成；本报告不将 GUI 保存标为成功。`attempt1` 是夹具 termios bytes JSON 序列化错误；失败 traceback 保留在全流。早期失败运行未记录被清理 host 的单独退出码，不补造该数值；最终两个成功运行已完整记录 0/0/0 退出和清理。

## 插装及最小副作用对照

模块源码：`scripts/native-module.c`。仅标准 C 头文件和 `dlsym`，使用现有 GCC 编译；`status.json` 记录完整编译 argv、编译 exit 0、模块/源文件 SHA-256；`launch.json` 明确记录 `GTK_MODULES` 绝对加载路径。最终模块 hash 是 `4a918852c20504998e884ef570e816860e456b37e07c47edb794d7c801b6d3cf`；源码 hash 是 `18fa276e05e4a57c6b2506ee47ced4fa4c373ce489da8e23a69c90b653f1e2bb`。模块只在 GTK 主循环里轮询自己的请求文件，然后读取真实 widget；没有 PTY 输出、输入注入、标题或选区 API。

`scripts/verify.py` 对最终配对样本执行 **76 项离线断言**，记录在 `raw/verification.json`：

- 插装与未插装的四张原始 PNG **逐字节相同**；每阶段原生读取前后 PNG 也相同。
- 每阶段读取前后真实 WM_NAME、_NET_WM_NAME、_NET_WM_ICON 原始属性相同。
- 两边实际 `outer-ansi.bin` 去掉 script 自身头尾后的全部 PTY bytes，分别等于固定 child `emitted.bin`；两边 child 字节也相同。没有用解析该流的结果作为 grid。
- 私有 X server 的 CLIPBOARD **owner 元数据均为 0**，读取前后相同。这里只查询 owner，**没有读 clipboard 内容，也没有非空剪贴板 payload 对照**；不能扩大为所有选区情形的非干扰证明。
- 原生文本的完整独立字面量、28 行、网格尺寸、widget/PID、normal 恢复、历史排除和错误范围负例均被核对。
- 最终 child / XFCE 外层 / Xorg exit 均 0，termios 完整相等。私有 HOME（包括临时模块 ELF）及显示 socket 已移除。

这些对照限于本固定样本。GTK module 改变宿主地址空间、增加主循环 callback 和内存读取；不证明任意时序/负载下完全无干扰。没有声称产品的未插装宿主矩阵已通过。未读取用户 DISPLAY、共享窗口、任何私钥或其他进程；不采集用户 clipboard；没有 SSH 或网络操作。

## 给151的复用边界

```sh
# 固定自有样本演示；每次必须用新的运行名，脚本拒绝覆盖：
VTE_RECON_RUN=unique-module VTE_RECON_MODE=module /usr/bin/python3 scripts/run.py
VTE_RECON_RUN=unique-baseline VTE_RECON_MODE=baseline /usr/bin/python3 scripts/run.py
# 核验本次冻结最终证据：
/usr/bin/python3 scripts/verify.py
```

`run.py` 只启动本调查的固定 scene，**不能充当实际公共 CJ consumer**。151 可复用 module 的构建/加载、单 widget 定位和 `native-request` → `native-N-visible.txt` / `native-N-meta.json` 机制，届时必须用自己的私有真实 XFCE 会话启动冻结公共 consumer，按 c/a/b/r 等实际阶段取得新的原生文本、PNG、全流、产品/源码 hash 和状态。不能把本调查文件填进产品 manifest。

原生 **当前文本** 设施缺口已获得实证；若151要求完整逐 cell 样式/宽字符单元属性，本路径仍不足，需要另行证明。TASK148 原要求未降低，`host-oracle.mjs` 没有更改也没有运行。是否接受这种明确标注的宿主插装观察作为151的 nativeGrid 证据，应在151证据策略中明示，不能凭 oracle 目前只检查非空就自动升级。

`findings.json` 提供机器可读交接；`hashes.json` 覆盖本目录全部最终文件（除自身和临时 pycache）。不包含 ELF、whole checkout 或私钥归档。
