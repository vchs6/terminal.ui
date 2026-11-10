# 验收矩阵

本文件记录唯一验收事实；任务状态见 [工程任务](tasks.md)。产品AC-001–032及AC-037–041均为pending。R5的AC-033（文档）、AC-034（语言探针）、AC-035（独立设计审核）、AC-036（依赖有界调查）只证明各自范围，不是产品实现验收。R6的AC-042/043同样只覆盖规格修订与独立设计审核。

| 验收 | 需求 | 场景/接口边界 | L3 | 预期及验证证据 | 状态 |
|---|---|---|---|---|---|
| AC-001 | REQ-003、REQ-004、REQ-007、REQ-011 | 产品平台与终端支持契约调查 | TASK-001 | 当前形成Linux ANSI的OS/SDK/CPU/ABI/终端宿主/权限矩阵及TTY、输入、尺寸和恢复证据；其他OS在Linux全部完成后扩展；证据待实施时链接 | pending |
| AC-002 | REQ-001 | 验证仓颉声明式语法可编译性 | TASK-002 | 分别证明组件块、链、状态、条件/列表、自定义组件与回调；记录失败定位与限制；证据待实施时链接 | pending |
| AC-003 | REQ-004、REQ-005、REQ-011 | 验证中心仓依赖与 SDK 适配边界 | TASK-003 | 固定ansies、unicode、unicodewidth及传递依赖可解析；当前先Linux核对分段/规范化、唯一宽度、ANSI、目标原生构建/干净消费与许可来源；其他OS后续扩展；证据待实施时链接 | pending |
| AC-004 | REQ-001,REQ-002 | 冻结首个公共构造切片契约 | TASK-004 | U1–U5 设计稿均可映射至语法规则、签名、模块归属和验收，不以设计稿冒充运行；证据待实施时链接 | pending |
| AC-005 | REQ-004 | 字符簇写入和边缘裁剪 | TASK-005 | 中文、组合符和 emoji 在边缘写入/覆盖/裁剪无半宽字符或孤立延续单元；证据待实施时链接 | pending |
| AC-006 | REQ-005 | 结构化样式映射与 ANSI 编码 | TASK-006 | 默认/16/256/真彩色按能力映射，组件不直接发序列；证据待实施时链接 | pending |
| AC-007 | REQ-004 | 完整目标帧与覆盖合成 | TASK-007 | 透明单元和带样式空格有区别，前后层按确定规则合成；证据待实施时链接 | pending |
| AC-008 | REQ-004 | 差分提交与写失败恢复 | TASK-008 | 无变化不输出；部分写失败不提交基线，安全重同步后完整重绘；无法确认时停止输出并报错；证据待实施时链接 | pending |
| AC-009 | REQ-005 | 有界增量 ANSI 输入适配 | TASK-009 | 跨块、畸形、超长、未知序列按支持矩阵处理，设备控制不越界透传；证据待实施时链接 | pending |
| AC-010 | REQ-005 | 完整彩色与纯文本快照 | TASK-010 | 含覆盖层独立快照无需差分历史，纯文本无 ESC，写失败明确报告；证据待实施时链接 | pending |
| AC-011 | REQ-003 | 横纵与弹性尺寸协商 | TASK-011 | 窄屏、零尺寸和非整除弹性分配有确定结果；见[R9独立验收](reviews/R9/verification/verification.md)；[R9证据](reviews/R9/result.md) | passed |
| AC-012 | REQ-003 | 圆角边框与阴影绘制区域 | TASK-012 | 阴影只扩展绘制；移动/缩小清旧区，服从祖先裁剪；见[R9独立验收](reviews/R9/verification/verification.md)；[R9证据](reviews/R9/result.md) | passed |
| AC-013 | REQ-001 | 主题、样式复用及显式复位 | TASK-013 | 四级优先顺序和继承/复位行为明确，运行时仅样式变化也更新；证据待实施时链接 | pending |
| AC-014 | REQ-001 | 自定义组件跨容器复用 | TASK-014 | 同组件用于普通容器与弹窗无需修改内核；证据待实施时链接 | pending |
| AC-015 | REQ-002 | 稳定身份与卸载订阅释放 | TASK-015 | 列表重排保留正确局部状态，卸载后订阅和引用失效；证据待实施时链接 | pending |
| AC-016 | REQ-002 | 状态批处理与 UI 调度 | TASK-016 | 后台状态经过调度，批量修改合并刷新，长短文本切换无残留；证据待实施时链接 | pending |
| AC-017 | REQ-003 | 键盘导航和有效焦点 | TASK-017 | 禁用、卸载和空焦点集合有确定行为，无失效引用；证据待实施时链接 | pending |
| AC-018 | REQ-003 | 覆盖层嵌套与关闭恢复 | TASK-018 | 父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态；证据待实施时链接 | pending |
| AC-019 | REQ-003 | 菜单与状态条组合行为 | TASK-019 | 水平/弹出菜单导航、选择、取消、禁用与窄屏状态条可组合；证据待实施时链接 | pending |
| AC-020 | REQ-004、REQ-011 | 应用退出与终端模式恢复 | TASK-020 | 当前在冻结Linux配置正常退出、异常及取消均按平台契约清理模式/光标；其他OS后续扩展；证据待实施时链接 | pending |
| AC-021 | REQ-001 | 交付 U1–U5 公开接口示例 | TASK-021 | M1 minimal/composition独立项目构建；不同业务U5无内核特判；四主题完整展示归AC-027，M2归AC-031；证据待实施时链接 | pending |
| AC-022 | REQ-004 | 交付可重复渲染基准项目 | TASK-022 | 固定尺寸、中文/emoji 和批更新负载可运行，记录环境与重复结果；证据待实施时链接 | pending |
| AC-023 | REQ-006、REQ-011 | 验证最终源码制品可独立使用 | TASK-023 | 实际cjp无开发资料，含四主题及统一展示；TASK-027/031/032等交付纳入制品，当前Linux冻结配置干净消费构建运行，其他OS在Linux全量验收后扩展；目标依赖/版本/许可证完整；证据待实施时链接 | pending |
| AC-024 | REQ-001–011 | 整体验收与发行准备 | TASK-024 | 当前Linux范围的需求全部有证据（含M2），产品文档与制品一致；后续OS独立扩展验收，不宣称跨平台完成；Battle 无未关闭必需失败；证据待实施时链接 | pending |
| AC-025 | REQ-008 | 分类主题配置解析与诊断 | TASK-025 | 合法单文件主题形成结构化配置；未知字段/非法值/坏引用带位置错误，不执行代码；产品证据待实现 | pending |
| AC-026 | REQ-008 | 应用主动主题重载与原子替换 | TASK-026 | 有效重载同批次生效；失败保留旧主题，旧请求不覆盖较新请求，状态/焦点保留；产品证据待实现 | pending |
| AC-027 | REQ-008、REQ-006 | 四套预置主题及统一组件展示 | TASK-027 | 深/浅/高对比/经典主题用同一展示应用，覆盖组件状态、受限色和窄屏；制品独立运行；产品证据待实现 | pending |
| AC-028 | REQ-001.8、REQ-009 | 基础输入编辑与标准快捷操作 | TASK-028 | 单/多行输入、Unicode簇级移动删除选择、剪贴板结果、撤销重做；Enter默认正确，坏粘贴不误提交；产品证据待实现 | pending |
| AC-029 | REQ-001.8、REQ-009 | 按钮标签与选择进度基础组件 | TASK-029 | 标签/按钮/单选/复选/进度条通过公开接口组合，状态可控、事件一次、主题一致；产品证据待实现 | pending |
| AC-030 | REQ-010 | 可选会话能力与本地剪贴板通道 | TASK-030 | SSH复制目标为用户本地，粘贴接收不主动读；标题/图片图标按支持证据，发送与确认分开；缺能力不影响核心；产品证据待实现 | pending |
| AC-031 | REQ-004.8 | M2局部布局绘制及基线对照 | TASK-031 | 局部负载减少无关工作，移动/遮挡/宽字符/resize与M1帧结果一致，记录CPU/分配/输出及大范围退化；产品证据待实现 | pending |
| AC-032 | REQ-001.9、REQ-002.7/.8 | 混合子元素操作与定向通知集成 | TASK-032 | 声明A/B/C中插X融合排序位置；显式移动/移除、无效锚点/卸载/重入操作有诊断；定向通知合批无手动flush；产品证据待实现 | pending |
| AC-033 | REQ-007 | 本轮规格与追踪一致性 | TASK-033 |R5最终严格检查与覆盖记录；实际证据：R5/validation-final.txt、check-consistency.mjs及re-review.md| passed |
| AC-034 | REQ-001 | SDK语言隔离调查交付 | TASK-034 |R5语言正负例、重跑及闭包/收集边界；不替代AC-002/004完整验收；实际证据：R5/evidence/README.md语言正负例；主代理重跑退出0| passed |
| AC-035 | REQ-007 | 独立设计审核 | TASK-035 |R5受审版本、findings及修复独立复核；仅design_reviewed；实际证据：R5/re-review.md：5项发现verified，固定修复版本070623f1014a48bd559364747550c48332c16201| design_reviewed |
| AC-036 | REQ-004、REQ-005 | 依赖选型有界调查交付 | TASK-036 |三项直接依赖及bitarray元数据/摘要、分段/宽度/ANSI和联合消费、失败及原生/许可边界；不替代AC-003完整集成；实际证据：R5/evidence/README.md、包摘要、分别及联合消费；原生/许可限制明确保留| passed |
| AC-037 | REQ-003.10/.11、REQ-009.1 | 通用视口内容访问 | TASK-037 | 80×24访问100行、宽表横向、宽字符裁剪与resize偏移/焦点保持；产品证据待实现 | pending |
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
| AC-061 | REQ-001/005/007 | TASK-061 | 独立颜色/属性/输出模式测试及真实RED | pending |
| AC-062 | REQ-007 | TASK-062 | 固定技术diff的spec/quality独立审核 | pending |
| AC-063 | REQ-005/006/007 | TASK-063 | cold全入口/真实PTY/标准bundle/clean消费者 | pending |
| AC-064 | REQ-005/007 | TASK-064 | 有限合同与最终集成独立验收 | pending |
| AC-065 | REQ-005/007 / 用户自动适配与跨终端截图约束 | TASK-065 | 实际能力来源探针、跨宿主矩阵及真实截图方法 | pending |
