# R6 独立设计审查

日期：2026-11-09。round_id：R6，初审。预算：最多3次修复复核或60分钟有效执行；本次未进入修复复核。

- 基线：`f998e158cf5ccd8b4743c24316e5ed6c9a8a6f26`。
- 受审版本：`64418db53921895e43fe7d928f806507908cd087`。
- 范围：相对基线全部23个变更文件，包含REQ-011、四平台后端候选、官方资料、主/增量规格及最终集成映射。
- 角色：未参与本轮撰写的独立AI审核者；沿用R5独立审核角色，不以R5结论替代R6审查，不代表外部机构认证。
- 分类与方法：按既定契约执行独立设计验证；依据AGENTS、BATTLE_PROTOCOL、ENGINEERING_TASK_DECOMPOSITION及R6/input.md。沿用已读取的本地Superpowers code-reviewer模板及verification-before-completion；使用锁定OpenSpec1.14.3。
- 写入范围：仅本报告与findings.json；未改规格/产品，未提交。

## 结论

**design_reviewed**。未发现本轮范围内必须修复的设计或规划缺陷，`findings.json`为空数组。

跨平台及HarmonyOS已成为required目标，Linux/Windows/macOS/HarmonyOS四目标矩阵明确属于工程细化，未伪称用户指定具体版本、CPU或SDK。每个OS至少一个冻结配置的完成条件可判定；产品平台仍planned/pending。没有把工具链、交叉编译、hdc、OpenHarmony、模拟器或从鸿蒙连接远程Linux的结果冒充HarmonyOS本地端到端字符界面验收。

本结论允许本轮规格交付，不表示四平台已经实现、依赖已经可移植、鸿蒙普通应用已有可用终端宿主，也不表示可发行。

## 契约与集成审查

| 检查维度 | 判断及依据 |
|---|---|
| 新用户目标 | REQ-011/NFR-07、AGENTS §13、README、产品说明及变更D-017一致。具体配置待TASK-001/004调查冻结，无任意全版本/全CPU保证。 |
| 共享核心 | architecture §20保持统一组件/状态/布局/合成与公开API，平台输入、输出、尺寸、模式/恢复及依赖边界独立；未按OS复制视图或Unicode算法。 |
| HarmonyOS实际运行 | REQ-011.3及terminal-session场景要求真实目标的输入/渲染/尺寸/恢复；商业HarmonyOS与OpenHarmony分开。hdc只是候选环境入口，宿主及权限仍须验证。 |
| 无证据时的处理 | 缺可用字符通道时保持必需目标并记录阻塞，不能静默删目标、降为可选或改为GUI/PTY/Shell实现；本轮不要求现在开发后端来换取文档通过。 |
| 可选能力边界 | 剪贴板、标题、实际图片图标仍按宿主报告；缺失不取消核心平台。R5本地剪贴板和图标语义未改。 |
| 四后端责任 | TASK-038 Windows、039 macOS、040 HarmonyOS、041 Linux各有稳定AC、范围和planned缺口；四后端不互相依赖。TASK-001/003/004提供目标/依赖/接口前置。 |
| 会话与最终集成 | TASK-020显式等待四后端，再由021/027及023/024汇合。023通过021→020间接等待全部后端，无须机械重复每条边；AC-020/023/024及REQ-011.5要求各目标运行与最终制品证据，未遗漏某个目标。 |
| 与既有M1/M2关系 | 020的四后端汇合没有指向021/027/031；原M1示例、主题展示及M2依赖保持无环。现阶段后端为候选，ready前仍需细化会话测试输入及完整UI集成的具体先后，不把静态无环当执行就绪。 |
| 依赖ABI | dependencies §4、architecture §20、AC-003与REQ-011.4覆盖每个目标的生成/编译/链接/运行和干净消费。Windows COFF、macOS Mach-O、HarmonyOS目标工具链及权限风险有记录；Linux归档不外推。 |
| 主/增量及追踪 | terminal-session/distribution新增要求与对应delta一致；REQ-011→001/003/004→038–041→020→023/024可定位；当前042/043文档与审核状态只在活动变更维护。 |

后端原生依赖消费证据与TASK-003调查不构成重复内核：前者验证具体适配使用，后者给出可复现构建/消费契约。最终核心UI/展示/基准由后续集成任务完整验收，平台会话局部证据不能单独宣称REQ-011整体完成。

## 官方资料与本地事实核验

独立抽查以下官方材料，确认platform-evidence.md所使用的证据等级合理：

- [仓颉1.2.0下载中心](https://cangjie-lang.cn/download/1.2.0)列有通用平台包及ohos包，与P1一致；下载条目本身没有证明cjtui运行。
- [仓颉1.2.0交叉编译](https://cj-docs.gitcode.com/zh/1.2.0/dev-guide/source_zh_cn/compile_and_build/cross_compilation.html)列Linux、Windows、macOS与ohos目标；P3正确区分目标名、配套工具链和实际运行库，未从目标名称推导ABI等价。
- [华为hdc指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hdc/)的版本表支持P7所述API15的-b路径及26.0.0新增交互方式。它仍是调试工具说明，不能证明普通发行应用的终端权限或完整字符UI。
- [HarmonyOS V5受权限限制的libc接口](https://developer.huawei.com/consumer/en/doc/harmonyos-references-V5/nce-on-ndk-libc-interfaces-affected-by-permissions-V5/)确列termios相关操作的SELinux限制。原证据明确标V5，未把该历史版本表泛化成所有当前系统均不可用或均可用。
- [Microsoft VT序列说明](https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences)明确存在控制台模式条件，支持Windows需要独立会话适配的判断。

华为网页普通HTTP读取仅得到页面壳，本次通过网页工具读取正文核对hdc及V5条款；未将空壳或搜索标题当作正文证据。未逐一重查P2/P4/P5/P6/P10/P11/P12的全部正文及套件权限；这些资料在当前设计中只作为调查线索，不承担已冻结的cjtui最低版本或平台可运行证明。涉及具体SDK/API兼容表的冻结仍必须重新核对实际配套套件。

另外只读检查固定R5缓存包的`unicodedata/CMakeLists.txt`、`src/data.S`和`src/library.c`：C/ASM、先执行generator、ELF风格section/导出/incbin、constructor/MSVC分支确实存在。报告将目标构建风险标为推断，未无实测宣布成功或失败。生成器宿主执行与目标归档编译的区分合理；数据端序/格式、符号/重定位、运行库和分发仍须目标验证。

本机重新执行SDK只读检查：cjc 1.2.0默认x86_64-unknown-linux-gnu；帮助列target/sysroot/toolchain；lib与runtime/lib仅有Linux/Windows对应目录，未出现ohos/macOS目录。与platform-evidence §5一致。没有执行新的编译、安装、部署或平台交互测试；没有重跑R5未变化探针。

## 实际静态检查

以下命令在受审版本运行，退出码均为0：

| evidence_id | 关联 | 命令与结果 |
|---|---|---|
| R6-IR-E01 | AC-042/043 | `node docs/reviews/R5/check-consistency.mjs`：37个产品任务依赖无环，27项delta Requirement与主规格匹配，无产品源码变更。 |
| R6-IR-E02 | AC-042/043 | `node docs/reviews/R6/check-platform-mapping.mjs`：四目标有独立责任、pending验收与020会话集成，HarmonyOS证据区别明确。已阅读脚本，不把字符串检查当完整语义审核。 |
| R6-IR-E03 | AC-042/043 | `node scripts/check-repository.mjs`：仓库、配置、链接、任务映射检查通过；不证明产品能力。 |
| R6-IR-E04 | AC-042/043 | `XDG_CONFIG_HOME=/workspace/work/tool-config OPENSPEC_TELEMETRY=0 /workspace/work/terminal.ui/node_modules/.bin/openspec validate --all --strict --no-interactive`：8项通过，0失败。 |
| R6-IR-E05 | AC-042/043 | `git diff --check f998e158cf5ccd8b4743c24316e5ed6c9a8a6f26 64418db53921895e43fe7d928f806507908cd087`：无空白错误。 |

检查方法和受检文档版本已固定；网络资料按2026-11-09核对日使用，不是可外推的长期平台通过证据。

## DQ-01–14

pass均指本轮规格和规划层，不代表038–041已具备ready条件或产品验收通过。

| DQ | 结果 | 理由 |
|---|---|---|
| 01 | pass | 当前042/043为文档与验证L3，无L1/L2直接编码。 |
| 02 | pass | 042的来源核对服务同一跨平台规格交付，043服务独立裁决；后端候选按OS独立归属。 |
| 03 | pass | 当前卡片字段可定位；未来后端明确planned、前置和待冻结项。 |
| 04 | pass | 只扩展平台范围，未增加GUI/PTY/业务UI分叉或隐式全版本承诺。 |
| 05 | pass | 每OS至少一个冻结配置及输入/尺寸/写入/恢复可观察；缺环境必须待证，当前规格检查可执行。 |
| 06 | pass | 37任务依赖无环，四后端经020汇合；未来未完成前置不被当ready。 |
| 07 | pass | REQ-011各子项分别映射调查、后端、会话和制品/整体任务，四平台无遗漏。 |
| 08 | pass | 共享核心、平台适配和上层集成职责一致，R5历史结果未外推。 |
| 09 | pass | 020/021/027/023/024闭合到全部后端，逐目标运行/制品验收明确。 |
| 10 | pass | 鸿蒙宿主、权限、版本、SDK、ABI和原生工具链未知显式列出并有调查责任。 |
| 11 | pass | 当前L4含来源核对、契约修订、静态检查和审核；未来候选允许后续细化。 |
| 12 | pass | 038–043编号、需求/AC与状态权威一致，产品pending与R5既有文档/探针结果分开。 |
| 13 | pass | 既有OpenSpec活动变更扩展、D-017授权/工程细化及技能使用引用可定位；未伪造平台完成。 |
| 14 | pass | 适配器唯一职责、原生构建风险和无旧产品实现的边界明确，无平行渲染/Unicode内核。 |

## 建议与未裁决范围

无新增必需问题。后续进入后端ready前，建议把平台会话测试输入与021/027的完整应用集成证据具体分开，按实际共享核心实现补齐必要依赖；当前文档已明确后续冻结，因此不要求本轮预造精确API或测试命令。

以下未在本轮判运行通过：四平台后端实际行为；商业HarmonyOS可分发终端宿主与启动身份；目标Unicode C/ASM可移植性及许可证；完整Unicode/终端字形；M2跨平台等价性/性能；实际制品构建部署。原因均为本轮只授权规格修订及来源核对，相关产品任务明确pending。这些待证项不能被本设计审查消除，也不构成本轮文档必须立即实施产品的理由。
