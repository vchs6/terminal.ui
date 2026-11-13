# 验收矩阵

本文件记录唯一验收事实；任务状态见 [工程任务](tasks.md)。产品AC-001–032及AC-037–041按下表逐项记录，有限增量不自动提升其他条目。R5的AC-033（文档）、AC-034（语言探针）、AC-035（独立设计审核）、AC-036（依赖有界调查）只证明各自范围，不是产品实现验收。R6的AC-042/043同样只覆盖规格修订与独立设计审核。

| 验收 | 需求 | 场景/接口边界 | L3 | 预期及验证证据 | 状态 |
|---|---|---|---|---|---|
| AC-001 | REQ-003、REQ-004、REQ-007、REQ-011 | 产品平台与终端支持契约调查 | TASK-001 | 当前形成Linux ANSI的OS/SDK/CPU/ABI/终端宿主/权限矩阵及TTY、输入、尺寸和恢复证据；其他OS在Linux全部完成后扩展；证据待实施时链接 | pending |
| AC-002 | REQ-001 | 验证仓颉声明式语法可编译性 | TASK-002 | 分别证明组件块、链、状态、条件/列表、自定义组件与回调；记录失败定位与限制；证据待实施时链接 | pending |
| AC-003 | REQ-004、REQ-005、REQ-011 | 验证中心仓依赖与 SDK 适配边界 | TASK-003 | 固定ansies、unicode、unicodewidth及传递依赖可解析；当前先Linux核对分段/规范化、唯一宽度、ANSI、目标原生构建/干净消费与许可来源；其他OS后续扩展；证据待实施时链接 | pending |
| AC-004 | REQ-001,REQ-002 | 冻结首个公共构造切片契约 | TASK-004 | U1–U5 设计稿均可映射至语法规则、签名、模块归属和验收，不以设计稿冒充运行；证据待实施时链接 | pending |
| AC-005 | REQ-004 | 字符簇写入和边缘裁剪 | TASK-005 | 中文、组合符和 emoji 在边缘写入/覆盖/裁剪无半宽字符或孤立延续单元；[R11证据](reviews/R11/result.md) | passed（[R11有限验收](reviews/R11/acceptance/report.md)） |
| AC-006 | REQ-005 | 结构化样式映射与 ANSI 编码 | TASK-006 | 默认/16/256/真彩色按能力映射，组件不直接发序列；[R10报告](reviews/R10/README.md) | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |
| AC-007 | REQ-004 | 完整目标帧与覆盖合成 | TASK-007 | 透明单元和带样式空格有区别，前后层按确定规则合成；[R11证据](reviews/R11/result.md) | passed（[R11有限验收](reviews/R11/acceptance/report.md)） |
| AC-008 | REQ-004 | 差分提交与写失败恢复 | TASK-008 | 无变化不输出；部分写失败不提交基线，安全重同步后完整重绘；无法确认时停止输出并报错；证据待实施时链接 | pending |
| AC-009 | REQ-005 | 有界增量 ANSI 输入适配 | TASK-009 | 跨块、畸形、超长、未知序列按支持矩阵处理，设备控制不越界透传；[R14独立验收](reviews/R14/acceptance/report.md) | passed（[R14有限验收](reviews/R14/acceptance/report.md)） |
| AC-010 | REQ-005 | 完整彩色与纯文本快照 | TASK-010 | 含覆盖层独立快照无需差分历史，纯文本无 ESC，写失败明确报告；证据待实施时链接 | pending |
| AC-011 | REQ-003 | 横纵与弹性尺寸协商 | TASK-011 | 窄屏、零尺寸和非整除弹性分配有确定结果；见[R9独立验收](reviews/R9/verification/verification.md)；[R9证据](reviews/R9/result.md) | passed |
| AC-012 | REQ-003 | 圆角边框与阴影绘制区域 | TASK-012 | 阴影只扩展绘制；移动/缩小清旧区，服从祖先裁剪；见[R9独立验收](reviews/R9/verification/verification.md)；[R9证据](reviews/R9/result.md) | passed |
| AC-013 | REQ-001 | 主题、样式复用及显式复位 | TASK-013 | 四级优先顺序和继承/复位行为明确，运行时仅样式变化也更新 | passed（基础范围；[独立验收](reviews/R15/acceptance/report.md)） |
| AC-014 | REQ-001 | 自定义组件跨容器复用 | TASK-014 | 同组件用于普通容器与弹窗无需修改内核；见C固定原件与独立有限验收 | passed（[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)；原AC完整范围） |
| AC-015 | REQ-002 | 稳定身份与卸载订阅释放 | TASK-015 | 列表重排保留正确局部状态，卸载后订阅和引用失效；见R13原件与独立验收 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-016 | REQ-002 | 状态批处理与 UI 调度 | TASK-016 | 后台状态经过调度，批量修改合并刷新，长短文本切换无残留；见R13原件与独立验收 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-017 | REQ-003 | 键盘导航和有效焦点 | TASK-017 | 禁用、卸载和空焦点集合有确定行为，无失效引用；普通域已验收，视口/层域及完整输入后续汇合 | passed（普通域焦点范围；[有限验收](reviews/interaction/A/TASK-102/report.md)） |
| AC-018 | REQ-003 | 覆盖层嵌套与关闭恢复 | TASK-018 | 父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态；见C固定原件与独立有限验收 | passed（[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)；原AC完整范围） |
| AC-019 | REQ-003 | 菜单与状态条组合行为 | TASK-019 | 水平/弹出菜单导航、选择、取消、禁用与窄屏状态条可组合；证据待实施时链接 | pending |
| AC-020 | REQ-004、REQ-011 | 应用退出与终端模式恢复 | TASK-020 | 当前在冻结Linux配置正常退出、异常及取消均按平台契约清理模式/光标；其他OS后续扩展；证据待实施时链接 | pending |
| AC-021 | REQ-001 | 交付 U1–U5 公开接口示例 | TASK-021 | M1 minimal/composition独立项目构建；不同业务U5无内核特判；四主题完整展示归AC-027，M2归AC-031；证据待实施时链接 | pending |
| AC-022 | REQ-004 | 交付可重复渲染基准项目 | TASK-022 | 固定尺寸、中文/emoji 和批更新负载可运行，记录环境与重复结果；证据待实施时链接 | pending |
| AC-023 | REQ-006、REQ-011 | 验证最终源码制品可独立使用 | TASK-023 | 实际cjp无开发资料，含四主题及统一展示；TASK-027/031/032等交付纳入制品，当前Linux冻结配置干净消费构建运行，其他OS在Linux全量验收后扩展；目标依赖/版本/许可证完整；证据待实施时链接 | pending |
| AC-024 | REQ-001–011 | 整体验收与发行准备 | TASK-024 | 当前Linux范围的需求全部有证据（含M2），产品文档与制品一致；后续OS独立扩展验收，不宣称跨平台完成；Battle 无未关闭必需失败；证据待实施时链接 | pending |
| AC-025 | REQ-008 | 分类主题配置解析与诊断 | TASK-025 | 合法单文件主题形成结构化配置；未知字段/非法值/坏引用带位置错误，不执行代码 | passed（基础范围；[独立验收](reviews/R15/acceptance/report.md)） |
| AC-026 | REQ-008 | 应用主动主题重载与原子替换 | TASK-026 | 有效重载同批次生效；失败保留旧主题，旧请求不覆盖较新请求，状态/焦点保留；当前 Component/NodeRef/Observable 状态范围，完整焦点/编辑控件后续汇合 | passed（当前异步范围；[独立验收](reviews/R15/theme-loading/acceptance/report.md)） |
| AC-027 | REQ-008、REQ-006 | 四套预置主题及统一组件展示 | TASK-027 | 深/浅/高对比/经典主题用同一展示应用，覆盖组件状态、受限色和窄屏；制品独立运行；产品证据待实现 | pending |
| AC-028 | REQ-001.8、REQ-009 | 基础输入编辑与标准快捷操作 | TASK-028 | 单/多行输入、Unicode簇级移动删除选择、剪贴板结果、撤销重做；Enter默认正确，坏粘贴不误提交；E001–E005有限编辑已获122 PASS_FINITE_E，见[E原件](reviews/E/README.md)；父级完整汇合保留 | finite_passed（完整父AC pending） |
| AC-029 | REQ-001.8、REQ-009 | 按钮标签与选择进度基础组件 | TASK-029 | 标签/按钮/单选/复选/进度条通过公开接口组合，状态可控、事件一次、主题一致；[独立157接受五控件S01–S05](reviews/widgets/S/widgets-small-acceptance/acceptance.md)；027/041全状态/Unicode/四主题展示另汇合 | passed（有限S语义范围） |
| AC-030 | REQ-010 | 可选会话能力与本地剪贴板通道 | TASK-030 | SSH复制目标为用户本地，粘贴接收不主动读；标题/图片图标按支持证据，发送与确认分开；缺能力不影响核心；产品证据待实现 | pending |
| AC-031 | REQ-004.8 | M2局部布局绘制及基线对照 | TASK-031 | 局部负载减少无关工作，移动/遮挡/宽字符/resize与M1帧结果一致，记录CPU/分配/输出及大范围退化；产品证据待实现 | pending |
| AC-032 | REQ-001.9、REQ-002.7/.8 | 混合子元素操作与定向通知集成 | TASK-032 | 声明A/B/C中插X融合排序位置；显式移动/移除、无效锚点/卸载/重入操作有诊断；定向通知合批无手动flush；见R13原件与独立验收 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-033 | REQ-007 | 本轮规格与追踪一致性 | TASK-033 |R5最终严格检查与覆盖记录；实际证据：R5/validation-final.txt、check-consistency.mjs及re-review.md| passed |
| AC-034 | REQ-001 | SDK语言隔离调查交付 | TASK-034 |R5语言正负例、重跑及闭包/收集边界；不替代AC-002/004完整验收；实际证据：R5/evidence/README.md语言正负例；主代理重跑退出0| passed |
| AC-035 | REQ-007 | 独立设计审核 | TASK-035 |R5受审版本、findings及修复独立复核；仅design_reviewed；实际证据：R5/re-review.md：5项发现verified，固定修复版本070623f1014a48bd559364747550c48332c16201| design_reviewed |
| AC-036 | REQ-004、REQ-005 | 依赖选型有界调查交付 | TASK-036 |三项直接依赖及bitarray元数据/摘要、分段/宽度/ANSI和联合消费、失败及原生/许可边界；不替代AC-003完整集成；实际证据：R5/evidence/README.md、包摘要、分别及联合消费；原生/许可限制明确保留| passed |
| AC-037 | REQ-003.10/.11、REQ-009.1 | 通用视口内容访问 | TASK-037 | 80×24访问100行、宽表横向、宽字符裁剪与resize偏移/焦点保持；[B独立有限验收](reviews/interaction/B/TASK-107/report.md) | passed（原037范围；B.1 getter/onMount axes 的M01仍deferred TASK024） |
| AC-038 | REQ-011 | Windows平台会话 | TASK-038 | Windows会话/依赖目标构建及字符UI核心场景，模式/尺寸/错误/恢复可复核；产品证据待实现 | pending |
| AC-039 | REQ-011 | macOS平台会话 | TASK-039 | macOS会话/依赖目标构建及字符UI核心场景，模式/尺寸/错误/恢复可复核；产品证据待实现 | pending |
| AC-040 | REQ-011 | HarmonyOS平台会话 | TASK-040 | HarmonyOS实际目标宿主交互、依赖构建/链接、权限/尺寸/恢复证据；不得以交叉编译或OpenHarmony/SSH替代；产品证据待实现 | pending |
| AC-041 | REQ-011 | Linux平台会话 | TASK-041 | Linux固定控制台/模拟终端字符会话及依赖，模式/尺寸/错误/恢复可复核；产品证据待实现 | pending |
| AC-042 | REQ-007、REQ-011 | R6跨平台规格及官方事实核对 | TASK-042 |平台目标、契约/任务/场景一致；官方资料与运行证据分开；实际证据：R6/validation-final.txt、platform-evidence.md及independent-review.md| passed |
| AC-043 | REQ-007 | R6独立设计审核 | TASK-043 |固定受审版本、独立发现及复核，无必需文档缺陷；不代表平台实现通过；实际证据：R6/independent-review.md；受审64418db53921895e43fe7d928f806507908cd087，findings为空| design_reviewed |
| AC-044 | REQ-007、REQ-011、REQ-004/005 | Linux优先顺序 | TASK-044 |Linux全部前置闭合，非Linux后置且目标保留；不代表Linux产品集成通过；证据入口R7/input.md；实际证据：R7/verification/verification.md：无环、Linux33前置闭合，非Linux后置| passed |
| AC-046 | REQ-004/005、REQ-007 | Linux Unicode原生构建调查 | TASK-046 |固定输入、根因、原生生成和FFI传递及766分段用例可独立复现，不代表产品集成；实际证据：R7/execution/retest-report.md及verification/verification.md：原生/766用例与真实fresh-target FFI链路；正式产品集成未验| passed |
| AC-047 | REQ-007 | 依赖许可来源调查 | TASK-047 |固定上游/包SHA与许可原文、内容差异及未解决门槛明确，不是法律授权批准；实际证据：R7/verification/verification.md：独立联网源码与12份许可文本对应核对；bitarray及最终分发门槛未清| passed |
| AC-045 | REQ-007 | R7独立审核 | TASK-045 |固定版本、DQ检查、发现修复及复核；证据待交付；实际证据：R7/re-review.md及verification/verification.md：三项发现verified，固定技术版本e2c122de616207c9e5166a9c89416233b8b81268| design_reviewed |

REQ-007 的既有配置证据见 docs/reviews/R0/result.md；该记录只覆盖环境与规划检查，不替代持续开发或框架集成证据。U1–U5、主题、焦点、多层、失败恢复与制品完整性全部通过后方可声明 G-001 完成。

## 首个Linux产品切片验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-048 | REQ-001/004 | TASK-048 | 独立测试契约、RED及可执行入口 ；实际证据：[测试设计与RED](reviews/R8/test-design/report.md) | passed |
| AC-049 | REQ-004/005/006 | TASK-049 | 正常原生构建和独立消费者链接，无探针路径 ；实际证据：[冷构建与源码包消费](reviews/R8/execution/slice-report.md) | passed |
| AC-050 | REQ-001/003/004/005 | TASK-050 | 本切片公开API、真实Linux会话和minimal示例 ；实际证据：[公开接口与真实TTY执行](reviews/R8/execution/slice-report.md) | passed |
| AC-051 | REQ-007 | TASK-051 | 独立代码/契约审核及修复复核 ；实际证据：[代码复核](reviews/R8/whole-review/re-review-2.md)及[入口复核](reviews/R8/whole-review/entry-review.md) | passed |
| AC-052 | REQ-007 | TASK-052 | 独立构建/测试/PTY执行原始证据 ；实际证据：[独立执行原始结果](reviews/R8/execution/slice-results.json) | passed |
| AC-053 | REQ-001–007 | TASK-053 | 首片交付与最终集成，未完功能明确 ；实际证据：[独立验收](reviews/R8/verification/verification.md)及[最终集成](reviews/R8/verification/final-integration.md) | passed |

## 布局与装饰质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-054 | REQ-003/007 | TASK-054 | 独立布局/装饰测试与RED；[R9证据](reviews/R9/result.md) | passed |
| AC-055 | REQ-007 | TASK-055 | 固定代码契约/质量审核及修复复核；[R9证据](reviews/R9/result.md) | passed |
| AC-056 | REQ-003/006/007 | TASK-056 | fresh slice/真实例子/clean包消费原始证据；[R9证据](reviews/R9/result.md) | passed |
| AC-057 | REQ-003/007 | TASK-057 | 有限合同验收及[最终独立集成核对](reviews/R9/verification/final-integration.md) | passed |
| AC-058 | REQ-007 / 用户源码组织约束 | TASK-058 | 包/实体文件一致，公开消费者及制品无回归；[R9证据](reviews/R9/result.md) | passed |
| AC-059 | REQ-004.7/007 | TASK-059 | 非throwing finally，业务/恢复错误均可见，标准bundle；[R9证据](reviews/R9/result.md) | passed |
| AC-060 | REQ-004.7/007 | TASK-060 | 独立生命周期组合回归及真实RED/termios；[R9证据](reviews/R9/result.md) | passed |

## 颜色与样式增量质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-061 | REQ-001/005/007 | TASK-061 | 独立颜色/属性/输出模式测试及真实RED | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |
| AC-062 | REQ-007 | TASK-062 | 固定技术diff的spec/quality独立审核 | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |
| AC-063 | REQ-005/006/007 | TASK-063 | cold全入口/真实PTY/标准bundle/clean消费者 | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |
| AC-064 | REQ-005/007 | TASK-064 | 有限合同与最终集成独立验收 | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |
| AC-065 | REQ-005/007 / 用户自动适配与跨终端截图约束 | TASK-065 | 实际能力来源探针、跨宿主矩阵及真实截图方法 | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |
| AC-066 | REQ-005/007 / 跨终端与运行截图 | TASK-066 | 真实宿主统一应用、原始PNG/日志/尺寸/能力来源/恢复测试程序 | passed（有限；[R10验收](reviews/R10/acceptance/report.md)） |

## 帧合成增量质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-067 | REQ-004/005/007 | TASK-067 | 固定公共消费者、独立网格/字节期望及真实缺API RED原件 | passed（[R11有限验收](reviews/R11/acceptance/report.md)） |
| AC-068 | REQ-007 | TASK-068 | 固定完整技术diff的spec/quality双结论，无未决必需缺陷 | passed（[R11有限验收](reviews/R11/acceptance/report.md)） |
| AC-069 | REQ-004/005/006/007 | TASK-069 | 独立新消费者/受影响旧回归/正常bundle及公开消费的实际退出与原始证据 | passed（[R11有限验收](reviews/R11/acceptance/report.md)） |
| AC-070 | REQ-004/005/007 | TASK-070 | AC005/007与文件原语有限验收及最终内容/元数据核对，不提升完整AC010/Linux | passed（[R11最终投影](reviews/R11/acceptance/final-projection-report.md)） |

## 持久运行时质量验收

状态由实际独立验收更新；[契约与任务](../openspec/changes/implement-reactive-runtime/tasks.md)，尚未实施的设计不算产品通过。

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-071 | REQ-001/002/007 | TASK-071 | 公共runtime/宏消费者固定期望与真实RED；见[R12有限验收](reviews/R12/acceptance/report.md) | passed |
| AC-072 | REQ-001/002/009 | TASK-072 | 持久构造/绑定/调度/有限事件及公开动态示例；见[R12有限验收](reviews/R12/acceptance/report.md) | passed |
| AC-073 | REQ-007 | TASK-073 | 固定技术diff的独立spec/quality审查；见[R12有限验收](reviews/R12/acceptance/report.md) | passed |
| AC-074 | REQ-002/004/006/007 | TASK-074 | 独立执行、真实退出/TTY恢复、正常bundle与公开消费；见[R12有限验收](reviews/R12/acceptance/report.md) | passed |
| AC-075 | REQ-001/002/007 | TASK-075 | A+B有限证据与最终元数据核对，原父AC不提前完成；见[R12有限验收](reviews/R12/acceptance/report.md) | passed |
| AC-076 | REQ-002/007 | TASK-076 | 动态/混合槽位独立golden与真实RED | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-077 | REQ-001/002 | TASK-077 | If/ForEach与手动操作共享唯一子序列 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-078 | REQ-007 | TASK-078 | C增量及运行时跨界独立spec/quality审查 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-079 | REQ-002/006/007 | TASK-079 | 独立动态矩阵、相关回归、正常公开包消费 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |
| AC-080 | REQ-001/002/007 | TASK-080 | 原AC015/016/032完整证据及元数据，014仍等018 | passed（[R13独立有限验收](reviews/R13/acceptance/report.md)；原015/016/032完整范围） |

## 有界富文本质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-081 | REQ-001/005/007 | TASK-081 | 独立typed文本/逐byte分块/手工样式golden与真实缺API RED | passed（[R14有限验收](reviews/R14/acceptance/report.md)） |
| AC-082 | REQ-007 | TASK-082 | 固定完整富文本技术diff的spec/quality独立审核 | passed（[R14有限验收](reviews/R14/acceptance/report.md)） |
| AC-083 | REQ-005/006/007 | TASK-083 | 独立新矩阵、受影响回归、正常源码包与公开消费 | passed（[R14有限验收](reviews/R14/acceptance/report.md)） |
| AC-084 | REQ-001/005/007 | TASK-084 | 原AC009和有限文本集成证据/最终metadata，010可见层仍待验 | passed（[R14有限验收](reviews/R14/acceptance/report.md)） |

富文本行为和支持任务状态见[具体变更](../openspec/changes/implement-rich-text/tasks.md)，已完成范围限原AC009及本四项支持验收。

## 主题样式质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-085 | REQ-008/007 | TASK-085 | 基础typed resolver/schema/布局/预置独立golden与真实RED | passed（基础范围；[独立验收](reviews/R15/acceptance/report.md)） |
| AC-086 | REQ-008/007 | TASK-086 | 013/025固定完整技术diff独立双审 | passed（基础范围；[独立验收](reviews/R15/acceptance/report.md)） |
| AC-087 | REQ-008/007 | TASK-087 | 独立基础矩阵/回归/正常bundle与SDK+stdx公开消费 | passed（基础范围；[独立验收](reviews/R15/acceptance/report.md)） |
| AC-088 | REQ-008/007 | TASK-088 | 原AC013/025及最终metadata，027全部展示仍待验 | passed（基础范围；[独立验收](reviews/R15/acceptance/report.md)） |
| AC-089 | REQ-008/007 | TASK-089 | 异步主题请求/淘汰/关闭/事务独立测试与真实RED | passed（测试交付/真实RED；[证据](reviews/R15/async-red/report.md)） |
| AC-090 | REQ-008/007 | TASK-090 | 固定load增量及跨界独立spec/quality | passed（当前异步范围；[独立验收](reviews/R15/theme-loading/acceptance/report.md)） |
| AC-091 | REQ-008/007 | TASK-091 | 独立乱序/失败/资源/重载与公开制品消费 | passed（当前异步范围；[独立验收](reviews/R15/theme-loading/acceptance/report.md)） |
| AC-092 | REQ-008/007 | TASK-092 | 原AC026及集成metadata，不提前关闭027/Linux | passed（当前异步范围；[独立验收](reviews/R15/theme-loading/acceptance/report.md)） |

具体准入和唯一任务状态见[主题样式变更](../openspec/changes/implement-theme-styles/tasks.md)；候选/配置文件不是实现通过。

## Linux VT 字形子接口质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-093 | REQ-004/005/007/011 | TASK-093 | 独立原文/标记/投影、原生边界及真实缺API RED | passed（[R16有限验收](reviews/R16/acceptance/report.md)） |
| AC-094 | REQ-004/005/011 | TASK-094 | 自动VT探测/等宽降级/高级覆盖及离线Unicode边界 | passed（[R16有限验收](reviews/R16/acceptance/report.md)） |
| AC-095 | REQ-007 | TASK-095 | 固定字形增量的独立spec/quality审核 | passed（[R16有限验收](reviews/R16/acceptance/report.md)） |
| AC-096 | REQ-004/005/006/007/011 | TASK-096 | 独立原生/投影/差分、真实VT与模拟器PNG、正常干净包消费 | passed（[R16有限验收](reviews/R16/acceptance/report.md)） |
| AC-097 | REQ-004/005/007/011 | TASK-097 | 有限字形子接口证据与metadata，完整041和主题ellipsis仍待汇合 | passed（[R16有限验收](reviews/R16/acceptance/report.md)） |

状态权威仅见[字形适配变更](../openspec/changes/implement-linux-vt-glyph-fallback/tasks.md)，候选微验证不是产品验收。

## 公共交互质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-098 | REQ-003/004/007/009 | TASK-098 | 独立Canvas/focus/事件/caret测试与真实RED | passed（测试交付与真实缺API RED；[固定测试](../tests/interaction_a/README.md)，产品行为待099–102） |
| AC-099 | REQ-003/004/007/009 | TASK-099 | 公共受控绘制与键盘目标实现 | passed（有限Unit A；[证据](reviews/interaction/A/TASK-102/report.md)） |
| AC-100 | REQ-003/004/007/009 | TASK-100 | A固定源码独立spec/quality | passed（有限Unit A；[证据](reviews/interaction/A/TASK-100/round2/report.md)） |
| AC-101 | REQ-003/004/007/009 | TASK-101 | A独立执行/真实TTY/正常包消费 | passed（有限Unit A；[证据](reviews/interaction/A/TASK-101/report.md)） |
| AC-102 | REQ-003/004/007/009 | TASK-102 | A有限验收/metadata，不提前关闭完整交互 | passed（有限Unit A；[证据](reviews/interaction/A/TASK-102/report.md)） |
| AC-103 | REQ-003/004/007/009 | TASK-103 | 独立viewport/root fallback/滚动golden与RED | passed（[B有限验收](reviews/interaction/B/TASK-107/report.md)；M01明确延期，非全部Linux） |
| AC-104 | REQ-003/004/007/009 | TASK-104 | 单viewport坐标/滚动/ensureVisible实现 | passed（[B有限验收](reviews/interaction/B/TASK-107/report.md)；M01明确延期，非全部Linux） |
| AC-105 | REQ-003/004/007/009 | TASK-105 | B固定源码独立spec/quality | passed（[B有限验收](reviews/interaction/B/TASK-107/report.md)；M01明确延期，非全部Linux） |
| AC-106 | REQ-003/004/007/009 | TASK-106 | B独立执行/滚动回归与公开包消费 | passed（[B有限验收](reviews/interaction/B/TASK-107/report.md)；M01明确延期，非全部Linux） |
| AC-107 | REQ-003/004/007/009 | TASK-107 | 原037完整证据与metadata | passed（[B有限验收](reviews/interaction/B/TASK-107/report.md)；M01明确延期，非全部Linux） |
| AC-108 | REQ-003/004/007/009 | TASK-108 | 独立多层/模态/透明/focus恢复golden与RED | passed（正式冻结与历史缺API RED；[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)，后续C行为及包/宿主已验证） |
| AC-109 | REQ-003/004/007/009 | TASK-109 | 同Runtime覆盖层/宿主/输入域实现 | passed（[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)；有限单元C，非全部Linux） |
| AC-110 | REQ-003/004/007/009 | TASK-110 | C固定源码独立spec/quality | passed（[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)；有限单元C，非全部Linux） |
| AC-111 | REQ-003/004/007/009 | TASK-111 | C独立真实终端/层集成与公开制品消费 | passed（[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)；有限单元C，非全部Linux） |
| AC-112 | REQ-003/004/007/009 | TASK-112 | 原018和014跨弹窗证据及metadata | passed（[C独立有限验收](reviews/interaction/C/overlay-acceptance/acceptance.md)；有限单元C，非全部Linux） |

唯一任务状态与精确前置见[交互变更](../openspec/changes/implement-public-interaction/tasks.md)，规划不作实现通过。

## 可选会话能力质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-148 | REQ-010/007 | TASK-148 | 独立固定wire/权限/故障/metadata用例与真实RED | passed（[R18有限验收](reviews/R18/acceptance/report.md)） |
| AC-149 | REQ-010/007 | TASK-149 | 同一writer复制标题/安全降级及结果实现 | passed（[R18有限验收](reviews/R18/acceptance/report.md)） |
| AC-150 | REQ-010/007 | TASK-150 | 固定会话增量独立spec/quality审核 | passed（[R18有限验收](reviews/R18/acceptance/report.md)） |
| AC-151 | REQ-010/007 | TASK-151 | 独立真实host与SSH/模式恢复/正常制品消费 | passed（[R18有限验收](reviews/R18/acceptance/report.md)） |
| AC-152 | REQ-010/007 | TASK-152 | 030有限会话结果及metadata，粘贴等完整父AC按实际汇合 | passed（[R18有限验收](reviews/R18/acceptance/report.md)） |

唯一任务状态见[会话扩展变更](../openspec/changes/implement-session-extensions/tasks.md)，不把协议环境探针当产品成功。

## 归一化输入与基础编辑质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-113 | REQ-009/010/007/011 | TASK-113 | 独立字节/分块/粘贴目标/EOF公平性golden与RED | passed（正式测试c96cc601冻结、当前上游baseline0/缺Keyboard API真实编译RED1；后续固定K有限行为见AC114–117） |
| AC-114 | REQ-009/010/007/011 | TASK-114 | 唯一KeyboardDecoder/设备/2004模式实现 | passed（有限K；[实现及证据](reviews/K/README.md)，固定产品c3c4642→main da9eaf40） |
| AC-115 | REQ-009/010/007/011 | TASK-115 | 固定键盘增量独立双审 | passed（[独立源码双审最终PASS](reviews/K/keyboard-review/round-03/report.md)；原两轮FAIL保留） |
| AC-116 | REQ-009/010/007/011 | TASK-116 | 独立真实输入/模态目标/退出恢复与普通包消费 | passed（[独立实际执行](reviews/K/keyboard-execution/report.md)；16阶段exit0、229包成员、三真实实现及宿主限制） |
| AC-117 | REQ-009/010/007/011 | TASK-117 | 有限键盘合同及metadata，完整编辑仍待验 | passed（[独立PASS_FINITE_K](reviews/K/keyboard-acceptance/acceptance.md)；不关闭完整父AC/Linux） |
| AC-118 | REQ-009/010/007/011 | TASK-118 | 独立Unicode事务/历史/竞态/控件golden与RED | passed（独立测试及supplements已冻结；真实缺API RED与前置成功原件见[E归档](reviews/E/README.md)） |
| AC-119 | REQ-009/010/007/011 | TASK-119 | 公共Canvas单多行输入/控制器/标准快捷键实现 | passed（接受源22ca8cf7/main b71cb2eb；公开Canvas编辑实现，作者证明独立列于[E归档](reviews/E/README.md)） |
| AC-120 | REQ-009/010/007/011 | TASK-120 | 固定编辑增量独立双审 | passed（spec/quality PASS_FINITE_SOURCE；初审四项Important修复轮1全部关闭；[双轮原件](reviews/E/README.md)） |
| AC-121 | REQ-009/010/007/011 | TASK-121 | 独立编辑/剪贴板结果/主题/viewport/真实终端消费 | passed（普通build/bundle、干净消费与真实XTerm/VTE/kernelVT执行完成；宿主及source-only限制见[E归档](reviews/E/README.md)） |
| AC-122 | REQ-009/010/007/011 | TASK-122 | 原028完整证据及metadata，030父项按真实paste/cut汇合 | passed（PASS_FINITE_E，spec/quality/evidence通过；[独立验收与矩阵](reviews/E/editing-acceptance/acceptance.md)，完整Linux/父AC另汇合） |

唯一任务状态见[输入编辑变更](../openspec/changes/implement-linux-input-editing/tasks.md)，有限K/E证据见[K归档](reviews/K/README.md)与[E归档](reviews/E/README.md)，完整Linux/父AC未关闭。

## M2与公开基准质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-123 | REQ-001/003/004/007 | TASK-123 | 独立同核算法/统计测试与新增API RED | pending |
| AC-124 | REQ-001/003/004/007 | TASK-124 | 单measure/arrange/paint重构及真实统计 | pending |
| AC-125 | REQ-001/003/004/007 | TASK-125 | 算法分离独立双审 | pending |
| AC-126 | REQ-001/003/004/007 | TASK-126 | 算法分离独立执行及回归 | pending |
| AC-127 | REQ-001/003/004/007 | TASK-127 | A有限验收，不提前称局部渲染 | pending |
| AC-128 | REQ-001/003/004/007 | TASK-128 | 独立Frame共享/宽簇/透明/分配槽测试 | pending |
| AC-129 | REQ-001/003/004/007 | TASK-129 | Frame私有行COW及精确来源 | pending |
| AC-130 | REQ-001/003/004/007 | TASK-130 | 行共享独立双审 | pending |
| AC-131 | REQ-001/003/004/007 | TASK-131 | 行共享独立执行和旧Frame回归 | pending |
| AC-132 | REQ-001/003/004/007 | TASK-132 | B有限验收，不提前关031 | pending |
| AC-133 | REQ-001/003/004/007 | TASK-133 | 独立dirty/cache/布局连带golden | pending |
| AC-134 | REQ-001/003/004/007 | TASK-134 | 节点约束缓存/精确失效传播 | pending |
| AC-135 | REQ-001/003/004/007 | TASK-135 | 缓存失效独立双审 | pending |
| AC-136 | REQ-001/003/004/007 | TASK-136 | 缓存/逐帧M1对照独立执行 | pending |
| AC-137 | REQ-001/003/004/007 | TASK-137 | C有限验收，局部合成待D | pending |
| AC-138 | REQ-001/003/004/007 | TASK-138 | 独立damage/层/滚动/caret/故障golden | pending |
| AC-139 | REQ-001/003/004/007 | TASK-139 | 同Frame局部合成与后端安全提交 | pending |
| AC-140 | REQ-001/003/004/007 | TASK-140 | 局部合成独立双审 | pending |
| AC-141 | REQ-001/003/004/007 | TASK-141 | 局部渲染/M1等价与设备故障独立执行 | pending |
| AC-142 | REQ-001/003/004/007 | TASK-142 | D功能验收，031成本待E | pending |
| AC-143 | REQ-001/003/004/007 | TASK-143 | 公开benchmark独立公平性与计量测试 | pending |
| AC-144 | REQ-001/003/004/007 | TASK-144 | 独立CJPM benchmark实现与说明 | pending |
| AC-145 | REQ-001/003/004/007 | TASK-145 | benchmark公平性/公共API独立双审 | pending |
| AC-146 | REQ-001/003/004/007 | TASK-146 | 独立重复CPU/Cell槽/heap/GC/RSS/输出与干净消费 | pending |
| AC-147 | REQ-001/003/004/007 | TASK-147 | 原022/031完整成本及metadata验收 | pending |

唯一任务状态见[具体变更](../openspec/changes/implement-incremental-rendering/tasks.md)，规划和探针不代表产品已完成。

## 标准控件质量验收

| AC | 需求 | 任务 | 验收边界 | 状态 |
|---|---|---|---|---|
| AC-153 | REQ-001/003/004/007 | TASK-153 | 独立受控状态/事件/样式/边界golden | passed（正式测试及7项修正冻结；前置build/direct0与五项真实缺API RED原件见[S归档](reviews/widgets/S/README.md)） |
| AC-154 | REQ-001/003/004/007 | TASK-154 | 公共Label/Button/Checkbox/Radio/Progress实现 | passed（接受源1df1325f/main85998ead；五公共控件实现；[作者证明独立列示](reviews/widgets/S/README.md)） |
| AC-155 | REQ-001/003/004/007 | TASK-155 | 基础控件独立双审 | passed（独立spec/quality PASS，0具体缺陷；[原件](reviews/widgets/S/widgets-small-review/report.md)） |
| AC-156 | REQ-001/003/004/007 | TASK-156 | 基础控件独立真实终端及包消费 | passed（普通build/bundle、干净消费、3PTY及6真实宿主运行；ASCII/default Classic native范围，见[S归档](reviews/widgets/S/README.md)） |
| AC-157 | REQ-001/003/004/007 | TASK-157 | 原029完整证据和metadata | passed（[独立PASS_FINITE_S](reviews/widgets/S/widgets-small-acceptance/acceptance.md)，S01–S05通过；完整Linux/M及027/041展示另汇合） |
| AC-158 | REQ-001/003/004/007 | TASK-158 | 独立菜单/状态/分区/层组合golden | pending |
| AC-159 | REQ-001/003/004/007 | TASK-159 | 公共菜单/状态条/SplitPane实现 | pending |
| AC-160 | REQ-001/003/004/007 | TASK-160 | 菜单组合独立双审 | pending |
| AC-161 | REQ-001/003/004/007 | TASK-161 | 菜单导航/取消/窄屏及制品独立执行 | pending |
| AC-162 | REQ-001/003/004/007 | TASK-162 | 原019完整证据与metadata | pending |

唯一任务状态见[具体变更](../openspec/changes/implement-standard-widgets/tasks.md)，规划和探针不代表产品已完成。

| ID | 需求 | 任务 | 验收证据 | 状态 |
| --- | --- | --- | --- | --- |
| AC-163 | REQ-004/005/007/011 | TASK-163 | 独立保守投影golden、真实旧GUI/新API RED及源hash | passed（[R23有限验收](reviews/R23/acceptance/report.md)） |
| AC-164 | REQ-004/005 | TASK-164 | 同一私有Glyph policy与canonical终端投影、离线Unicode保留 | passed（[R23有限验收](reviews/R23/acceptance/report.md)） |
| AC-165 | REQ-007 | TASK-165 | 固定技术diff独立spec/quality | passed（[R23有限验收](reviews/R23/acceptance/report.md)） |
| AC-166 | REQ-004/005/007/011 | TASK-166 | 实际两GUI DSR/原PNG/未改行及包消费复验 | passed（[R23有限验收](reviews/R23/acceptance/report.md)） |
| AC-167 | REQ-004/005/007/011 | TASK-167 | R14T083001及有限G纯子接口独立验收 | passed（[R23有限验收](reviews/R23/acceptance/report.md)） |

163–167唯一状态在[projection tasks](../openspec/changes/fix-uncertain-glyph-advance/tasks.md)，163–167已有限验收；Glyph093–097后续有限验收见R16，完整041/Linux仍按各自范围待验。

2026-11-11：AC093–097仅字形子接口通过；P30新增当前固定源码的实际kernel有限组合证据，完整041/全Linux与Theme实际ellipsis布局仍待后续汇合。历史不足结论保留其原时点，不扩大本轮范围。


Theme基础AC013/025/085–088仅当前范围接受：42项矩阵含限定复用/来源限制/后续排除，不能称42项全通过。T087-G01整包checker仍exit1，最终TASK023保持OPEN。AC089早期证据保留真实基础正向后异步API缺失；后续026/090–092已通过当前异步范围：原22实际行为、正常包184成员与clean代表2例、真实PTY写失败后的接受记录保持。完整焦点/编辑/滚动控件仍等对应交互阶段，023/027、全Linux与M2保持未完成。

K版本化验收说明（2026-11-13）：[归档边界](reviews/K/README.md)将AC003/004归一化、017目标桥接、030paste接收、020新增模式清理、041输入作为父项分段证据；不提高其完整状态。实际OSpipe/TTY EOF与未练习自然宿主EOF区分；VM kernelVT非物理硬件。AC028编辑、019/029菜单、M2、全Linux/024仍pending。B-M01仍延后024；T087-G01完整checker在023保持必需pending，本次普通bundle/有限包审计不替代它。
