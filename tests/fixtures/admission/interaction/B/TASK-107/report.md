# TASK107 独立有限验收

结论：**PASS_FINITE_UNIT_B**。固定产品 `62039552a26da295dcd710d7cfc40cb9e43ca5fd` 的 B-01–B-04 必需执行证据成立，当前 **0 Critical、0 Important，1 Minor 明确延期**。这不是“全部 B.1 满足”：T105-M01 的布局前 getter axes 义务仍未满足。后续 C 可消费 start 返回后及事件安全边界的已提交几何、唯一节点/offset 与生命周期输入；C 自身的 owner/portal/modal/anchor 合同仍须独立实施和验收。

权威合同为 design SHA256 `3aa214946949afbaa79ab08a214bd2fb6bc6f9b3b2173f11d64225bc52b16ebd` 及 task-107-brief。独立 TASK105 原完整审查、round1、round2 构成连续审查链，八个 Important 已闭环；未把原始 CHANGES_REQUIRED 报告改写为 PASS。TASK106 最终 manifest SHA256 `a4cbad039dd8aa8ccb37afe21dbf9077dae5591f80c59c821a6f88ca802073d5`，其 index SHA256 `36378247cfda85ed182ce70cd83c2bcf387742437b495426fdc708608168fb2f`。

逐项结论见 [matrix.json](matrix.json)：原 31 项、bareCanvas 附加项、9 项 review observations 均按各自实际证据通过，另列 M01 为 DEFERRED_TASK024，共 42 行。9 项在独立 selector 与完整正常入口出现属于两种观察，不算 18 个独立用例。原 case/golden 的 PREPARED_UNEXECUTED 字段是冻结准备材料的历史元数据，不覆盖本次实际执行记录。

| 合同 | 独立接受的证据及边界 |
|---|---|
| B-01 | 公开 Column/Row/Canvas viewport 与 ScrollView 组合、裸根 100 行、横向内容访问、完整 Unicode 簇及固定 chrome。正常完整入口与 clean 原正式消费者通过；真实 PTY 与 GUI/VT 的键输入、原生格另核。 |
| B-02 | weighted 兼容、固定/独立视口屏障、Off、wrap、零尺寸、axes 关闭、extent/offset 钳制、mounted export 不污染 App、有限资源与测量依赖。I009 至多两次根协商、单树和实际尺寸 Frame、Nearest 内部分支采用独立105源码职责及固定源码核对；RSS 不当作 pass 计数。布局前 getter axes 例外见下文。 |
| B-03 | 嵌套 Some/None 矩形、二维对齐、当前布局验证、ensure 顺序、真实 resize、旧 caret 与同回调新 caret 优先、手动滚回不被每帧拉回。guard/容量/生命周期/post/取消也由公开断言覆盖。portal 边界属 C。 |
| B-04 | 用户 Ancestor 先于 viewport 默认、prevent 与 stop 区分、内层边缘交给外层、首次真实移动消费、Bool 按已有几何及排队 offset 表示接受变化。PageUp/PageDown 仅规范化 KeyEvent，未声称物理解码通过。 |

正常 B、九项复核、真实 PTY、NodeRef controls/实际 GC/新进程 500 次守卫、T008 Canvas 三种集成、受影响 A/runtime/Theme 和准入 async8 原命令均 exit 0。clean 解包 library、完整正式 B、NodeRef 两进程、ThemeCanvas 三模式和公开 viewport 示例 build/--smoke 均 exit 0。正常 mandatory lint + bundle 成功，原 stdout 保留 **618 条 warning**；bundle 内自带测试 TOTAL:0 不冒充 B 功能测试。GNU Time 原 runner 的 0.02 秒和 26,812 KiB 仅为该次资源观察。

身份校核见 [verification.json](verification.json)：独立核对 1,569 原件、5 个报告/索引文件、38 组源码 pre/post、当前固定源码、40 个外部制品、208 个 CJP 全成员及 clean 解包字节、55 个正式 consumer 文件、375 个上游源文件与 371 个 stdx 文件。消费者仅 manifest 依赖路径变化。CJP SHA256 `7aae8c78c6bac15a6dd618a8616646b3bbc23feb3c54d79d1f610d8799474885`；宿主直接执行 ELF 与 VM 内 `apps/viewport-b` 为同一 SHA256 `229eb7a6189fb0d916bfec1dba992a15e01471e410d8bff2b6e98363dc621062`。52 个 initrd 清单项、kernel、SDK 1.2/compiler/cjpm/config/UCD 及实际宿主/font 字节均校核。源码审查原索引 44 项、round1 41 项、round2 5 项均无差异。上述数量是身份/原件检查数，不是新增功能用例数。

真实宿主为 XTerm398、Xfce4-terminal1.1.4/VTE0.80.1、Xorg1.21.1.16、DejaVu Sans Mono16；Linux VT 为 QEMU TCG 内 Debian6.12.107 tty1，产品 uid/euid1000。8 个 GUI 场景 32 阶段、3 个 VT 场景 12 阶段的原生行/全部剩余空格、状态字面量、一次产品 query、退出和 termios 独立核对；GUI 原 mode25 恢复，VT Unknown 的产品 write 不含 25h/l/s/r。物理窗口 resize 与 VT_RESIZE/readback、真实 100+14 个 Down 输入保留。自然 4→2 得 offset11/`l `；同回调 `4/9` 后物理 2×1，新 caret 得 offset1/`bc`，手动零得 `ab`。91 张成功原 PNG（64 GUI、27 VT）全部哈希核对，直接查看其中 12 张代表图，未声称逐张视觉审查。全部阶段 native 数据与原 trace/serial 链核验；图片没有代替精确字节和原生格。VT 本轮是 ASCII 场景，不扩张为 VT 全 Unicode/字体覆盖，也不声称物理硬件测试。

失败采集历史保留：缺省 `/usr/bin/time` 不存在 exit127，显式 GNU Time 原 runner 后成功；VTE softwrap 范围误当物理行、JSON 发布竞态、末列 exclusive 读取错误；VT 早期 15 秒界限/旧状态/完整 VCS 串口洪流。后续只修观察器并加入 native 阶段围栏，原产品、100 键输入和 oracle 未改。两个 VM pack 清单目录错误及未载入 SDK 的前置 wrapper 失败不提供产品结论。外层 collector exit1 不抹去已完成子场景的独立完整 exit/native/termios 原件。工具末态哈希仅是 post-collection 身份，不能追溯冒充 pre-run。TASK107 自身校核脚本的语法、CRLF 比较和 cpio trailer 解析修正也仅属验收工具，未重跑产品。

**精确未结项 M01：** `Canvas.viewport({ => Both }).onMount(...)` 内合法 `viewportSnapshot().axes` 实际为 Off，start 返回后才为 Both；B.1 要求挂载后未布局时零几何与当前 axes。固定 lifecycle 测试只断言常量 Both 场景的零几何，不验证 getter axes，不能据其通过关闭缺陷。当前源顺序仍先执行 mount effect、后 syncViewportAxes；独立105反例与最终源码一致。保留 root 已明确的 TASK024 延期，最终关闭须修复并验证该精确 getter/onMount 义务。C.6 使用已提交布局，C 的普通 owner/host 输入因此可继续；不得让其测试或实现依赖 M01 被修复。

父 AC037 的原文要求“80×24访问100行全部内容，横向访问宽表；边缘宽字符不拆，resize钳制偏移并保持有效焦点”。这些有限视口义务具备可机械投影的实际证据：真实方向键与尺寸变化、公开 width12 横向 Row 首尾访问、Unicode 整簇及身份/焦点保持。完整表格业务不在该父项范围。M01 仍挂最终 TASK024；C、019/028/029/020/030 全任务、027 展示、M2、完整 Keyboard/物理 Page keys、TASK023 wholechecker 的 themes 允许表及 composition/benchmark 门禁、完整 Linux/release 和其他平台均未关闭。

本角色未访问作者104报告/自评/工作树或联系作者，未派子代理，未改产品/tests/spec/main，未启动任何新产品套件。旧 A/Theme/Glyph sealed 原件只读复用；19 个 A 实现字节一致项及旧 manifest 已核，新的 B 布局与宿主行为使用本轮证据。索引只引用原件，不复制 raw/source/SDK/ELF/PNG；后续整 B 归档由 root 一次处理。
