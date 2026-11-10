# TASK148 独立正式测试交付

状态：**test_contract_frozen / ready_for_root_review**。仅测试设计及真实旧产品 RED；不是未来产品 GREEN、宿主 PASS、AC148 独立验收或父 AC030 完成。未派下级代理。

- BASE：`9bc493fe9c1943b8608be0969c0b2d5e4cfdd924`。
- test-only commit：`4093a7ab146f01ac60e0e447a487eaac55f82677`，分支 task148-independent-tests。
- 源目录：`/workspace/work/session-extension-tests/source`；仅 `tests/session_extensions/` 19 files / 1,071 additions，工作树干净。
- 固定合同：`d0657194529747da9dd2494f84c2fbbea0e16378` 的 design S001–S012；原件副本 `input/design.md`，含重复 restore 与深层数组防别名修订。
- 产物入口：`source/tests/session_extensions/README.md`、`run.sh`。正式源码/产品/spec/main 均未改；原 R10、runtime、native 围栏测试原样保留。

## 实际验证与 RED

| 检查 | 命令/原始证据 | 实际结果 / 含义 |
|---|---|---|
| 正常旧库 CJPM consumer | `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip tests/session_extensions/run.sh build`；raw/final-api-red.log/.exit | **exit 1**，32 compiler diagnostics：31 项缺少 Session 公共类型/标识符/方法，1 项未知 SessionStepResult 导致的 enum-pattern 连带错误。无独立语法错误；没有旧库新 API 功能运行。 |
| native/oracle selftest | `tests/session_extensions/run.sh selftest`；raw/final-selftest.log/.exit | **exit 0**，22 checks，7 项故意 wire/result 损坏负对照均被拒；另 4 项 synthetic host observation 负对照被拒。只有夹具自检 PASS。 |
| 最终完整消费者语法 | `cjc -p .../source/tests/session_extensions/src --import-path=.../syntax-only/consumer/target/release --output-type=staticlib --error-count-limit all -o .../syntax-only/final-consumer.a`；raw/final-syntax-only.log/.exit | **exit 0**；staticlib 模式仅 main-unused warning。固定 preflight throw-only 公共声明提供类型形状，**从未运行该库或任何声明夹具**。不提供功能成功事实。 |
| 初始完整 shape-only CJPM 编译/链接 | raw/compile-only-shape.log/.exit | **exit 0**，警告为 throw-only 参数未使用和当时 main 导入未使用。可表达性事实，不是产品成功；后续最终来源通过上述直接编译核对。 |
| JS/shell/C seam | 所有 .mjs `node --check`，两 .sh `bash -n`；C 以 `-Wall -Wextra -Werror` 构建 | **exit 0**。 |
| 范围和 patch | `git diff --cached --check`；`git diff --exit-code BASE -- src native cjpm.toml` | **exit 0**；源产品零变化，未打包 caches/checkout/binary。 |

最终正常旧库 RED 于 **2026-11-10T20:00:50Z → 2026-11-10T20:03:04Z UTC**。cjc/cjpm **1.2.0**，x86_64-unknown-linux-gnu，包 0.0.0。正常 consumer path 直接依赖原库 `../..`，不是 preflight shape 路径；`target/release/cjtui/libcjtui.a` 与 cjtui.cjo 的实际哈希在 raw/old-library-built-hashes.txt。该正常旧库 consumer 没有生成可运行 main，因此未使用 cjpm run 或把编译退出掩盖成通过。未来执行入口直接执行真实二进制。

第一次消费者构建发现测试自身两处语言问题（Int64.parse 缺 std.convert import、闭包捕获可变变量），已修正；后续消除 Array repeat 的既有 None 歧义，保留单独 typed bare None 兼容断言。最初日志保存在 raw/old-build* / final-old-build*，不作为冻结 RED 证据。冻结 RED 已在最终 .cj 文件下重建；最后增加的 host-consumer.sh 和文档未改变 CJ/产品/依赖，复用正常 RED 与最终语法证据。没有用文本扫描替代普通消费者编译。

## 覆盖与精确计数

正式执行矩阵 **277 configurations**，其中 **211** 项为五种扩展小序列在三 route 上逐个不完整字节位置的故障，另 **3** 项为既有屏幕 writer 部分故障。这些运行配置尚未在未来产品上执行；不能称 277 PASS。各配置内含多个可定位结果/能力/bytes/清理断言。手工 wire golden 9 copy vectors + title empty/Unicode + save/pop + tmux/screen literal 校验；上限 65,536 / 1,024 / 1,048,576、每序列 90,000 均冻结。

| 范围 | 具体可执行断言 |
|---|---|
| S002/S011 | 七个方法、八个 enum 的全部 case、全部 record 字段；Int64/String/Array 形状显式类型消费；root wildcard 后裸 Option None 保留。没有外部伪造 result constructor。 |
| S003 | 未 run 无 snapshot；headless NoDevice；跨线程 capability getter；snapshot 持续/新 ID；Auto 不因 TERM/COLORTERM/TMUX/STY 名称升级；Disabled/Declared/独立策略；任何真实结果不可 Applied 或 RestoreConfirmed；无启动可选控制序列。 |
| S004 | 空复制/标题；RFC4648 七标准短向量、Unicode组合、控制只作Base64；copy 65535/65536/65537、title 1023/1024/1025、icon 1048575/1048576/1048577；astral/é 精确UTF8预算；9 malformed classes × copy/title；65 C0/DEL/C1 title scalars，byte offset=2；UTF8/length/control/disabled 优先顺序及零写。 |
| S005 | Direct/Tmux/Screen 全向量与边界：固定 c/BEL、OSC2、22;2/23;2；tmuxESC加倍及ST两字节；max wire 87392/87402/87396。仅一层 typed route，无 arbitrary escape 输入。 |
| S006 | 四操作在 inactive/getter/mount/cleanup/后台/不同 active context 失败零写；outer/batch/event/post；FIFO及post中新post下一turn；4096容量/停止丢弃；copy不脏帧；写前stopCancelled、写后SentUnconfirmed、忽略Failed仍run失败。 |
| S007 | 一scope、多次set、显式pop、重复restore Unknown/NoSavedTitle+NotNeeded、下一set新scope、close不重复pop；Unknown栈不push；正常/callback错误/取消清理；save失败不set，set失败不掩盖save；cleanup有界一项。 |
| S008 | 211 offset覆盖OSC/DCS/ESC/padding/BEL/ST/UTF8内位置；EIO/EAGAIN/zero/EINTR/成功短写/前置native allocation；准确write计数和step求和；部分后 all-wire 静默，无CAN/SUB/ST/BEL/reset/pop；无下一poll；实际close termios+signal handlers/masks；同进程第二App部分失败拒绝open、零写失败允许open；device primary与UI/native聚合；屏幕writer共享unsafe闩。 |
| S009 | 实际所有 public results 都不可Applied，所以不能授权默认cut删除。未伪造编辑器、revision/selection/undo或把未来TASK028/041签过。 |
| S012 | 改set返回steps后正常恢复；改cleanup外数组与内steps后再读保持原值。不是仅public let静态检查。 |

`cases.mjs`、`src/*.cj`、`oracle.mjs` 是可定位权威；README 给出完整 case 映射和执行方式。未修改 R10 原始断言。产品冻结后 role151 必须运行该矩阵并记录真实结果。

## 夹具、宿主与原始证据

native link --wrap 保留真实 Application/RuntimeSession/native open/close/writer，只在准确 syscall/既有 buffer-add 返回边界注入。selftest 使用旧产品真实 native writer：11 个 native 配置（完整、0/1/11-byte EIO、EINTR、EAGAIN、zero、allocation、逐1-byte成功、第二序列target、普通screen与session字节区分），另11个标准golden检查。实际 raw 已从临时目录保留到 **raw/final-fixture-raw/**。

`wire.bin` 只含 session 固定事务；`all-wire.bin` 含 arm 后所有实际输出，部分故障用后者严禁盲清理。启动 UI、未来独立caret协议与session可选host协议区分；不增加I015未来行为期望。完整PTY/raw、原始result/steps、native open/close/write/poll/signal、TTY/grid/termios/time均由后续实际运行保存。测试诊断写文件，不在unsafe后打印到终端。

真实host交付含正常CJ consumer host模式、`host-consumer.sh` 真TTY child入口、`host-oracle.mjs`、不可冒充实测的FILL示例manifest，以及4个权限/title/icon/termios负控。host入口拒绝已有目录，保留实际binary hash/TERM/mux/grid/TTY/time/termios；按c→a→b→r→q的真实键事件驱动，不用协议写手替代产品。oracle分离wire与外部真实标题/clipboard确认，要求PNG原件/hash/窗口id/采集命令、host配置版本、native grid、代码和二进制hash。声明或真实host外部成功都不会把产品SentUnconfirmed改成Applied。

只读复用 /workspace/work/session-extension-recon/report.md、ssh/report.md、/workspace/work/linux-vt-product-probe/osc-probe/report.md；原始宿主 raw/PNG/manifest未改、未重跑。后续可复用独立私有Xorg的XTerm398/VTE0.80.1/tmux3.5a/screen4.09.01机制；SSH handoff是实际ssh -T + remote script PTY，loopback边界明确。正式oracle要求真实auth/kex/remoteTTY/grid/exit和完整source/binary证据；**没有读取、复制或输出任何SSH私钥**。host-only原证据不是cjtui产品PASS。

## 可复现性、依赖与技能

- 独立 cache：`/workspace/work/session-extension-tests/cache`，从既定只读 replay seed COPY；root及consumer均有ignored cangjie-repo.toml，registry=`http://127.0.0.1:18973`。未启动重复relay。UCD17 zip固定路径；依赖ansies1.3.113、unicode0.1.0、unicodewidth0.1.113、bitarray0.1.0，精确archive SHA在 **raw/dependency-SHA256SUMS**。
- 完整命令：**raw/commands.txt**；最终test源hash **raw/test-source-SHA256SUMS**；产品git对象 **raw/old-product-git-objects.txt**；SDK版本 **raw/sdk-version.txt**。本报告外置，不加入test commit。所有缓存/二进制/shape副本均在commit之外。
- 实际使用 superpowers:test-driven-development（含writing-good-tests：先精确公开契约断言，再真实旧库RED；expected不取产品encoder）、verification-before-completion（执行及核对退出后commit）。using-superpowers按subagent条款不套完整主流程。superpowers本地固定 `bb92a77741419a4ab5f06e711a283343f1ada0c3`；云skill不暴露版本SHA，未杜撰。
- CangjieSkills `277f2e1234ca5217496966887243c679653887a8`，读实际SKILL并用search_docs.py单进程批量查String.checkUtf8Encoding/Thread/File.writeTo等；以SDK1.2实际编译优先。
- OpenSpec apply本地1.14.3技能已读，按固定 implement-session-extensions读取status/instructions和合同；本次父派发明确test-only，因此未按skill改规格/task checkbox或主仓；root协调状态。CLI system PATH不含openspec时用了主仓已有node_modules/.bin/openspec，未安装工具。
- Cloud runtime已读取，实际environment_status observations_current=true、network policy=enforced/unrestricted。未安装依赖、未修改系统服务、未发布。无需额外审批。

## 限制/后续角色注意

1. 这不是277项产品运行通过。未来实际产品、全部真实host权限对照、产品SSH、异常/取消真实外观恢复由151独立执行，150/152独立审查/验收。严格host oracle的native-grid条件在当前VTE recon尚无导出，应明确insufficient_evidence并补真实证据，不能用ANSI重绘。
2. Runtime heap/OOM未人为耗尽；allocation覆盖现有native buffer-add pre-write失败。90,000 WireTooLarge、Int64 overflow、未知enum route均被更严格公开payload上限/closed enum挡住，无法通过合法公开输入到达；不调用私有encoder伪造覆盖。最大wire assertions给出可达预算证据。
3. S009仅消费诚实状态；真正cut事务/revision/selection/undo和输入paste不是本测试实现。全部AC004/020/030/041与Linux矩阵没有被提前关闭。
4. 检查无主动session OSC query和无误OSC0/1；进程/shell/clipboard-read的实现调用图仍需独立代码审核，wire oracle本身不冒充OS syscall全审计。
5. 初始补充shape仅编译且从不执行。它排除了测试语言错误，不能证明产品返回值/副作用/恢复。正常旧库RED与该shape路径、输出严格隔离。
