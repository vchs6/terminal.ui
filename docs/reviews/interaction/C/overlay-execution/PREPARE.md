# TASK-111 PREPARE — READY（仅准备，非执行准入）

执行型独立测试角色；工作目录 `/workspace/work/overlay-execution`。当前固定候选 `f8f0493a7f5aa3b74bd59bdc7e6d82af6696426d`（替代61e4de9d）；scoped TASK-110 尚审核，收到主代理正式 GO 前不构建、不跑产品。只编辑本目录，不改封存 B、正式产品、测试、规格或 main；不读作者 report、不联系作者、不派子代理。

**已读依据：** terminal.ui/AGENTS.md（尤其 11.1、13.2、15），变更 tasks.md 的 Shared L3、TASK-111 与 C-01–05，design C.1–7/shared errors。实际读取 cloud `superpowers:using-superpowers`（子角色豁免启动流程）和 `verification-before-completion`；本阶段只验证准备文档，正式执行按验收与 AGENTS 11.1 复用有效证据。模型仅为派单要求，不认证实际 serving。

**待主代理确切交接：**

1. 正式 GO；TASK-110 接受记录路径/hash及固定产品完整 SHA（候选短 SHA 不充当准入）、可独立取得的 source snapshot/bundle 路径与 SHA256；TASK-108 冻结测试完整 SHA、文件/hash清单、`bash tests/interaction_c/run.sh` 入口及其 README。仅交契约、源码/测试、命令与 raw/hash，不交作者推理/自评。
2. 固定 contract/design/spec/admission/interface-map 的路径/hash；本候选相对已接受 A/B/080/088 的相关内容变更清单；必要既有回归命令及可复用证据的 source/dependency/environment/config/scope/hash 映射（不冷跑历史全套）。
3. 088 SDK1.2.0/stdx 与 registry/cache 交付路径、确切版本/hash、独立配置方法及离线依赖来源；正常 build/bundle 命令，公开 C 消费者与 `examples/overlay_composition` 的固定源码/hash、运行模式/输入序列、手工 golden 与真实 PTY 场景说明。不得交作者 target/private cjo 作为消费制品。
4. 真实宿主共享桌面恢复/连接方式和捕获依赖路径，允许采集窗口/输入的显示会话；需按实际载入版本复核 XTerm398、VTE0.80.1、QEMU Linux6.12.107 kernel VT。当前只读检查：未发现 Xorg/Xvfb/终端/QEMU 运行，`/tmp/.X11-unix` 空；xterm、xfce4-terminal、libvte、QEMU、kernel 路径仍存在，尚未验证版本/可运行性。缺运行中 X server/可连接 display 与宿主窗口，不能当作 GUI 已就绪。

**GO 后执行清单：**

- [ ] 核固定 source/test/contract/hash；隔离 SDK/registry/cache 配置并记录实际工具版本。运行冻结 C 入口，逐命令保存 argv/env（脱敏）、stdout/stderr、真实 exit、时间及 hash；只补 admission 相关失效回归。
- [ ] 正常 `cjpm build` / mandatory `cjpm bundle`，不 skip。干净解包，正式公共 C 消费者与公开例子仅改 manifest dependency path；保存该唯一差异、源码/制品/hash及实际运行 exit。
- [ ] C-01 域隔离/取消/interrupt；C-02 owner隐藏卸载、非顶层/兄弟与一次焦点恢复；C-03 opaque/hole/阴影遮caret、主题、host/滚动anchor/最新底层；C-04 pending/stale/非法参数/cleanup错误及恢复；C-05 同 SettingsPanel/model 两实例、children与节点/主题/滚动状态。headless 手工 golden 原始输出与真实设备证据分别记录。
- [ ] 沿用封存 B 的采集方法（只读 tools/gui.py、record-host.py、host-facts.py、vt.py、start-vt.sh、vt-init.sh），另建 C 采集输出。XTerm native printer、VTE native rows、VM `/dev/vcsa1` 与 QMP screendump；保存原始 PNG及hash、native cells、实际 loaded host版本/配置/尺寸/能力来源、输入/输出 raw、termios前后、模式恢复、实际 binary exit（另列host/QEMU exit）。不可换 TERM 冒充宿主或把旧图/旧结果当 C 新证据。LinuxVT 明示 VM，非物理硬件。
- [ ] 逐 AC 形成 passed/failed/insufficient_evidence 与原始证据索引；source/test/bundle/consumer/PNG SHA256 全链。失败只回主代理，不修产品/测试；环境缺失保持 insufficient_evidence。交付 run/、bundle/ 对应归档映射供主代理集成，不自行改任务权威状态。

**采集器已备（未跑候选/guest）：** `tools/h01_gui.py`、`host_supervisor.py` 与 `h01_vt.py`、`vt-supervisor.c`、`vt-init.sh`、`pack-vt.py`，仅外部collector；XTEST/窗口resize/strace字节解析只读复用B方法。实际冻结设备消费者文件为 `tests/interaction_c/src/native_fixture.cj`（无 device_overlay.cj）；与 pty_driver.py/native-host-recipe/case-matrix/main 及所读B工具的SHA256在 `environment/collector-preparation/input-hashes.json`。真实宿主环境状态见 ENVIRONMENT.md。

**输入/字节来源：** 严格五模式 interrupt/prevent/escape/signal/callback-error；按冻结顺序真实键盘 m→p→c→x，trace固定 `Cc;Tc;Tb;Cb;Td;Ca;|0|0`。其后真实Ctrl-C、prevent后q、Escape后s/q、向actual binary PID发SIGINT、或真实Shift-1产生!；文件ack与cleanup内容来自原公共消费者。GUI不伪造DECRQM回复；终端自动回复保留在actual read(0) raw，写出来自actual write(1) raw，输入事件/QMP单独留记录。F6打印由XTerm宿主绑定消费；VTE采集原生rows；VT由/dev/vcsa1和/dev/vcsu1读原始cells，QMP只截图/键盘。SIGINT控制通道只通知外部supervisor向实际消费者PID发信号，不给消费者伪输入。退出barrier位于产品已退出之后，留窗口/VM供原始恢复PNG采集，释放后另存宿主/QEMU exit；实际binary exit从其PID strace终态核对，不混同tracer exit。VM完整termios结构前后另存原始bin。

**已检查/仍待运行：** Python py_compile、C gcc -Wall -Wextra -Werror -fsyntax-only、sh -n、空PTY termios JSON序列化与无产品xdpyinfo均exit0（逐命令cwd/UTC/raw在 environment/collector-preparation）。未编译supervisor、未打新initrd、未运行native采集或冻结C；GO后才编译collector、按固定actual binary打流式initrd并运行。GUI/VT采集与恢复barrier尚未实际验证，不能声称C或新collector行为通过；失败按需只修外部collector并保存失败raw。不抄旧PNG/cells/结果；native内容只是实测证据，不替换冻结headless预期，不扩展H01五场景。

**独立输入已备：** `product/` 为本地 `git clone --shared --no-checkout` 后稀疏检出固定f8（约12MiB，无target；不复制历史归档/SDK）。产品包边界、tests、必要合同及8门前置proof到位；currenttable八项ACCEPTED均祖先/路径静态核对成立。dc0e07e→作者alias f1a982d8→root alias6687220d→f8 的 tests/interaction_c 字节差异全空；collector五个冻结输入与先前准备相同。源码/合同/测试、SDK800文件、deps375、stdx371、UCD、env/config和工具prehash在 `input-preparation/`，deps375/stdx371与既有接受基线逐文件全等；cjc/cjpm独立版本命令均1.2.0/exit0。自己的root/全部消费者配置文件名为cangjie-repo.toml，指向获准共享 `/workspace/work/viewport-tests/cache`；服务离线且未启动，不继承不完整缓存，不使用作者target。源SDK/stdx/UCD路径按主代理确切交付，未复制。实际公开例子目录为 `examples/overlay`（不是overlay_composition）。

**复用映射已备：** `input-preparation/reuse-map.json` + native-reuse-bindings.json：19项native/decoder/capability绑定与B已接受内容全等，仅复用其有限上游事实；B layout/focus/viewport、C resolver/theme_candidate_validation 有变，不能把旧B/主题整体验证改称当前C通过。依AGENTS11.1不冷跑旧B真实宿主/资源/clean或历史全套；GO后执行新C及admission所需受影响边界。作者获准pure raw仅开发证据，不替代111独立正式入口、mandatory lint/bundle、clean消费、新PTY和三真实宿主。当前仍待scoped110 clean与正式GO；若QA改动仅更新受影响输入。
