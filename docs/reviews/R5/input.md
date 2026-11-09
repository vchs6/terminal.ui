# R5 审查输入

## 范围、分类与授权

日期2026-11-09；基线 b8ce41857e37186cadfbbbc3586a9f8f5e67ece4。具体受审commit由独立审核记录填写，不能只引用可变工作树。本轮变更为 refine-terminal-ui-contracts。用户授权规格修订、变更提案、必要隔离验证、第三方独立审核、完成后直接推送main；不授权产品实现或发布。版本要求三段数字，当前开发状态0.0.0，第三方版本保留。

TASK-033属已确认方向文档落实，TASK-034含技术选型决策，TASK-035为独立设计验证。用户已选择持久运行节点＋可重算描述、M1/M2；配置格式及状态合并等工程细化在design中明示，未伪称用户逐项指定。

## 用户要求覆盖

- 通用字符网格文本终端，非GUI；业务处理数据/动作，视图组织呈现/顺序/显隐，框架渲染。
- ArkUI声明习惯、仓颉业务回调、自定义组件、动态视图元素API共享容器子序列。
- 响应式与显式定向通知，内容/状态/样式/布局/结构失效，M1全帧差分、M2局部绘制。
- 所有已列基础组件、横纵嵌套与固定/内容/比例尺寸、最大视口利用；实际尺寸不足时仍按实际大小，框架不自动隐藏；纵向滚动，表格横向。
- Unicode包含emoji，键盘事件优先，标准编辑快捷键、单/多行Enter；事件焦点→父→应用，模态隔离。
- 系统剪贴板指本地设备（含SSH）；标题及实际图片图标按宿主能力可选，不以名称/界面图片冒充。
- 分类主题配置、全局状态样式、显式属性优先，四主题及同一展示应用；应用控制加载/切换/重载，无默认监听。
- 中心仓unicode/unicodewidth比较选型、ansies评估，必要验证自主执行。

## 工具与技能

OpenSpec1.14.3固定于package-lock；使用仓库可发现的openspec-propose与openspec-sync-specs，已运行list/context/new change/status/instructions并按输出路径创建工件。必需本地Superpowers7.0.0来自tools.lock锁定obra/superpowers完整revision bb92a77741419a4ab5f06e711a283343f1ada0c3，setup完成且.agent链接技能可读。

主代理已实际读取并使用云技能using-superpowers、brainstorming（前序讨论）、writing-plans（映射本变更tasks）、dispatching-parallel-agents、requesting-code-review、verification-before-completion；工具安装遇只读home缓存/配置失败时读取systematic-debugging，用workspace内npm cache和XDG_CONFIG_HOME定位修复。未修改HOME、未放宽摘要校验。收到审核反馈再调用receiving-code-review。环境工具准备按cloud-environment-runtime及packages/networking说明。

分工：隔离技术验证代理只写R5/evidence；主题/会话文档代理仅写两个delta及三份长期文档（GPT-6.1 Sol/high）；主代理整合核心契约与追踪。最终审核使用未参与撰写、无会话历史的独立代理（GPT-6 Astra），不以撰写者自查替代独立审核。模型选择遵用户要求；审核是独立AI代理，不是外部机构认证。

npm安装默认缓存失败是执行环境home不可写，使用 --cache /workspace/work/npm-cache 成功；OpenSpec默认配置同理，XDG_CONFIG_HOME=/workspace/work/tool-config 后setup成功。该环境路径不成为产品要求。

## 技术证据与边界

[R5证据](evidence/README.md)包含真实SDK摘要、源码、正负例、重跑脚本、包索引与摘要及许可证缺口。只证明记录样本，不证明框架、完整ArkUI、完整Unicode、终端兼容、系统剪贴板、图标、主题或性能。产品AC-001–032继续pending。

## 独立审核要求

按BATTLE_PROTOCOL与DQ-01–14检查：需求覆盖、旧规划冲突、增量/主规格一致性、任务/验收/唯一状态映射、可判定场景、编译证据范围、字符终端边界、可选能力确认/失败、依赖原生构建与许可、M1/M2阶段及公开API不变。用真实文档位置/最小反例提出问题，严重性blocker/major/minor/suggestion；不要把待实现产品缺失视为本轮产品实现失败。

输入范围为本commit相对基线的全部diff和新增文件；检查.gitignore是否漏掉证据。审核者只写 independent-review.md 与 initial-findings.json，不改规格；主代理负责修复，审核者独立复核。预算每轮最多3次修复复核或60分钟有效时间，先达到者结束该轮，不因此伪造通过。
