# Public interaction primitives

## Why

当前公共 Text/Column/Row、NodeRef 与事件路由不能让用户组件实现受控自绘、焦点、滚动和层级交互。内置控件若先行补私有 kind，会绕过用户公共API并产生重复渲染/生命周期；本变更先交付共同基础。

## What Changes

- A：新增一个公共 Canvas 叶及独立 measure/draw 依赖、局部 PaintContext、选区样式、会话 caret；enabled/focusable、可跟踪只读查询、目标/祖先默认动作和物理子序列焦点。最小设备解码新增 HT→tab、CSI Z→backtab；KeyEvent仍只有code/text。
- B：通用 viewport 修饰、默认纵向 ScrollView、表格横滚和 ensureVisible。Application根未声明viewport时默认Vertical兜底，可用root.viewport(Off)关闭；普通非root Column不隐式滚。根先保旧短内容布局，仅未承接overflow时再作一次自然内容协商；指南主体ScrollView、菜单/状态条留普通布局，不修改业务显隐。标准键滚是通用viewport能力，每节点用户Ancestor之后才尝试，ScrollView不重复登记回调。
- C：同Runtime节点的owner依赖层、宿主裁剪、锚点、modal/nonmodal/passive、级联关闭及焦点恢复；公共surface填充意图保证无背景modal不透底又不压死主题。
- 替换当前设备root固定目标与分散默认退出分支；保留现有公共事件控制、Style/Frame/Unicode/ansies和M1完整参考。新增行为按安全边界提交，组件不取得stdout/ANSI或可变整屏Frame。
- 仅冻结交互基础。Button/Progress/InputCaret是公共消费者证明，不交付TASK-019/028/029的完整菜单、编辑或标准控件API；鼠标、拖动、剪贴板及M2不在本变更。

## Capabilities

### New Capabilities

无新顶层capability；复用既有职责目录，避免将同一UI runtime拆成平行规范权威。

### Modified Capabilities

- `ui-runtime`：精确化焦点、默认动作、视口、层域和生命周期边界，新增公开基础接口的可观察要求。
- `ui-construction`：公共Canvas与同组件普通/层复用、主体默认ScrollView的构造契约。
- `terminal-output`：逻辑caret与画面统一提交、过期绘制上下文、透明/opaque surface及不改变M1参考的保证。

## Impact

产品仅Linux当前阶段；SDK1.2.0、现有依赖版本与正常CJPM/bundle路径，无新增第三方运行时。主要影响Component/NodeRef/Application/RuntimeSession、唯一布局/样式resolver/Frame、InputDecoder和设备caret桥接。每公开/内部类型单文件，纯数据可下沉无root循环，受控句柄与Context留根包。

依次交付A(098–102)→B(103–107)→C(108–112)，父项分别TASK-017/037/018。A产品准入消费已验080、084和主题基础088；不等待异步主题092。父020退出恢复仍保留完整责任，030可选会话能力不在本件。独立目录只创建规划产物，全部新签名尚未编译验证；需实际SDK签名微编译、独立preflight与DQ后才具备测试/产品准入。主代理采纳决策不代表产品实现或父AC通过，本轮不改主仓、不写产品/正式测试、不发布。
