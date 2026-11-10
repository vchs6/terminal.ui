# 标准控件公开组合候选

状态：required / planned / pending。2026-11-10 独立起草；待主代理裁决、正常 SDK 签名验证和独立 preflight。没有修改产品、正式测试或主仓任务状态；本文不是冻结记录。

## Why

REQ-001.8、REQ-003 与原 TASK-019/029 已要求标准控件。Runtime C、RichText、Theme 和交互 primitive 合同提供共同基础，但不能用这些基础的存在替代控件的公开构造、受控值、一次激活和菜单导航证据。应用应组合菜单、内容、状态栏、按钮和进度，无须触碰 RuntimeNode 或输出终端字节。

## What Changes

- 单元 S（153–157，父 TASK-029）：Label、Button、Checkbox、Radio、Progress；受控 getter 和请求回调、精确非法输入、ASCII 默认标记、主题角色与公共事件阶段。
- 单元 M（158–162，父 TASK-019）：MenuEntry、HorizontalMenu、PopupMenu、StatusBar；附同批公共 SplitPane 薄组合，关联 TASK-011/REQ-003.1，不篡改原 TASK-019 范围。
- 每单元固定测试编写→产品→审核→测试执行→验收五个独立角色，输入按 hash 固定。新增签名全部未编译；前置未验收时不 ready。

## Capabilities

### New Capabilities

- `standard-widgets`：现有标准控件目标的精确公开组合、状态、导航、主题及验收投影。

### Modified Capabilities

无须重定义 Runtime C、RichText、主题、布局、焦点、viewport 或 overlay。必要公共缺口由主代理回到所属 primitive 合同修订；不得藏进控件私有路径。

## Impact

拟新增根包公开纯组合工厂、MenuEntry 与 SplitAxis 值类型、两组公共消费者/测试和文档；沿用 Component/Text/Row/Column/Canvas、ForEach/ListItem、NodeRef、唯一 resolver/LayoutNode/Frame/Unicode 内核。布局算法、设备 decoder、主题 schema、运行时节点种类均非本件修改范围。实际产品路径待前置固定接受源映射，不能预先虚构上游文件。

原TASK-019/029及支持153–162唯一任务状态已转至本变更tasks.md，docs/tasks.md只保留编号及原AC引用，不维护第二份勾选状态。U2/U4/U5 和 TASK-027 四主题完整展示仍需后续集成证据，162不自动关闭它们。Linux 全部验收、发布、其他平台不由本件宣布完成。
