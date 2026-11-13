# TASK-111 环境 READY — 2026-11-13 UTC

只恢复/核对测试环境，仍等正式111 GO；未构建/执行候选 C、旧 B 或任何产品套件，未启动 QEMU guest，未复制 SDK/VM 磁盘。

- 按封存 B `tools/gui.py` 同法，以既有 dummy config 启动 Xorg `:199`，`xdpyinfo` 及 `xwininfo` 实际 exit 0；Xorg 1.21.1.16，PID 5544。XTerm 与 VTE 仅运行空白 bash，窗口标题含 environment only。
- 真实 XTerm 输出 `XTerm(398)`。xfce4-terminal 1.1.4；动态调用 libvte 版本函数得到 0.80.1，实际终端进程 PID 5875 的 `/proc/.../maps` 映射 `/usr/lib/x86_64-linux-gnu/libvte-2.91.so.0.8000.1`。终端启动器仍运行，exit=null，未将其记作成功退出。
- 首次终端继承只读 HOME 产生 fontconfig/dconf/xfconf 错误；比较 B 的独立 HOME/XDG 方法后，仅对本次测试宿主改用 `environment/host-home`，重新启动后上述错误消失。保留首次及重启 raw；现仅剩无 session manager 的独立测试窗口提示。VTE 1.1.4 提示 terminalrc 迁移至 Xfconf，正式采集须记录实际有效字体配置，不能只据旧 terminalrc 声称已应用。
- QEMU 实际 `--version` 为 10.0.13（exit 0），Linux kernel 文件标识 6.12.107+deb13-amd64。已有 kernel/BIOS/VGA ROM/QEMU/VT supervisor/VTE采集模块可读并已记录 SHA256；VTE模块 `ldd` exit 0。这里只核文件和工具，未验证 guest 启动；LinuxVT 始终是 VM，非物理硬件。
- `environment-only.png` 为本轮原始 X root 捕获（shell环境），只证明采集工具可调用，不是任何 C 行为证据。原始 stdout/stderr、命令 argv/cwd/UTC/实际 exit、进程存活状态与文件hash在 `environment/`，索引 `environment/SHA256SUMS`。
- 云环境状态工具返回 remote_desktop enabled=true、state=unknown；可发现工具中没有 desktop js / open_in_codex。已确认测试 X display 可连接，但官方共享 Desktop viewer 连接尚不能验证。若正式111要求用户可观看的官方桌面，仍需宿主提供对应工具/已连接 viewer；本轮不声称该项已恢复。

本记录取代 PREPARE.md 中“无运行中 X server”的初始观察；其余正式输入清单仍有效。磁盘剩余约1.4GiB，准备证据体积很小。下一阶段只补当前 C 必需原始证据；未变上游证据按 AGENTS 11.1 复用。
