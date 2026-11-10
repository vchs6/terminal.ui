# Linux native caret mode 25：有限能力调查

2026-11-10 19:22:19–19:23:16 UTC 原始捕获，独立目录 `/workspace/work/cursor-capability-recon`。角色请求 Sol/high；actual serving model 无可核验证据。适用系统 debugging、cloud runtime 与 completion verification 流程；没有仓颉产品修改，故未引入 CangjieSkills/SDK/CJPM。不是产品测试、正式 tests 或 A/020/008 验收，当前 caret 产品尚未实现。

**结论：XTerm 398 和 XFCE 1.1.4 / VTE 0.80.1 能报告并恢复本次 mode 25 原显隐；真实 Linux 6.12.107 tty1 能切换显隐，但在本次有界查询中没有回应，且 `CSI ?25s` / `CSI ?25r` 未恢复原显隐。不能把无回应写成“不能控制光标”，也不能把发出 restore 写成“原状态已恢复”。**

| 真实宿主 / 80×25 | 原 visible：baseline→反转→restore→进程退出 | 原 hidden：baseline→反转→restore→进程退出 | DECRQM 原文 |
|---|---|---|---|
| XTerm(398)，TERM=xterm | visible→hidden→visible→visible | hidden→visible→hidden→hidden | visible=`ESC[?25;1$y`；hidden=`ESC[?25;2$y` |
| XFCE 1.1.4 / 实际 libvte 0.80.1，TERM=xterm-256color | 同上 | 同上 | 同上 |
| QEMU 10.0.13 / Debian Linux 6.12.107+deb13-amd64，真实 `/dev/tty1`，TERM=linux | visible→hidden→**hidden→hidden** | hidden→visible→**visible→visible** | 六次查询均0字节（每次最多600ms）；随后阶段推进读到的都是实际 PS/2 `6e` |

GUI query 的九字节 hex 分别 `1b5b3f32353b312479` / `1b5b3f32353b322479`，返回值与已知起态、实际像素、反转、恢复相符。该事实仅覆盖这两个真实版本/配置，不能泛化为任意 TERM 或任何宿主的可信承诺。两个 GUI 的 TERM 来自宿主默认配置；没有在同一 PTY 换名冒充宿主。

## 实验与独立证据

`source/cursor-probe.c` 是唯一 native fixture。每个真实宿主各开两条新连接，先精确发送 `?25h` / `?25l` 建立 known-visible / known-hidden 的受控原态，然后：

1. 在相同 marker 空白单元定位 `CSI 3;9H`，查询 `CSI ?25$p`，捕获 baseline。
2. 同一连接 `CSI ?25s`，发送相反 `?25l` / `?25h`，查询，捕获 changed。
3. 同一连接 `CSI ?25r`，查询，捕获 restored。
4. 恢复 termios，fixture 真正退出；外部 wrapper / init 不输出任何屏幕字节，捕获 exited。退出码和 termios 是外部/串口证据，不能拿来替代 mode 25 恢复事实。

没有重画屏幕、移动光标、改变 shape/blink 或 marker 来“修复”恢复结果。每阶段七个原始快照、间隔至少220ms；GUI 用 ImageMagick X11 `import -window`，VT 用 QMP `screendump` 得原PPM再 lossless PNG。共168张原PNG，VT另保留56张原PPM；没有ANSI重绘图。`raw/analysis.json` 是原图的逐帧RGB差异统计，未编辑原图。

- XTerm 804×479：唯一差异是 caret `[82,40,92,59)` 的190像素；VTE 817×504：唯一差异是 caret `[81,66,91,85)` 的190像素。所有七帧均对应表中状态，退出后也相同。
- VT 720×400：caret 下划线只在 `[72,45,81,47)` 的18像素。visible 起态 baseline 七帧差异为 `[18,18,0,0,18,18,0]`，changed/restored/exited 均全0。hidden 起态 baseline 全0，changed/restored/exited 每组均 `[18,18,0,0,18,18,0]`。所以没有把单张 blink off 图误判为 hide；restore 后能看见完整的错误状态多帧轨迹。
- 每个 VT 阶段实际 `/dev/vcsa1` / `/dev/vcsu1` 原始字节全部相同；vcsa header 始终25行80列、0-based x=8,y=2。屏幕文字/属性/位置没有变化；vcsa 本身不提供 visibility，本轮不能从该header读原显隐。全部56张PPM与PNG RGB逐像素相同。
- GUI 两轮 fixture / host 各exit0；VT两轮 fixture / init / QEMU各exit0，六轮 `RESTORE_TERMIOS rc=0 equal=1`。自有Xorg、terminal、dbus wrapper、QEMU和fixture均已结束并wait回收，`raw/process-cleanup.json` 没有活动自有进程。未操作此前无关进程。

真实 VT 由既有 Debian内核、TCG `-cpu max -machine pc -m 512 -smp 1`、SeaBIOS、VGA、PS/2构成；`-display none`只关host前端。`VT_GETSTATE rc0 active1`、`KDGKBTYPE rc0 type2`、`tty=/dev/tty1`、80×25来自本fixture实际ioctl，QMP保留版本/KVM/status。独立initramfs只复制既有BusyBox并替换该native fixture，没有重跑旧产品场景、下载SDK或字体依赖。用户clipboard没有读取/查询，未发送外部消息。

原始文件入口：

- GUI：`raw/{xterm,xfce-vte}/{visible,hidden}/events.log`、`*-response.bin`、`output.ansi`、`capture-times.jsonl`、`{baseline,changed,restored,exited}-[0-6].png`、实际window/命令/版本/退出记录。
- VT：`raw/vt/{visible,hidden}/vt-serial.log`、`vt-qmp.jsonl`、`evidence/*-response.bin`、`evidence/output.ansi`、`*-vcsa1.bin`、`*-vcsu1.bin`、原PPM/PNG及退出记录。
- `raw/metadata.json` 保留捕获UTC、主仓观察commit与AGENTS/A.6/tasks/宿主可执行文件/内核hash；`raw/package-versions.txt` 和 `raw/xfce-ldd.txt` 对照实际VTE库，另通过其公开版本函数核对0.80.1。`SHA256SUMS` 索引源码/命令/制品/所有原证据。

复现命令在 `commands/build.sh`、`run-gui.py`、`run-vt.py`、`start-vt.sh`、`pack-guest.py`。先 build，再两条run命令，最后 `python3 commands/analyze.py`；run目录已存在会拒绝覆盖，复验应复制本目录工具到新目录并相应调整GUI wrapper中的固定BASE路径。GUI/Xorg/图像分析工具只属开发探查，不是产品依赖。

## 对A实现的有限技术建议（不冻结新API）

A.6要求首版终端原生caret位置/显隐、会话统一输出、完整成功提交和退出原模式恢复；TASK-020要求正常/异常/取消恢复；TASK-008要求失败不能假提交，无法确认安全同步应停止输出并报错；AGENTS第15节要求框架自动适配、普通应用无需选终端能力。基于本次事实，最小路线比较如下：

| 候选内部路线 | 本轮依据与代价 |
|---|---|
| 仅真实DECRQM可信1/2时管理show/hide，退出精确回原值 | GUI有可信已知态读取和显隐控制事实，可作为首选；无需普通用户配置。若用异步有界查询，回复与普通键盘字节必须进入现有唯一InputDecoder，不得丢失startup输入或增加第二parser；本轮没有验证产品解析/错误路径。优先记录自身状态，避免占用terminal只有一份的mode25 saved slot及其嵌套归属风险。 |
| 已验证宿主的 `?25s/r` | 两个GUI本轮可工作，VT本轮不工作。不得用“发送成功”推导支持，或用TERM名字/terminfo cnorm/civis代替读原状态。仅有无回应时，不能把save/restore当自动成功兜底。 |
| 无可靠读取/保存时保持原visibility，自动保守降级 | 框架不发送25h/l，仍可CUP定位；逻辑caret继续按原clip、焦点域及遮挡规则计算。它能避免主动改坏未知原显隐，但native隐藏/显示无法保证：原visible时即使本帧无caret请求，宿主原cursor仍可能可见；原hidden时定位也不会让它出现。能力分支留在框架，普通应用不处理。此最小候选需要诚实标明A.6设备效果限制，不新增软件cursor、第二renderer或API，也不把退化效果冒称严格原生caret全通过。 |
| 未知仍改显隐，退出一律show/猜初态 | hidden起态会被改坏；这是best-effort重置而非恢复，应排除其“严格恢复”承诺。 |
| 严格合同下，未知且无可证恢复路径则不开始该不可恢复输出并诊断 | 与008诚实失败围栏一致，可保住原态；但自动拒绝不能等同于“所有Linux终端caret完成”，也不满足普通用户无感使用目标。不能把这个限制藏进用户能力配置。 |

本轮没有测其它VT读取/保存机制，因此不声称“内核永远不存在任何路径”；准确缺口是**已测这些序列不能同时做到该VT的可用显隐和精确原态恢复**。若坚持所有已列Linux宿主、严格原态恢复、首版native caret三者，A实施前仍需有证据的额外机制或正式裁决自动降级语义；不需要第二renderer、GUI字体或要求普通用户选终端。现有三宿主证据不足以直接把A/020判PASS，异常/取消/部分写失败恢复也均未在本探针验证。
