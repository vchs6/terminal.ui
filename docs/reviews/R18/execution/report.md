# TASK151 independent execution

2026-11-10 UTC。正常构建、正式 278 配置、14 个真实宿主 profile、正常 bundle、实际解包公开示例构建与运行已取得证据；现另补齐正式 README 要求的真实宿主正常/错误/取消自动标题清理三例。**本报告提供执行事实，最终独立验收由 TASK152 判断。** 完整发布 checker 仍退出 **1**，不能据此宣称完整 Linux 发布或 TASK030/041 完成。

初次交付漏了 README:56 对实际宿主 error/cancel restoration 前后状态的明确义务；278受控PTY与14个显式r恢复profile不能覆盖这个缺口。root转达后仅补三例，未重跑已有效的278/14/包/trace。初次封存的 report/findings/results/manifest/artifacts 原bytes和SHA保存在外部 `initial/`，见 [初次版本索引](initial/README.md)；原先结论不被静默覆盖为“起初证据已齐”。

本角色只执行与观察；未改产品、正式测试、main 或任务状态，未派代理、未读取 TASK149 作者报告/进度/推理或与作者沟通，未读取/复制/哈希 SSH 私钥。父角色指定 Sol/medium；实际 serving model 无独立可核验来源。

## 固定对象与命令证据

| 对象 | 固定值 |
|---|---|
| product/base | `83094ca92acab37ed0a38042e2e40ead55049f41` / `04a5289361d990e5a340ace22bbd50c9b805a9d9` |
| 独立 checkout | root `11729c23da37395efbb941457a2dc0ce92027051`；产品区域与固定 product 内容一致 |
| final official test | `f8b95815616c850145b647aae57e082c7915dab0`，包含 namespace 修正及独立 S007 supplement |
| test tree | `4bf3044fb7c3a64d0e918455401f4cf214b26638` |
| SDK | Cangjie Compiler / CJPM `1.2.0`，x86_64-unknown-linux-gnu |
| 实际正式 consumer SHA256 | `dc5c0dde2548b9bd9ac74d5a390e82b6a2ee65cdf5777eb6668e2fda74a3677a` |
| 外部原始 CJP SHA256 | `51ece35ab68c3391f796407d7452decdb89b3f625a7b9a8eb7f468865706a7b2` |

[产品逐文件 hash](scope/product-source.json)、[正式测试逐文件 hash](scope/formal-tests.json)、[contract hash](scope/contracts.json)、[SDK 文件 hash](scope/sdk-files.json)、[只读依赖 seed hash](scope/seed-files.json)、[配置原文与 hash](scope/configs.json)、[实际动态运行库](raw/dynamic-runtime/stdout) 保留来源。root 和每个 consumer 均使用独立可写 cache，复制既有只读 seed，复用 `127.0.0.1:18973` registry，未启动 relay。seed 的 310 个文件最终仍相同，见 [最终核对](scope/seed-final-check.json)。原始源码/SDK/cache 不进入 curated。

每个阶段的 `raw/<stage>/command.json`、`execution.json`、`stdout`、`stderr`、`exit` 给出 exact command、cwd、UTC、真实返回值。构建和测试使用固定 SDK env 与 UCD archive；正式 runner 直接运行实际 binary，没有用 `cjpm run` 退出码替代。

| 阶段 | 实际命令/结果 |
|---|---|
| 正常库构建 | `cjpm build`；[exit 0](raw/build/execution.json)，23:26:49–23:28:05 UTC |
| 正式完整执行 | `tests/session_extensions/run.sh all`；[exit 0](raw/formal-all/execution.json)，23:29:46–23:31:00 UTC，**278 cases / 0 failures** |
| 正常分发包 | `cjpm bundle`；[exit 0](raw/bundle/execution.json)，**331 条未抑制 advisory** |
| 实际包全成员比较 | [exit 0](raw/package-inspect/execution.json)，138 regular members 全部逐字节匹配固定 product git blob |
| clean 解包公开 consumer | 原包 `examples/session` 正常 `cjpm build`；[exit 0](raw/clean-build/execution.json)，未改示例/库源码 |
| clean 示例直接执行 | [真实 script PTY](raw/clean-example-pty/execution.json)，c/t/r/q，binary exit 0，完整 termios 相等 |
| 完整发布 checker | 原样 `node .../scripts/check-bundle.mjs <actualcjp>`；[exit 1](raw/full-bundle-check/execution.json)，[原错误](raw/full-bundle-check/stderr)：缺 `examples/composition/cjpm.toml` |

正常 lint 未跳过、未压低等级、未隐藏警告。[advisory 计数](scope/bundle-advisories.json) 由本次日志独立统计；331 不是沿用作者观察。实际包的 [138 成员清单](scope/package-members.json) 同时记录外部 CJP hash，成员原始 bytes 与 git blob hash。仅三个 `.gitkeep` 空目录占位被正常 bundle 省略；没有把生成的 `.a/.o` 列作应分发源码。composition/benchmark/full release 边界仍由后续门禁处理，完整 checker 的失败不被本次 scoped PASS 覆盖。

## 正式故障、上下文与资源证据

[完整原始矩阵](raw/session-matrix/summary.json) 与 [正式 stdout](raw/formal-all/stdout) 保留 278 配置。每个实际 TTY case 留 `session.raw`、`results.tsv`、native syscall/sequence/open/close/signal log、`wire.bin`、`all-wire.bin`、真实 tty/pid、before/after termios、launch 和 `check.json`。headless 留真实 stdout/stderr 与结果，未 open native device。预期业务/输出/cleanup 异常由公开 consumer 捕获并记录；consumer exit 0 不被单独当成正确，正式 oracle 还检查预期错误、首错/聚合、计数、wire 和 reopen。

S007 四个重点原件分别是 Direct/Tmux/Screen 的 set offset0 与带 callback/UIcleanup 异常的新增 Direct case：`038-fault-set-Direct-0`、`125-fault-set-TmuxPassthrough-0`、`230-fault-set-ScreenPassthrough-0`、`277-fault-set-Direct-0-aggregate`。完整 push 后零字节 set 失败仍安全 pop 一次；部分 set 则严格停止所有后续输出，包括 pop/屏幕/恢复控制，并拒绝同进程 reopen。零字节失败允许清理后新 run。正常/stop/回调异常/UIcleanup/nativecleanup、EINTR、成功 short writes、EAGAIN、write=0、native allocation seam、每个不完整 wire 偏移、原屏幕部分失败、深层防别名和无设备上下文均由正式矩阵覆盖。native allocation seam 不扩大为 managed heap/OOM 证明。

fixture selftest 的 22 checks、7 deliberate negatives、namespace controls、三 route 原生安全 pop 与 39 supplemental negatives 原件另保留在 `raw/fixture-artifacts`；这些是夹具证明，不冒充产品测试。

按 AGENTS11.1，受影响的 native-session、runtime-core、runtime-session、application-lifecycle、colors、capabilities 复用独立150已核验的原始记录，而非重跑无变化内容。[复用清单](scope/regression-reuse.json) 在本角色核对 95 个相关源码 hash 和 12 份原始 log/exit hash；同 product/deps/SDK/env/config/scope，新的 final test 树另已完整执行。原 runtime-session 中预期 abnormal child exit1 恢复场景不被改写成“所有子进程均0”。

另对同一正式 consumer 的三个 declared route 进行实际 `strace -ff -e trace=process`，[直接执行记录](raw/process-trace/execution.json) exit0。15 份原 trace 只有三次最终 consumer 的 execve；clone/clone3 均是 `CLONE_THREAD`，没有产品 fork/vfork/其他 exec/shell/clipboard 工具。GUI 的 `product-processes.json` 快照未获得进程条目，不能作为无子进程证明；此处使用真实 syscall trace 与固定源码审查的边界证据。

## 14 个真实宿主 profile

所有行使用上面的同一最终 consumer SHA。XTerm **398**、XFCE **1.1.4** / VTE **0.80.1**、tmux **3.5a**、screen **4.09.01**、Xorg **1.21.1.16** / dummy；[实际版本输出](raw/host-tool-versions/stdout)、[stderr 版本](raw/host-tool-versions/stderr)、[设施文件 hash](scope/host-facilities.json) 留存。每次新建私有 Xorg `:173` 前拒绝现有 socket/lock，独立 HOME/XDG/dbus/mux socket/SCREENDIR；没有连接用户 DISPLAY 或用户 clipboard。

真实 XTEST 输入 c/a/b/r/q；每 profile 留 initial/A/B/restored 原始 PNG、真实 X properties/icon 原始 hash、已知自有 selection seed 与完整 UTF8 selection bytes、native grid/viewport、全 outer PTY stream、产品 transaction wire、实际 tty/grid/termios、host config/完整 launch argv/env、UTC 和直接退出。这14个profile共 **56 张原始 PNG**，加下节自动清理三例8张，总计64张。XTerm 为1004×536，VTE为1017×561；tmux child实际100×27，其他 child100×28。标题不是由截图或 ANSI 推测，clipboard 不是由发送成功推测。

下表“写入”仅表示独立夹具观察到私有 CLIPBOARD payload；所有产品完整发送结果仍是 `SentUnconfirmed`，不产生 `Applied` / `RestoreConfirmed`。

| Profile / 正式 manifest | 外部实际效果 | 正式 oracle |
|---|---|---|
| [xterm-default](raw/hosts2/xterm-default/manifest-corrected.json) | OSC52 默认拒绝，seed保留；标题 A/B/原值 | exit0 |
| [xterm-enabled](raw/hosts2/xterm-enabled/manifest-corrected.json) | SetSelection允许、GetSelection仍禁；完整写入；标题恢复原值 | exit0 |
| [xterm-titleoff](raw/hosts2/xterm-titleoff/manifest-corrected.json) | clipboard写入；allowTitleOps=false，标题始终原值 | exit0 |
| [vte-default](raw/hosts2/vte-default/manifest-corrected.json) | 静态 --title覆盖；标题不变、clipboard拒绝 | exit0 |
| [vte-dynamic](raw/hosts2/vte-dynamic/manifest-corrected.json) | dynamic replace，A/B后pop为空字符串；clipboard拒绝 | exit0 |
| [tmux-default](raw/hosts2/tmux-default/manifest-corrected.json) | 默认 set-clipboard external，外层标题与seed不变 | exit0 |
| [tmux-allow](raw/hosts3/tmux-allow/manifest.json) | set-clipboard on + set-titles；写入；恢复初始 pane hostname | exit0 |
| [tmux-outer-deny](raw/hosts2/tmux-outer-deny/manifest-corrected.json) | tmux允许但外层XTerm拒绝，seed保留 | exit0 |
| [tmux-pass-off](raw/hosts2/tmux-pass-off/manifest-corrected.json) | 显式单层wrapper，allow-passthrough off，外层不变 | exit0 |
| [tmux-pass-on](raw/hosts2/tmux-pass-on/manifest-corrected.json) | 显式单层wrapper + allow-passthrough on；写入、恢复外层原值 | exit0 |
| [screen-plain](raw/hosts2/screen-plain/manifest-corrected.json) | direct标题A/B；Unknown stack不push/pop，B保持；seed保留 | exit0 |
| [screen-pass](raw/hosts2/screen-pass/manifest-corrected.json) | 显式单层wrapper；写入并恢复外层原值 | exit0 |
| [ssh-enabled](raw/hosts4/ssh-enabled/manifest.json) | stock loopback SSH到真实remote script PTY；local XTerm允许、写入 | exit0 |
| [ssh-denied](raw/hosts4/ssh-denied/manifest.json) | 同真实SSH链，local XTerm默认拒绝，seed保留 | exit0 |

XTerm/mux 使用宿主原生 print/capture-pane/hardcopy，未从 wire 另写终端解析器。VTE 两行使用明确插装的私有 GTK module，真实 `TerminalWidget` 上 `vte_terminal_get_text()` 导出当前 viewport，四阶段各有原生 widget/PID/28×100 metadata。该文本不是完整 cell styles/宽字符续单元序列化；不能把“oracle非空”升级为完整 cell 证明。原生 range/contents 输出仅辅助保留，不以含 history 的 contents 冒充当前 viewport。既有独立76 controls的证据仅按原范围复用，包含 empty clipboard owner0；不宣称任意 populated clipboard 或时序下完全无干扰。产品本次实际clipboard seed/payload由独立X11观察，图片图标属性真实hash前后相同；属性缺失也如实留原始 xprop 文本。

SSH 是现有 stock sshd 自建 `127.0.0.1:22473`，不请求 SSH PTY（`-T`），远端由真实 util-linux `script` 建100×28 PTY，未用 patched sshd。原始 client log证明 publickey auth、negotiated kex 和 Exit status0。远端实际 `TERM=dumb`，没有通过换TERM模拟宿主；source SDK env仅让同binary找到真实运行库。client 私有 PTY另保存termios→raw -echo→ssh→恢复，远端 native before/after也相等。loopback不扩大为跨网/resize/disconnect/Wayland证明。

正常/取消/业务和cleanup故障在278受控真实PTY矩阵已测；未在14个profile重复整套相同fault矩阵。另按正式README补充下述实际XTerm自动清理前后证据。旧host-only recon没有计入这14行产品通过。

## 补充：真实 XTerm 自动清理生命周期

正式 `tests/session_extensions/README.md:56` 明确要求 error/cancel lifecycle modes 还须采集实际宿主前后状态。现以同一 `dc5c…3677a` binary、冻结 XTerm398、Direct/DeclaredSupported title-stack，在新的自有Xorg上直接运行原有 `ledger-close`、`ledger-error`、`ledger-cancel` 模式，未修改正式consumer、产品或oracle。每例输入x创建scope；没有发送r或调用显式restore。外围shell仅在正式host-consumer已返回、termios已记录后静默等待，以保留真实XTerm窗口供清理后的属性/截图/native print观察；不延缓或修改产品cleanup。

| 实际模式 / 原始目录 | 输入与实际标题 | 结果与资源 |
|---|---|---|
| [ledger-close](raw/lifecycle-hosts/ledger-close/launch.json) | x后正常app.stop；before/after均为原始标题。单次回调过快，未宣称捕获中间B截图 | save+A+B+pop精确26bytes；cleanup.count1；consumer/host exit0；termios相等 |
| [ledger-error](raw/lifecycle-hosts/ledger-error/launch.json) | x后实测owned标题B并捕获原PNG/native grid，再真实XTEST e触发业务异常；之后实际标题回原值 | callback主错误保留；UIcleanup和native-close返回值故障两项原样聚合；仍自动pop一次，native实际close0；consumer/host exit0 |
| [ledger-cancel](raw/lifecycle-hosts/ledger-cancel/launch.json) | x后实测owned标题B并捕获，再真实XTEST Ctrl+C取消；之后实际标题回原值；未kill产品 | run.failed=false；自动pop一次，consumer/host exit0；termios相等 |

错误例的native seam只在真实close完成后注入返回值失败，不能称“真实termios恢复失败”；其 `run.primary=SESSION_CALLBACK_SENTINEL`、`run.extras=2`（UIcleanup sentinel及terminal restore failed）与native close0/inject1原件均保留。每例保存初始/自动清理后的真实WM_NAME/_NET_WM_NAME/图标属性、原始PNG、原生XTerm print、完整outerstream、wire/native/results、实际hostPID/_NET_WM_PID、config/argv/env/hash/UTC、native termios与真实退出。错误/取消还保存退出前的owned-B阶段；正常快速结束由原始完整push+两次set+自动pop证明scope存在，不能凭缺少中间截图否定或伪造其时序。

[新执行命令与退出](raw/lifecycle-host-launch/execution.json)、[宿主原始summary](raw/lifecycle-hosts/summary.json)、[正式runtime oracle与外部事实断言结果](raw/lifecycle-hosts/verification.json)、[核验命令exit0](raw/lifecycle-verify/execution.json) 和 [collector源码](scripts/lifecycle-hosts.py) 均保留。`verify-lifecycle.mjs` 直接导入未改的正式 `verifyLive`，不改变其预期值；额外独立检查前后真实标题、PNG/native-grid hash、scope只在cleanup消费、主错误/cleanup聚合及close/termios。`host-oracle.mjs` 的c/a/b/r/q schema未被伪用于这些不同lifecycle模式。三例均只有一个自动pop、没有Applied/RestoreConfirmed；Xorg实际exit0且私有socket移除。

此补证修正初次执行覆盖缺口；它不预设TASK152最终验收结论，也不将三例算作新增正式runtime matrix配置。

## 原始失败与复核

[执行夹具尝试清单](scope/helper-attempts.json) 逐条分类，原始 stderr/失败manifest/PNG/fullstream均保留：只读sshd launcher无执行位；manifest absolute binary被正式join拼接；tmux启动改caption使原窗口查找失效；SSH远端缺SDK loader路径；ssh -T本地canonical键输入未转发；一次 recorder现有目录保护和一次离线helper误计summary.json。修正仅限本角色 launcher/manifest/证据helper，没有修改正式 expected/oracle或产品。

11个实际GUI/mux运行的最初oracle在最后binary文件打开处ENOENT，之前语义断言已执行；原manifest/原失败保留，新增合法相对路径 `manifest-corrected.json`，同一正式oracle离线复验exit0。tmux-allow与SSH使用fresh真实运行；未把失败attempt覆盖成通过。每轮host结束后的Xorg/sshd退出与socket清理留在 `raw/hosts*/summary.json`。最终私有运行HOME已清理。

[首轮离线复核](raw/verification.json) 在23:36:44 UTC完成 **906 项原始证据/hash断言**：278矩阵、14host、56PNG、三实际进程trace、包成员/binary和清理均匹配；它不包含后补的三例自动清理。补证的原始独立核验另在上节链接。906是证据复核数量，不称906产品测试。首次helper计数错误及修正源一并保留。最终证据树 hash 在所有宿主/Xorg退出以后生成。

## 范围与交付

当前 `83094ca` 的 **actual kernel VT 产品执行未进行**。按root对既定151卡/冻结矩阵的说明，151覆盖两GUI/mux/SSH、278故障资源和headless NoDevice；真正内核VT/字体/map及平台组合由094→096/097与最终041执行。旧6a7b或OSC VT只保留为历史host/parser事实，未标当前产品PASS。输入粘贴、编辑cut/revision/undo、完整composition/benchmark/checker、完整Linux release及其他平台不由本次关闭。

本目录的 report/findings/results/scope/raw/scripts 与逐文件manifest为独立交付；`curated-r18-execution`仅包含允许的有限证据、原PNG和hash。原始 ELF/CJP/CJO、SDK/cache、整checkout、私钥不进入curated；[保留/省略映射](manifest.json) 给外部来源与hash及理由。原始报告bytes保持相同，相对Markdown链接只指向已保留证据；host JSON中的binary是原始外部执行位置，其省略明确列出，需复验时使用已标hash的外部原件。
