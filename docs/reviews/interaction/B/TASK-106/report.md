# TASK106 独立执行

固定 source `62039552a26da295dcd710d7cfc40cb9e43ca5fd`：**PASS_SCOPED_EXECUTION**，本轮必须执行项无产品失败。请求角色 Sol/medium；实际 serving 配置无法独立认证。依据唯一 TASK106 brief 的 ACTUAL GO 和105最终源审查；测试、产品、契约与 main 均未修改，无作者 target/报告/自评输入，无子代理。

| 验收 | 实际结果与原件入口 |
|---|---|
| B-01 根滚动、组合、真实方向输入 | `raw/b-normal` 普通构建/直接执行0；`raw/b-device/detail` 原固定PTY五阶段及三个序列0。完整31原oracle、附加 bareCanvas、八公开消费组均由冻结入口执行。 |
| B-02 有限布局、逻辑范围、失效与夹取 | 同上；独立 review9 `raw/b-review9`0，正常大同进程再次执行全部九项0；它们是九个义务的两种观察，不能计作18项。资源原固定runner `raw/b-resource-gnutime`0，GNU Time实测0.02秒、最大RSS26,812KiB；仅描述资源，不能当内部pass计数。 |
| B-03 嵌套、caret/同回调resize、Unicode | 固定headless/PTY0；真实XTerm/VTE的四场景和真实LinuxVT的三个ASCII场景全部0，公开状态与native物理网格逐阶段一致。 |
| B-04 控制、生命周期、异常边界 | 正常B与review9均0；`raw/node-reference` controls及新进程500守卫0，实际GC从0到1；`raw/theme-canvas` finite/control/subtree各0，失败候选保留旧theme/session/root/canvas状态。 |
| 必要受影响回归 | `raw/affected-a-headless`、`affected-runtime`、`affected-themes`、`affected-async8`均0；async仅准入的 lifecycle/session-fence/queued-restart/atomic-caches/observability/event-post/multi-application/exception-boundary，保留原正向gates。 |
| 正常制品与公开消费 | `raw/bundle` 正常mandatory lint+bundle0，警告完整保留。CJP SHA256 `7aae8c78c6bac15a6dd618a8616646b3bbc23feb3c54d79d1f610d8799474885`，208成员全部逐字节等于固定git，无预编译包产物。干净解包library、原正式B全入口、NR两进程、ThemeCanvas三模式及公开viewport示例 build/--smoke全部0。只允许manifest依赖路径变化，逐文件核对见 `raw/package/consumer-byte-bindings.json`。 |

逐原matrix入口与source位置见 `scope.json`；每条真实argv/cwd/UTC/exit/stdout/stderr、pre/post源及SDK/config/UCD hash见 `raw/<command>/`，汇总 `raw/identity/completed-commands.json`。375上游源文件与371官方stdx文件pre/post身份一致；共享既有SDK1.2、官方stdx和正常registry源缓存，独立配置/构建输出。未复制SDK/cache或借作者cjo。I009至多两根pass和Nearest内部tie分支采用105源审查，不伪造公开计数。

真实宿主证据映射在 `raw/identity/host-index.json`。XTerm398及Xfce4/VTE0.80.1来自真实程序/已加载库；字体DejaVu Sans Mono16，Xorg1.21.1.16，精确版本/config/font/二进制hash见 `raw/host-facts` 与各launch/home-config。XTerm四场景在 `raw/gui-hosts/xterm-*`；VTE的pty在 `raw/gui-vte-hosts/vte-pty`、其他三个在 `raw/gui-vte-final/vte-*`。共64张成功GUI原PNG，含每阶段两帧。resize实际修改物理窗口，native40×10及4×1/2×1与TTY readback一致，不以TIOCSWINSZ或Frame字段冒充物理大小。原query、每session一次产品query、退出0、原cursor态及termios恢复保留。

真实Linux内核VT在 `raw/kernel-hosts-fenced/{pty,caret-resize,same-turn}`：Debian6.12.107内核、uid1000产品、tty1设备/VT_GETSTATE/KDGKBTYPE、真实VT_RESIZE及TIOCGWINSZ、完整VCS/VCSU、QMP原PNG、guest strace/termios/真实退出0均保留；27张原PNG。冻结100 Down达到offset76；真实40×10保留76、14 Down到90、恢复80×24夹回76。自然caret缩小到2×1 offset11；同回调原`4/9`握手后实际2×1，新caret得到offset1/native`bc`及cursor(1,0)，手动0得到`ab`。这里是QEMU运行的真实LinuxVT，不声称物理硬件或VT完整Unicode字体覆盖。Unicode完整组合/ZWJ/CJK字节与损伤检查在固定headless/PTY；真实XTerm/VTE另观察冻结Unicode序列。

保留的环境/观察器历史：默认time不存在127，后显式官方GNUTime原runner0；VTE逻辑softwrap范围被误当物理行、JSON发布竞态、4列range末列exclusive边界，均保留旧C/module/driver/hash及失败输出后最小修观察器。原VTE完整visible/write_contents已有`abcd`、物理4×1，证明修的是采集末列。首两VT控制器15秒界限/旧state与频繁完整VCS串口输出造成采集失败；最终改为只轮询公开profile、阶段native围栏，保留真实100键、原oracle及全write trace，90秒/阶段有界完成。另有VM pack inventory父目录缺失及未source SDK导致wrapper前置退出，均非产品执行结论。详见 `findings.json`；不隐藏失败或循环改产品至绿。

按AGENTS11.1复用旧A仅限逐文件相同的decoder/native writer/probe/capability/glyph实现及同SDK/stdx/UCD/宿主工具配置，绑定见 `raw/identity/reuse.json`。旧证据不覆盖新的B布局、owner/session、clip/caret/scroll/Unicode damage；本轮均实际执行。旧087/091/A原件未修改。

M01 getter axes onMount初始Off仍明确deferred TASK024；wholechecker TASK023的themes允许表及composition/benchmark最终门禁仍OPEN。完整Linux交付、M2、完整widgets/Menu/Editing、Keyboard117、物理PageUp/PageDown、HarmonyOS均未关闭。本报告不把源审查或有限执行提升为完整release验收。

`manifest.json` 索引原件字节；`artifacts.sha256`校核索引/报告。ELF/CJP/SDK/cache/VM镜像以 `omitted-artifacts.json`精确外部hash引用，归档不复制完整source/历史资产/二进制。保留同一原件供107核对，完整B归档仅由root后续一次处理。
