# R6 跨平台与 HarmonyOS 证据

核对日期：2026-11-09（UTC）。任务性质：执行型只读调查及证据记录；用户已经确定跨平台且包含鸿蒙，不在本调查中重新选择或缩小该目标。本文是 TASK-001/003 调查输入，TASK-004 尚须冻结平台契约；不代表产品实现或平台验收通过。

已读取 AGENTS.md、提案、需求、架构、用户构造及依赖证据；适用 Superpowers 的 brainstorming 调查边界与 verification-before-completion。没有实现产品、安装鸿蒙 IDE/镜像、生成平台制品或连接真机。OpenSpec 的对应修订及状态由本轮主任务维护。

## 1. 结论与目标登记建议

Linux、Windows、macOS、商业 HarmonyOS 均应登记为 **required / planned / pending**。用户明确要求跨平台并包含HarmonyOS；Linux/Windows/macOS/HarmonyOS四目标矩阵是本轮工程细化，不声称用户逐一指定了版本或CPU。这既不是“语言支持即产品支持”，也不是把 HarmonyOS 降成可选扩展。各平台的 OS 版本、CPU、SDK、终端宿主和协议组合仍须实测后冻结；当前不存在可据以发布“全平台已支持”的产品证据。

| 平台 | 范围 / 实现 / 验证 | 有依据的调查起点 | 必须继续冻结的部分 |
|---|---|---|---|
| Linux | required / planned / pending | 仓颉 1.2.0，x86_64；R5 隔离语言/依赖探针 | 发行版、系统版本、glibc、终端模拟器及无图形控制台，TTY/raw/resize/恢复；aarch64 单列调查 |
| Windows | required / planned / pending | 仓颉 1.2.0 的 x86_64-windows-gnu/MinGW 路线 | Windows 版本、控制台宿主、VT 模式及键盘/resize/恢复；不能以 WSL/Linux 结果代替原生 Windows |
| macOS | required / planned / pending | 1.2.0 下载页提供 mac-aarch64；手册还列 x86_64 目标 | macOS 版本、实际可获得 SDK/架构、Terminal 等宿主；不能由手册的目标名承诺 Intel 制品可获得 |
| HarmonyOS（华为商业系统） | required / planned / pending | 仓颉 ohos 交叉 SDK、HarmonyOS NDK、hdc 调试 shell 均有官方依据 | **确切仓颉/DevEco/SDK/API、OS 构建号、CPU/ABI、设备型号、终端宿主、启动身份/沙箱、部署及分发方式，均待实测冻结** |
| OpenHarmony | 单独调查记录；不计入上述 HarmonyOS 验收 | 官方开源项目及 ohos 目标，可为调查提供资料 | 发行版/版本、板卡、内核、SDK、权限与宿主另列；通过不自动转移到商业 HarmonyOS |

工程推断：以纯模型/布局/合成/文件快照与平台会话适配分离来保留可移植性合理；这只是设计约束，不证明任一目标终端已可用。不以 GUI 字符绘制后端或自建 PTY/Shell/终端模拟器来补足平台证据，不改变现有产品范围。

## 2. 一手来源与证据边界

下列 URL 均在核对日访问或检索到官方正文；其中带 V5 的资料明确仅作该历史版本证据。华为当前无版本后缀文档会更新，不能视为已锁定 SDK。

| 编号及官方来源 | 能证明 | 不能证明 |
|---|---|---|
| P1 [仓颉 1.2.0 下载中心](https://cangjie-lang.cn/download/1.2.0) | 1.2.0 STS 发布日期为 2026-09-22；列 Linux x64/aarch64、Windows x64、Mac aarch64 通用包，及 Linux x64、Windows x64、Mac aarch64 的 `-ohos-1.2.0` 包 | SDK 包名不是 cjtui 的可构建、可部署或终端运行证据；ohos 包不能自动等同商业应用 SDK 全部能力 |
| P2 [1.2.0 安装手册](https://cj-docs.gitcode.com/zh/1.2.0/dev-guide/source_zh_cn/first_understanding/install.html) | 通用工具链适配 Linux/macOS/Windows；Linux x86_64/aarch64 环境要求列 glibc 2.27、内核 4.15、libstdc++ 6.0.24 或更高；macOS 12+；Windows 编译器基于 MinGW，并有功能差异 | 仅部分 Linux 发行版完成工具链完整功能测试；这些是工具链条件，不是 cjtui 最低支持版本 |
| P3 [1.2.0 交叉编译](https://cj-docs.gitcode.com/zh/1.2.0/dev-guide/source_zh_cn/compile_and_build/cross_compilation.html)；[编译选项](https://cj-docs.gitcode.com/zh/1.2.0/dev-guide/source_zh_cn/Appendix/compile_options.html) | 目标名列 Linux x86_64/aarch64、Windows x86_64、macOS x86_64/aarch64，以及 `x86_64-linux-ohos`、`aarch64-linux-ohos`，后两者标为 OpenHarmony/HarmonyOS；跨编译须配套目标工具链与 SDK | 不代表任意通用 SDK 自带全部目标运行库，也不代表 `linux-ohos` 等于 `linux-gnu` ABI、glibc 或 Linux 控制台行为 |
| P4 [HarmonyOS 当前 ABI 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ohos-abi/) | NDK CMake 的 OHOS_ARCH 列 arm64-v8a、armeabi-v7a、x86_64；DevEco 默认 arm64-v8a；文档区分 CMake 与 IDE 对 armeabi-v7a 的支持 | NDK 支持的 ABI 不是仓颉商业 SDK 支持的完整 ABI/设备集合，不能承诺三种架构均可交付 cjtui |
| P5 [华为鸿蒙编程语言演进策略](https://developer.huawei.com/consumer/cn/doc/guidebook/programming-language3-0000002593094802/) | 当前官方说明覆盖仓颉鸿蒙应用、库开发及 DevEco 支持，并说明鸿蒙 5/6/7/8 的演进路线 | 路线/总体兼容说明不能代替具体插件的最低 API、设备清单，也没有证明字符终端宿主 |
| P6 [华为官方 HarmonyOS 7 仓颉体验版 FAQ](https://developer.huawei.com/consumer/cn/forum/topic/0201221222503885537?fid=0104164651529951067) | 官方活动说明要求查配套 DevEco/系统/设备清单；指出插件 6.0.2.636 Beta 及以后开发应用的 compatibleSdkVersion 最低为 6.0.2(API 22)；部分清单需活动通过后可见 | 不是“所有仓颉 1.2 程序最低鸿蒙 5”或“最新任意插件均同一门槛”的证明；本轮没有活动权限/真实套件核对 |
| P7 [HarmonyOS 当前 hdc 指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hdc/) | 有设备端命令执行与交互 shell；`-b` 可调试应用数据目录参数始于 API 15，API 26.0.0 起增加该目录的交互 shell；需调试签名并启动应用；支持命令随系统版本不同 | 调试 shell 不等于普通发行应用获分配可交互 TTY，不证明 raw、resize、完整 ANSI/Unicode，也不证明终端用户无调试工具即可启动 |
| P8 [HarmonyOS 当前 libc](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/musl/) | 使用 musl，提供 C99/C11/POSIX 相关能力但非完全兼容；动态加载有命名空间限制 | Linux glibc 原生库不能据此复用；有 stdio/POSIX 函数声明不等于沙箱可操作终端 |
| P9 [V5 受权限限制的 libc 接口](https://developer.huawei.com/consumer/en/doc/harmonyos-references-V5/nce-on-ndk-libc-interfaces-affected-by-permissions-V5/) | V5 官方明确将 tcgetattr/tcsetattr 等 termios 操作列在 SELinux 限制项中；普通应用与调试/系统身份必须区分 | 不能把 V5 限制表无条件外推到所有当前设备/身份；也不能忽略其风险而宣称 POSIX raw mode 可直接工作。当前无版本同名 URL 本轮读取超时/503，未把它当成已核对正文 |
| P10 [V5 仓颉标准流](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/os_process_package_classes-V5/)；[isatty](https://developer.huawei.com/consumer/cn/doc/cangjie-guides-V5/os_posix_package_funcs-V5/) | 版本文档有 CurrentProcess.stdIn/stdOut/stdErr 及 isatty 接口 | 标准流可以是文件/管道/日志通道；API 存在不证明部署后的 fd0/1 是终端，更不证明全屏交互 |
| P11 [OpenHarmony 官网](https://openharmony.cn/)；[官方文档](https://docs.openharmony.cn/) | OpenHarmony 是开放原子开源基金会孵化运营的开源项目；官方资料存在不同系统类型与内核配置 | 开源项目、任一厂商发行版、华为商业 HarmonyOS 不是同一个验收对象；开发板 Linux 内核、串口控制台成功均不能替代商业真机 |
| P12 [Microsoft VT 序列](https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences)；[Apple termios 手册](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/tcgetattr.3.html) | Windows VT 有 Console mode 配置条件；Apple 文档有 termios/raw 与保存恢复路径 | 都只是平台 API 依据，不能替代 cjtui 原生构建与实际终端验收；Apple 资料为归档手册 |

当前信息的适用关系：P5 的总体演进/向后兼容说明与 P6 的具体体验版最低 API 不能合并成单一 cjtui 最低版本。TASK-001 应拿到实际 SDK/插件后按其配套表冻结；P1 的通用 1.2.0 与商业 HarmonyOS 应用套件版本号也必须分别记录。

## 3. HarmonyOS 终端路径：事实与未知

“在鸿蒙设备运行仓颉”“有 stdin/stdout”“有交互 shell”“cjtui 字符终端可用”是四层独立证据。当前只有前三层的有限文档依据，没有第四层实测。

| 候选宿主路径 | 已知事实 | 未知及验收要求 |
|---|---|---|
| PC 终端经 hdc 到商业设备 shell | P7 有官方命令路径；设备 `/system/bin` 可查可用命令；开发调试连接需要配套工具/系统 | 必须在明确身份运行目标二进制，检查 stdin/stdout 是否 TTY、termios 权限、UTF-8 字节、键盘即时输入、终端尺寸及 resize 传递、ANSI 行为与退出恢复；当前没有执行这些检查 |
| hdc `-b` 可调试应用沙箱 | API 15 起有非交互命令路径，API 26 起的交互能力另有条件 | 访问应用数据目录不等于加入已有应用进程的标准流，不证明可执行二进制、控制 TTY 或商业发行可用；工作目录变化也不能当作终端宿主能力 |
| 设备上普通应用沙箱内的现成终端宿主 | 本轮没有找到足以冻结名称、版本、启动协议和权限的一手材料 | 是否提供字符网格宿主、如何启动仓颉进程、传递 fd/按键/尺寸及恢复均 pending；没有证据就不得假定存在或不存在 |
| 设备本地系统控制台、串口、`/dev/tty*`/`/dev/console` | OpenHarmony 系统/板卡资料可提供调查线索 | 商业设备是否存在、对谁可访问、是否支持交互与字符协议均未实测；不能据 Linux 节点名、内核背景或开发板调试串口泛化 |

非 TTY 的读取/写文件成功，仅可记标准流或快照能力的证据，不能作为本产品全屏交互通过。文件快照仍需按独立契约验收，不能用一次性命令行输出替代必需交互模式。若实际商业设备没有授权范围内可用宿主，应保留 HarmonyOS required/pending 并提交具体阻塞和真实选项，不静默改成 extension 或新增 GUI 后端。

## 4. 原生 Unicode 依赖的跨平台风险

沿用 [R5 依赖结论](../../development/dependencies.md)：unicode 0.1.0 提供分段/规范化，unicodewidth 0.1.113 是唯一宽度来源，ansies 1.3.113 用于其已证实的 ANSI 能力。R5 仅 Linux x64/SDK1.2.0，尚不能证明平台集成。

本轮只读查看 R5 缓存中的 `unicode-0.1.0/unicodedata/CMakeLists.txt`、`src/data.S`、`src/library.c` 及包清单；原始 cjp 摘要与来源见 [R5 元数据](../R5/evidence/dependency-metadata.json)。上游登记来源为 [libunicode](https://gitcode.com/vchuoshen6/libunicode)，实际判断以固定中心仓包为准。事实：CMake 声明 C/ASM，先运行仓颉 generator 生成数据；ASM 使用 `.section .rodata`、`.globl`、`.incbin` 及裸导出符号；C 有 constructor/MSVC 分支；清单需要 `-lunicodedata`。原生部分不是可忽略的纯仓颉源码。

| 目标 | 工程风险与需做的验证（推断，不是已失败结论） |
|---|---|
| HarmonyOS | 用目标 NDK clang/sysroot/ABI 重编 C/ASM，不能把 Linux glibc `.a` 复制过去；核对符号、PIC/重定位、musl、运行库和打包/加载。宿主 generator 与目标库分开构建，不能在开发主机执行目标 generator。即使链接通过，终端权限仍独立验证 |
| Windows | 官方仓颉路线是 MinGW；GAS ASM、PE/COFF 节及符号规则、constructor 和 archive/链接器均须目标验证。C 的 `_MSC_VER` 分支不证明整个库兼容 MSVC，更不能替代仓颉实际 MinGW 组合验证 |
| macOS | Mach-O 的 section/外部符号约定与当前 ELF 风格 ASM 存在适配风险；AppleClang 能编 C 不代表原 ASM 能过。aarch64 与 x86_64 各自的 archive、符号及仓颉链接需实际验证 |
| 所有平台 | 数据生成、版本/摘要、完整一致性测试、许可证、包内路径及干净消费者构建分别留证据；不能以手工修改缓存成功冒充只需 `cjpm build` 的产品消费路径 |

这些风险足以要求 TASK-003 在选型完成条件中加入每个必需平台的原生构建/消费证据；不足以在未试验前宣布依赖不可移植，或自行更换已选库、复制 Unicode 数据/算法。

## 5. 本地 SDK 只读核对

2026-11-09 在已安装 `/workspace/work/validation/sdk/cangjie` 执行，不改 SDK、不编译源码：

```bash
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cjc --version
cjc --help | rg -n -C 1 -- 'target|sysroot|toolchain'
ls /workspace/work/validation/sdk/cangjie/lib
ls /workspace/work/validation/sdk/cangjie/runtime/lib
```

实际结果：`Cangjie Compiler: 1.2.0 (cjnative)`，默认 `Target: x86_64-unknown-linux-gnu`；帮助有 `--target <value>`、`--target-cpu <value>`、`--sysroot <value>`、`--toolchain <value>`；两个目录列有 `linux_x86_64_cjnative` 与 `windows_x86_64_cjnative`，没有 ohos/macOS 对应目录。帮助没有列出所有 target 的可用性清单。

故本机只证明该 SDK 有目标参数入口及上述随包目录，**没有执行 HarmonyOS 交叉构建、链接、部署或交互测试**。不根据目录推断 compiler 后端绝不支持其他目标，也不根据帮助选项推断运行库已经齐备。

## 6. TASK-001/003/004 需补的最小证据

1. 为四个必需 OS 分别记录准确 SDK/编译器来源摘要、主机/目标、OS/CPU/ABI、终端宿主及启动方式；商业 HarmonyOS 与 OpenHarmony 分开。先查商业套件真实配套表，明确兼容 API 与可获取设备。
2. 用隔离探针验证目标原生依赖、静态库链接、运行库部署及干净消费者；语言/宏验证与终端验证分别记录。现有 R5 结果不外推。
3. 在对应真实宿主验证 TTY/非 TTY、原始按键与粘贴、尺寸与 resize、颜色/Unicode/宽字符、进入/退出/取消/异常恢复；记录权限失败和宿主限制。测试外部现成终端会话不要求 cjtui 实现 PTY。
4. TASK-004 只有取得上述结果才冻结具体矩阵、快捷键及降级策略。required/planned/pending 保持到可审查的产品与平台验收证据到位；证据不足如实记录，不把 SDK 下载、官方语言能力或模拟器成功写成产品支持。
