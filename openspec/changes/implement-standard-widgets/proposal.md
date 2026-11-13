# 标准控件公开组合候选

状态：有限S已交付；2026-11-13。S01–S05的TASK153–157已完成：独立157为PASS_FINITE_S（spec/quality/evidence PASS），接受源1df1325f7b51777d8adab62f950c936051aa5876对应main 85998ead2b53cb8e6a6ab8c69e5e3efb8739411f；源码/native/构建/包配置/examples/tests/控件产品文档逐字节一致。[有限S原件与真实宿主图](../../../docs/reviews/widgets/S/README.md)。五个公开控件Label/Button/Checkbox/Radio/Progress已交付；155独立双审0具体缺陷，156普通制品/干净消费/真实XTerm、VTE、kernelVT执行已交付。M158正式独立测试已完成：原测试e59d5c9f对应main9ec836ce，51手工catalogue cases；前置build/direct0（含42项S修饰键排除），孤立6项缺M目标编译RED1/classifier0。M159已交付产品候选6f7d6fee，固定验证源6e3f26aa及独立测试ad100b79/tree ff16e53f；作者formal runner0、53项headless与真实PTY退出0/21/22、正常example build/bundle0属developer proof，非161真实宿主/162验收。M160由fresh独立Astra/high审查中；161–162 planned，M候选产品尚未合入main，完整M/父019/027/Linux保持未接受。新native S只覆盖ASCII/default Classic；Unicode/disabled/explicit palette是headless S/source155及限定E后端机制复用，完整all-state/Unicode/four-theme展示仍属027/041。完整Linux/M/M1M2/父019/020/030/发布未关闭，B-M01→024、T087→023保留。

## Why

REQ-001.8、REQ-003 与原 TASK-019/029 已要求标准控件。Runtime C、RichText、Theme 和交互 primitive 合同提供共同基础，但不能用这些基础的存在替代控件的公开构造、受控值、一次激活和菜单导航证据。应用应组合菜单、内容、状态栏、按钮和进度，无须触碰 RuntimeNode 或输出终端字节。

## What Changes

- 单元 S（153–157，父 TASK-029）：Label、Button、Checkbox、Radio、Progress；受控 getter 和请求回调、精确非法输入、ASCII 默认标记、主题角色与公共事件阶段。
- 单元 M（158–162，父 TASK-019）：MenuEntry、HorizontalMenu、PopupMenu、StatusBar；附同批公共 SplitPane 薄组合，关联 TASK-011/REQ-003.1，不篡改原 TASK-019 范围。
- 每单元固定测试编写→产品→审核→测试执行→验收五个独立角色，输入按 hash 固定。S签名已编译并有限验收；M正式测试/实现未交付，前置未核验时不 ready。

## Capabilities

### New Capabilities

- `standard-widgets`：现有标准控件目标的精确公开组合、状态、导航、主题及验收投影。

### Modified Capabilities

无须重定义 Runtime C、RichText、主题、布局、焦点、viewport 或 overlay。必要公共缺口由主代理回到所属 primitive 合同修订；不得藏进控件私有路径。

## Impact

拟新增根包公开纯组合工厂、MenuEntry 与 SplitAxis 值类型、两组公共消费者/测试和文档；沿用 Component/Text/Row/Column/Canvas、ForEach/ListItem、NodeRef、唯一 resolver/LayoutNode/Frame/Unicode 内核。布局算法、设备 decoder、主题 schema、运行时节点种类均非本件修改范围。实际产品路径待前置固定接受源映射，不能预先虚构上游文件。

原TASK-019/029及支持153–162唯一任务状态已转至本变更tasks.md，docs/tasks.md只保留编号及原AC引用，不维护第二份勾选状态。U2/U4/U5 和 TASK-027 四主题完整展示仍需后续集成证据，162不自动关闭它们。Linux 全部验收、发布、其他平台不由本件宣布完成。
