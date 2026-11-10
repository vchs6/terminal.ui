# Public interaction runtime delta

## MODIFIED Requirements

### Requirement: 覆盖层与焦点

框架 SHALL 支持菜单、弹窗及进一步模态确认，定义层所有权、输入隔离、键盘导航、禁用项及关闭恢复；关闭父层同时关闭附属层。覆盖层使用同一组件节点与生命周期，普通children物理顺序不因层宿主而重排，宿主只决定层几何与裁剪。标准菜单/Modal构造仍由各自后续任务交付，不以本基础协议通过替代全部组件验收。

#### Scenario: 关闭恢复
- **WHEN** 关闭模态层时原触发节点已卸载
- **THEN** 按design的owner祖先、原物理后继/前驱、新域首个规则恢复有效焦点，不访问失效引用，显示底层最新状态。

#### Scenario: 非交互层
- **WHEN** 视觉上层仅用于装饰
- **THEN** 不因其最高显示顺序自动抢焦点，但真实不透明绘制仍遮挡下方caret。

#### Scenario: Owner cascade
- **WHEN** owner或父层卸载，或owner显式隐藏
- **THEN** 依赖闭包中的附属层同步关闭，先使句柄与订阅失效再清理，每个cleanup至多一次，只恢复一次焦点。

#### Scenario: Presentation host
- **WHEN** 弹层超出触发节点内容盒但仍处于显式宿主有效clip
- **THEN** 弹层在该clip内可见，不能越过宿主/终端边界，事件归属和主题继承仍由owner决定。

### Requirement: 实际尺寸与滚动

框架 SHALL 以终端实际行列为根布局边界，响应尺寸变化；ScrollView默认纵向滚动，公开构造指南默认将主体置于ScrollView，固定菜单/状态条留在普通布局；Application根未显式声明viewport时默认Vertical兜底，显式None关闭，其他显式axes优先；普通非root Column不隐式滚动。表格允许显式Horizontal/Both，单行输入内部视口保持光标可见；组件显隐由应用显式确定。

#### Scenario: 固定小控制台
- **WHEN** 实际80×24且应用最小尺寸100×30
- **THEN** 仍以80×24布局，不强制放大或维持超大最小画布；主体的100行可通过标准纵向视口访问，固定菜单/状态条不滚动。

#### Scenario: 缩放与可见性
- **WHEN** 窗口缩小再恢复
- **THEN** 重新分配可用空间并钳制有效偏移，保留节点状态和有效焦点，不因空间变化自行隐藏分区。

#### Scenario: Horizontal table
- **WHEN** 宽表选择Horizontal或Both并请求水平滚动
- **THEN** 可访问所有逻辑列，宽字符左右边缘整簇裁剪，最终帧尺寸仍为真实终端尺寸。

### Requirement: 键盘事件与模态域

框架 SHALL 提供归一化键盘事件、预处理拦截、停止传播及阻止默认行为；capture、bubble、允许域app和legacy之后，执行目标默认、框架interrupt/Escape/Tab、祖先默认。模态时下层app/legacy均不接收事件，域外显式dispatch报FocusOutsideDomain；未阻止的键盘interrupt仍退出全应用，外部会话取消不成为可消费键盘事件。

#### Scenario: 事件消费
- **WHEN** 焦点组件处理一个按键并停止传播
- **THEN** 父组件及应用处理器不重复执行业务动作，但默认行为仅在preventDefault或consume时被阻止。

#### Scenario: 模态未处理
- **WHEN** 模态窗口内没有组件处理某全局快捷键
- **THEN** 不得穿透执行下层应用快捷动作；关闭后恢复有效焦点。

#### Scenario: Keyboard interrupt
- **WHEN** 模态内收到未preventDefault的interrupt
- **THEN** 目标默认完成后停止整个应用，清理层与节点并恢复终端，而不是只关闭当前弹层。

#### Scenario: Minimal Tab decoding
- **WHEN** 设备接收HT字节或无参数无中间字节的CSI Z，包括分块到达
- **THEN** 分别产生code为tab或backtab且text为空的现有KeyEvent，按当前域前进或后退焦点，不新增虚构修饰键字段。

## ADDED Requirements

### Requirement: Compatible default root scrolling

框架 SHALL 对隐式Application根先执行原有限布局，只有未被显式fixed高度裁剪或独立纵向viewport承接的overflow才再协商一次自然内容extent，最多两pass；外盒始终实际尺寸。短内容原权重分配保持，内容变化不触发无限布局稳定循环。

#### Scenario: Short weighted compatibility
- **WHEN** 高10的隐式Column根有两个weight=1、min=0、自然高1和3的孩子
- **THEN** 原5/5分配保持，不无条件改变为自然基准4/6，根offset为0。

#### Scenario: Overflow reallocation
- **WHEN** 同样根的孩子自然高为8和1，第一次5/5截断前者
- **THEN** 第二次按自然基准8/1加既有余数分配为9/1，extent10，不再循环；裸100行则extent100并可滚。

#### Scenario: Fixed and independent viewport boundaries
- **WHEN** 某子树显式height(3)但未启纵滚，或主体已用独立Vertical ScrollView承接100行
- **THEN** 前者保留声明裁剪，后者只滚自己的内容；两者内部overflow均不让隐式root额外扩张。

#### Scenario: Wrapped and zero-size root
- **WHEN** 实际分配宽度使文本wrap后纵向overflow，或实际根内容高度为0
- **THEN** 使用该宽度的真实视觉行数决定根extent，最多两pass；零轴不绘制或显示caret，不强撑min或改变业务visible。


### Requirement: Focus eligibility and physical order

框架 SHALL 以当前域内有效、visible、enabled、focusable节点为候选，按普通真实children深度优先前序遍历，不排序业务数据。视口外节点仍可候选，进入焦点后确保可见；同key重排保持身份和焦点，失效时按design确定回退。

#### Scenario: Keyed mixed reorder
- **WHEN** ForEach节点与manual节点交错且key重排
- **THEN** 当前焦点仍指相同有效node，下一次Tab采用提交后物理序列，marker不参与遍历。

#### Scenario: Empty or zero viewport
- **WHEN** 域内无候选或实际viewport为零
- **THEN** 空候选时focusedNode为None且可用域根仍可成为activeTarget；零尺寸本身不清除有效焦点身份，caret隐藏。

### Requirement: Readonly interaction observations

框架 SHALL 允许同UI域属性getter读取Component.reference及可跟踪focus/activeTarget/viewport查询，而不驱动pump或授予修改权限。跨session活动域仍拒绝；失效NodeRef按既有规则诊断。

#### Scenario: Visual focus binding
- **WHEN** 用户在visualStates getter中读取自身reference及isFocused
- **THEN** getter能随焦点变化更新外观，但不能在该求值中requestFocus、滚动、改结构或进入别的session。

### Requirement: Default action phases

框架 SHALL 为公共组件提供Target与Ancestor两个默认槽，每槽后写替换，同一事件每个所属节点至多调用一次；每节点用户Ancestor之后、未prevent时才尝试该节点viewport标准键滚，接受变化即prevent后续。stopPropagation不停止默认，preventDefault停止剩余默认；事件有效期延至全部默认完成。

#### Scenario: Nested page movement
- **WHEN** 输入目标默认处理PageDown并preventDefault
- **THEN** 祖先ScrollView默认不再滚动；目标未处理时，最近能移动的viewport消费事件且其外层不再滚动。

#### Scenario: Ancestor before viewport default
- **WHEN** 当前节点用户Ancestor处理滚动键并仅stopPropagation，或改为preventDefault
- **THEN** 前者仍允许该节点viewport标准滚动，后者阻止；ScrollView及隐式root共用此语义，不重复登记另一滚动回调。

### Requirement: Unified viewport commands

框架 SHALL 使用节点代际内唯一offset状态，提供受控滚动与ensureVisible，按最后几何及已排队offset计算接受变化，再在边界按最新extent钳制。offset查询不触发布局，滚动不修改业务数据或visible。

#### Scenario: Accepted scroll and resize
- **WHEN** scrollBy已按当前几何返回true但同turn内容缩短
- **THEN** 返回值只表示接受了变化，最终offset按新extent钳制，不保证设备已移动或保留旧偏移。

#### Scenario: Nested ensure visible
- **WHEN** 指定内容rect位于嵌套viewport外
- **THEN** 从内向外确保其可见，外层使用内层可见片段；不会跨overlay宿主反向滚动触发组件。

### Requirement: Anchored overlay lifetime

框架 SHALL 按同session合法owner/host/anchor建立层，Modal仅无anchor居中；非modal锚点用最新布局/滚动几何定位，失去有效可见锚点时关闭。owner仅disabled不隐式关闭或禁用已打开层；owner显式hidden关闭附层。

#### Scenario: Scrolled-away anchor
- **WHEN** 非modal锚点经滚动后与宿主clip无交集
- **THEN** anchored层以AnchorGone结束，依赖层一并关闭，不留下漂浮菜单或无效焦点。

#### Scenario: Owner button disabled
- **WHEN** 打开层后应用仅禁用触发按钮以防重复打开
- **THEN** 已打开层保持自己的enabled语义，层内交互不因跨owner关系继承disabled而失效。
