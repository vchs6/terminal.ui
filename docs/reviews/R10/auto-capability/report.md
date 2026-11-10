# TASK065：Linux 自动终端能力的隔离调查

本目录不是 `terminal.ui` 的实现、测试或新契约。它只记录可以在此 Linux 环境重新运行的 `libtinfo`/terminfo 探针证据，供后续实现和真实终端矩阵验证使用。

运行全部证据：

```bash
bash /workspace/work/auto-capability-recon/source/run_probe.sh
```

该脚本会重新编译探针并写入 `raw/*.log`；每份日志第一行是实际命令，末行是退出码。它不调用 shell `tput`，也不把它作为任何产品运行时依赖。

## 实测事实

| 主题 | 实际结果 | 原始证据 |
| --- | --- | --- |
| 可选加载 | 本机 `libtinfo.so.6` 的 `setupterm`、`tigetnum`、`tigetflag`、`set_curterm`、`del_curterm` 与全局 `cur_term` 均可经 `dlopen`/`dlsym` 取得。 | [libtinfo_symbols.log](raw/libtinfo_symbols.log) |
| 单色/8/256 | `dumb` 返回 `colors=-1`；`linux` 返回 8；`xterm-256color` 返回 256。 | [basic_mono.log](raw/basic_mono.log)、[basic_8.log](raw/basic_8.log)、[indexed_256.log](raw/indexed_256.log) |
| 样式字符串 | `tigetstr` 在 `dumb` 中对 bold/dim/sitm/smul/rev 都为空；在 8 色 `linux` 中 bold/dim/smul/rev 存在而 sitm 为空；在 `xterm-256color` 中这些字符串都存在。`smxx` 在 xterm 条目中为 `ESC [ 9 m`，但在 linux 条目不是字符串能力；应按非可移植的 strikeout 扩展对待。 | [basic_mono.log](raw/basic_mono.log)、[basic_8.log](raw/basic_8.log)、[indexed_256.log](raw/indexed_256.log)、[xterm_style_entry.log](raw/xterm_style_entry.log)、[linux_style_entry.log](raw/linux_style_entry.log) |
| 颜色与样式组合 | `linux` 的 `ncv` 为 18；xterm 与 dumb 条目未声明（API 返回 -1）。这证明条目可声明“颜色不能与某些视频属性组合”，不能仅根据每个样式字符串存在就保证组合输出正确。 | [basic_8.log](raw/basic_8.log)、[indexed_256.log](raw/indexed_256.log) |
| 16 色 | 此系统安装的 terminfo 条目中未找到 `colors#16`。编译的合成条目能由同一 API 返回 16。它只验证数值读取路径，并不代表真机。 | [indexed_16.log](raw/indexed_16.log) |
| 真彩标记 | 本机 `xterm-256color` 的 `Tc`/`RGB` 都是 -1，证明 256 色不蕴含真彩。合成的 `RGB` 与 `Tc` 扩展条目各自返回 1，验证扩展查询路径。两者都不代表真机。 | [indexed_256.log](raw/indexed_256.log)、[rgb_extension.log](raw/rgb_extension.log)、[tc_extension.log](raw/tc_extension.log) |
| 已有状态恢复 | 先以 `dumb` 建立 `cur_term`，再查询 `xterm-256color` 后，`set_curterm(saved)` 恢复到原指针；`del_curterm(created)` 后当前指针仍是原指针。 | [restore_existing.log](raw/restore_existing.log) |
| 失败不会退出进程 | 不存在的 terminfo entry 得到 `setupterm.rc=-1`、`errret=0`、探针退出 12；不存在的库得到 `dlopen=FAIL`、退出 10。 | [missing_entry.log](raw/missing_entry.log)、[missing_library.log](raw/missing_library.log) |
| TERMINFO 的限制 | 即使以干净环境设置 `TERMINFO`/`TERMINFO_DIRS` 为不存在路径，本机仍成功查到 `xterm-256color`，因为 ncurses 回退到编译进库的系统搜索路径。这个试验**不能**作为“数据库已不可用”的证据。 | [restricted_env_fallback.log](raw/restricted_env_fallback.log) |

本会话宿主只声明 `TERM=dumb`、空 `COLORTERM`。标准输入/输出是 TTY，但没有 controlling terminal（`tty` 失败）；因此这些记录不声称探测到了宿主模拟器或物理终端能力。见 [host_environment.log](raw/host_environment.log) 和 [stdio_tty.log](raw/stdio_tty.log)。真实 xterm/VTE/复用器/Windows 等输出与截图属于独立矩阵工作，未在此报告替代。

`std.env.getVariable(key: String): ?String` 在可用的仓颉标准库文档中存在，适合无副作用地读取 `TERM` 和 `COLORTERM`；`key` 含 NUL 会抛出 `IllegalArgumentException`。本机按指定 SDK 初始化后是 Cangjie 1.2.0，见 [cangjie_sdk.log](raw/cangjie_sdk.log)。这里没有将该 API 接入产品。

## 推荐的最小策略（建议，不是已实现契约）

1. 默认配置始终是 `App` 的自动路径；不要默认要求用户选择 capability mode。只有显式的手动 override 才能覆盖自动结果。
2. 把程序员提供的 `Color`/`Style` 视为富语义源值。离线纯 ANSI 快照保留这些源值；写到真实设备时才依据本次渲染的能力降级，不能把降级后的颜色写回源样式。
3. 自动路径先读取宿主声明 `TERM` 和 `COLORTERM`。`TERM` 只是一条 terminfo 查表键，`COLORTERM` 只是一条宿主声明；两者都不是硬件探测。空、缺失、`dumb`、库不可加载、entry 不存在、数据库不可读或任一异常，都得到 `Unknown`，并按保守单色输出继续渲染。
4. 若可选 terminfo 查询成功，使用 `tigetnum("colors")` 划分 `Mono`（小于 1）、`Ansi8`（8 至 15）、`Ansi16`（16 至 255）、`Ansi256`（至少 256）。不要由 256 色推断真彩。用 `tigetflag("RGB") == 1` 或 `tigetflag("Tc") == 1`，以及大小写无关的 `COLORTERM=truecolor|24bit` 声明，单独得到 `directRgb`。保留“信息来自哪个声明/termInfo”的内部诊断即可，不应把它包装成硬件事实。
5. 渲染器在 `directRgb` 时写原 RGB，在 `Ansi256`/`Ansi16`/`Ansi8` 时只为该次设备输出选择最近可表达色，在 `Mono`/`Unknown` 时省略颜色。对 rich Style 的 bold、dim、italic、underline、reverse，设备输出分别以 `tigetstr("bold"|"dim"|"sitm"|"smul"|"rev")` 是否为非空、非 `(char *)-1` 的字符串决定；缺失或 Unknown 就省略那一个设备属性，源 Style 不变。应使用该条目给出的序列，而不把“存在”误当作任意固定 ANSI 序列都可用。`smxx` 只在明确映射为 strikeout 且条目实际提供时才可采用。
6. `ncv` 是颜色与视频属性的组合约束来源。它存在时，未来实现需要以本次目标库已验证的位定义逐项裁剪有冲突的组合；在尚无该位解释、组合优先级和真终端验证前，不能把单项 `tigetstr` 的存在包装成“颜色和六种属性已安全自动组合”。
7. 普通示例与离线 ANSI snapshot 不应被要求先进行 capability 判断；真实 device sink 才注入上述自动结果。这样测试既能固定原始 SGR，又不会把模拟的 `TERM` 当成真实跨终端验证。

可把结果表示成“调色板级别 + `directRgb` + 置信来源”，而非单一互斥等级。例如 `Ansi256 + directRgb` 是有效组合。`Unknown` 必须和 `Mono` 分开保存以利诊断，但两者的默认设备输出同样保守。

## 可选 `libtinfo` 接入的线程与副作用边界

探针的关键顺序是：保存 `cur_term`，调用 `setupterm`，查询，`set_curterm(saved)`，再 `del_curterm(created)`。这在本机的空旧状态与已有旧状态两种情形都通过了。探针源码在 [terminfo_probe.c](source/terminfo_probe.c)。

但 `cur_term` 是动态库进程全局状态，`setupterm` 在查询期间会替换它。一个仅由本组件持有的互斥锁不能保护同时直接使用 ncurses 的外部线程。因此未来实现只能在以下边界之一运行：在其他 ncurses 使用和并行渲染开始前一次性完成，或由覆盖所有该库调用方的进程级串行机制包住保存、查询、恢复、释放的整段操作。无法满足该边界时，应跳过该探针并保守返回 `Unknown`。无论库、符号、数据库还是 entry 失败，均不得阻塞 UI、退出进程或改动用户选择。

这里验证的是 `libtinfo.so.6`，不是对所有 Linux 发行版库名、ABI 或线程行为的泛化保证。未来若尝试多个库名，每个 `dlopen`/符号缺失都应是普通的 `Unknown` 失败路径。

## `ncv`：颜色优先时可确定裁剪的两项

本机 `infocmp -L linux` 将 `ncv#18` 展开为 `no_color_video#18`，并列出该条目的样式能力。`ncv` 是 terminfo 的“不能同颜色使用的视频属性”位掩码。该镜像没有安装 terminfo(5) 手册页；为避免靠记忆解释数值，隔离脚本同时读取本机 Python ncurses 绑定的实际 `A_*` 常量，将其右移实际属性位移 16 后解码。结果是：18 = `A_UNDERLINE` (2) + `A_DIM` (16)，见 [ncv_local_entry.log](raw/ncv_local_entry.log) 与 [ncv_decode.log](raw/ncv_decode.log)。

标准 `ncv` 掩码还涵盖 standout、reverse、blink、bold、invisible、protect 与 altcharset；本次需要的映射为 underline=2、dim=16、reverse=4、bold=32。italic (`sitm`) 和 xterm 的 `smxx` strikeout 扩展不在该传统掩码中，仍只能按各自字符串能力裁剪。xterm-256color 的 `ncv` 由 `tigetnum` 返回 -1，且 `infocmp -L` 未列出 `no_color_video`；它表示该 entry 没有声明组合禁令，不能倒推它是物理硬件证明，也不应被当成“所有组合都不支持”。

若冻结“颜色优先”的设备策略，确定规则可以是：源 `Color`/`Style` 不变；当设备输出颜色且 `ncv >= 0`，仅省略掩码命中的已知样式属性，保留颜色和不冲突的样式。于是本机 `linux` 的有色输出裁掉 underline 与 dim，仍可输出 bold/reverse；无色输出仍可使用该条目存在的样式。`ncv < 0` 仅按“未声明限制”处理，不作额外裁剪。这个规则仍需要真实宿主矩阵验证其可见结果。

## glibc 私有 `libtinfo` 命名空间

常规 `dlopen` 会触碰进程内共享 `cur_term`，因而需要与所有 ncurses 调用协调。glibc 提供的 `dlmopen(LM_ID_NEWLM, "libtinfo.so.6", RTLD_NOW | RTLD_LOCAL)` 在本机可用，且为该库提供独立可写状态。隔离 C 探针的实际结果：

- 基础命名空间先建立 `dumb`，其 `colors=-1` 与 `cur_term` 指针保持不变；私有命名空间随后查 `xterm-256color` 得到 256，私有 `cur_term` 恢复为 null。
- `dlinfo(RTLD_DI_LINKMAP)` 返回不同的实际加载基址，两个命名空间的 `cur_term` 数据地址也不同。
- 一个已加载的私有 handle 在互斥锁内复用 500 次没有错误；基础与私有命名空间分别在线程中各循环 500 次也没有错误，基础指针仍不变。

原始结果见 [dlmopen_isolation.log](raw/dlmopen_isolation.log)，源码见 [dlmopen_probe.c](source/dlmopen_probe.c)。因此第一阶段 Linux/glibc 的最小接入可以持有**一个**私有 handle，并用组件内部 mutex 串行该私有 handle 的 `setupterm`、查询、恢复、释放；不需要让应用程序员管理 ncurses 全局锁，也不应每次查询新建 namespace。这个结论仅覆盖本机 glibc/libtinfo 组合；没有 `dlmopen`、`LM_ID_NEWLM`、符号、库或数据库时直接 `Unknown`。它不对 musl、非 Linux 或其他 ABI 作承诺。

私有 namespace 只把 terminfo 当作能力元数据，不能把 `tigetstr` 的任意字节透传到设备。当前两条实际条目的 bold/dim/sitm/smul/rev 序列恰好分别是已知标准 SGR 1/2/3/4/7（xterm 另有 `smxx=SGR 9`），见 [xterm_style_entry.log](raw/xterm_style_entry.log)。安全最小实现应仅把“去除且不执行 terminfo padding 后，精确等于该属性已知 SGR”的条目视作该属性的支持证据，实际输出仍由自己的 ANSI SGR 编码器生成；任意其他字符串、参数化能力或未知扩展均不执行并保守省略。颜色同样继续由框架自己的标准 SGR 编码器生成，terminfo 数值只参与选择级别。

## SDK 1.2 的 API 形态最小验证

在指定 SDK 1.2.0 中，下面两种无默认值/带默认值形态可以同时编译并运行：`Application(root)` 与 `Application(root, colorMode: ColorMode.Basic16)`，其中构造器分别是 `init(root: Root)` 和 `init(root: Root, colorMode!: ColorMode)`；以及 `Frame().toAnsi()` 使用命名参数默认值的丰富快照模式。见 [application_overload_probe.cj](source/application_overload_probe.cj) 和 [cangjie_overloads.log](raw/cangjie_overloads.log)。

这只证明语言与调用兼容性：未来 `Application(root)` 可以走自动设备能力，旧显式调用仍可作为 override；未来 `Frame.toAnsi()` 可以默认丰富的纯快照。它没有证明当前产品已无设备查询，实际实现仍须把探测限制在 Application 的真实 device sink 路径，并以直接行为验证快照入口不会读取环境或终端。

## SDK 1.2 可执行程序到私有 FFI 的实际调用

为排除“纯 C 进程通过，但 Cangjie runtime 的动态装载/TLS 环境不同”的风险，本目录另建了一个 CJPM executable（不是产品包）：[cangjie_dlmopen_probe](cangjie_dlmopen_probe)。它沿用产品的相对 FFI 形态：`cjpm.toml` 的 `[ffi.c] cangjie_dlmopen_probe = { path = "./native" }` 链接本地 `libcangjie_dlmopen_probe.a`；仓颉侧用 `foreign { func cangjie_dlmopen_probe(): Int64 }` 调用一次。没有加入运行时专用 flag、外部初始化或额外库。

该 helper 在 Cangjie executable 内以基础 namespace 建立 `dumb`，私有 `dlmopen` namespace 查询 `xterm-256color`，然后打包三个实际断言：bit 32 为基础 `cur_term`/colors 未变、bit 16 为私有 `cur_term` 已恢复、低 16 位为私有 colors。SDK 1.2 `cjpm build` 后，在同一 SDK 的常规 `envsetup.sh` 环境直接执行生成的 `target/release/bin/main`，退出 0 并打印 `dlmopen_packed=4295033088`（两个状态位均为 1，colors=256）。

完整入口与结果在 [cangjie_dlmopen_probe.c](cangjie_dlmopen_probe/native/cangjie_dlmopen_probe.c)、[main.cj](cangjie_dlmopen_probe/src/main.cj)、[cjpm.toml](cangjie_dlmopen_probe/cjpm.toml)，以及 [cangjie_dlmopen_c_compile.log](raw/cangjie_dlmopen_c_compile.log)、[cangjie_dlmopen_cjpm_build.log](raw/cangjie_dlmopen_cjpm_build.log)、[cangjie_dlmopen_directbin.log](raw/cangjie_dlmopen_directbin.log)。这只验证一次受控调用，不替代前述 C 层的重复/并发实验，也不扩大为产品 profile 实现。

## 有界终端查询

未实施也不推荐作为默认来源。若以后确有需要，它至少应只在可写 TTY 上、明确 opt-in、单一未完成请求、严格字节数上限和短超时下执行，并完整恢复/隔离输入流；没有可靠回复就仍是 `Unknown`。它不能替代真实跨终端矩阵，也不能因伪造的 `TERM` 视为检测到实际硬件。

## 范围与可复现性

`source/extended-terminfo.src` 的 RGB、Tc、16 色条目是特意合成的 API 夹具；`source/run_probe.sh` 会生成它们到本目录的 `generated-terminfo/`。所有正式产品文件、正式测试和共享缓存均未修改。本调查没有生成或声称有真实运行截图。
