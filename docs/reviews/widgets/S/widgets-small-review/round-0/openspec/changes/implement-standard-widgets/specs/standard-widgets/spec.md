## ADDED Requirements

### Requirement: 标准控件使用唯一公开组件模型

框架 SHALL 通过用户可获得的Component/Text/Row/Column/Canvas与事件/状态/主题/布局/overlay公共能力提供本件控件，不新增控件专用kind、私有RuntimeNode入口、第二renderer/layout/theme/Unicode内核或终端直接输出。所有新增签名在本候选中仍未编译、产品未实施。

#### Scenario: 公开构造与跨宿主复用

- **WHEN** 应用通过正式原始组件块和公开工厂组合五个小控件以及菜单/状态栏/分区，并把同一自定义面板类型的两个实例用于普通容器与覆盖层
- **THEN** 两者共享相同公开API和业务模型，各自保持合法挂载身份，无内核业务特判或第二Application

#### Scenario: 非法主题能力不静默忽略

- **WHEN** 应用通过typed setStyle、getter属性或已解析的命名/Inline样式把容器gap应用到Text根控件，或给Progress设置静态文字wrap属性
- **THEN** 沿唯一能力验证抛UIException("InvalidProperty")，不因主题角色名获得不存在的primitive能力

#### Scenario: 继承的旧常量快捷入口保留异常契约

- **WHEN** 应用在Text根Label/Button/Checkbox/Radio/MenuItem调用既有gap(Int64)、alignItems(Alignment)或justifyContent(Alignment)等布局合同明确不适用的旧常量快捷入口
- **THEN** 与原Text一致立即抛IllegalArgumentException并保留旧设置；不得获得容器能力，也不得改成按widget角色区分的异常；旧容器textAlign与非法Stretch等既有边界同样保持

此LEGACY-PROP-001仅保留已有布局入口合同；新typed/getter/样式目标检查仍严格InvalidProperty。主题配置已知role不支持字段仍为UnsupportedProperty诊断，程序化非法样式数值仍按T013原边界抛IllegalArgumentException。

### Requirement: 精确受控签名与单行Unicode caption

框架 SHALL 提供design W001列明的常量/getter重载、必需callback和可选label，不提供Checkbox/Radio内部可写Bool初值模式。caption SHALL 复用唯一plain-text验证并拒逻辑换行，空值合法，Unicode宽簇由唯一Text路径处理。主题和用户的合法wrap仍可使单行逻辑caption视觉换行。

#### Scenario: 最新getter与空caption

- **WHEN** 业务getter的caption由长Unicode文本变短或变空
- **THEN** 控件重新呈现最新文本且清除旧内容；Checkbox/Radio空caption仅显示三字符标记，不残留分隔空格

#### Scenario: 非法caption

- **WHEN** caption常量或getter包含ESC、非法控制、LF、CR、U+2028或U+2029
- **THEN** 报IllegalArgumentException，getter失败走既有Runtime清理，不将控制内容直接发终端

### Requirement: 选择值由业务唯一拥有

Checkbox SHALL 在默认激活时读最新checked一次并请求onChange取反一次，不自行写业务值；Radio SHALL 只在最新selected为false时请求onSelect一次。分组互斥 SHALL 由业务共同模型表达，不按caption或私有注册表推断。

#### Scenario: 应用不接受变更请求

- **WHEN** checked=false的Checkbox收到一次合法激活，而onChange只记录请求、不写业务状态
- **THEN** callback收到true恰一次，下帧仍显示`[ ]`，没有内部乐观切换

#### Scenario: 已选Radio与共同模型

- **WHEN** 已选Radio收到合法激活，或两个相同caption的Radio绑定不同业务身份
- **THEN** 已选项onSelect为0次且合法激活键被消费；重复caption不制造分组，互斥只由应用模型变化产生

### Requirement: 一次目标默认激活与统一禁用

Button/Checkbox/Radio/MenuItem SHALL 使用公共Target defaultAction，仅有效enabled且focused目标处理enter或单ASCII空格text。之前preventDefault阻止激活，stopPropagation单独不阻止；完成激活先preventDefault再调用callback。S从首次实现消费117固定接受源并 SHALL 排除ctrl/alt/shift修饰事件和paste。事件资格取公共已提交快照，不在传播中私自flush结构。

#### Scenario: 传播取消与请求次数

- **WHEN** capture、bubble或app回调preventDefault，或只stopPropagation
- **THEN** prevent路径业务callback为0次；单独stop路径合法目标仍只激活1次，祖先默认不因同键再次激活

#### Scenario: 禁用与当前事件的边界

- **WHEN** 目标或普通祖先在dispatch开始已disabled，或合法未聚焦目标被显式dispatch；又或前置回调更改尚未提交的enabled值并preventDefault
- **THEN** 已disabled目标按公共路由拒绝，未聚焦目标不执行控件激活，preventDefault取消当前动作；无私有中途协调

#### Scenario: 修改键与异常

- **WHEN** 完整输入后收到Alt+Space、paste空格，或业务callback抛异常
- **THEN** 修改键/paste不激活；异常保留首错并走统一cleanup/native恢复，不吞错或重试callback

### Requirement: ASCII默认控件皮肤与统一主题状态

Checkbox SHALL 使用`[ ]`/`[x]`、Radio使用`( )`/`(*)`，非空caption前只加一个空格；Button/Label直接呈现caption。ThemeRole SHALL 使用真实T003名称。交互A I012的同一resolver SHALL 自动合成真实disabled/focused与声明态，selected仍只来自声明；控件不得私读或复制行为态。

#### Scenario: 离线、祖先禁用和后链enabled

- **WHEN** detached render或mounted会话中存在disabled祖先，或控件后链enabled(false)，并声明VisualStates.disabled=false
- **THEN** 两种路径都得到有效disabled外观；false不能掩盖真实态，没有detached假NodeRef

#### Scenario: 外观模拟不修改行为

- **WHEN** enabled控件声明VisualStates.disabled=true或focused=true
- **THEN** 仅样式变化，不禁用事件或移动焦点；用户可通过现有显式样式逐字段覆盖颜色，不能反向写业务状态

### Requirement: Progress有限分数与纯绘制依赖

Progress SHALL 接受finite Float64的0..1，非法值在求值时InvalidProperty，不夹改业务数据。Canvas自然内容尺寸 SHALL 为20×1，fraction只在draw读取；分配宽w时首floor(fraction*w)列`=`其余`-`，仅y=0，宽高0安全。显式viewport时使用Canvas有限逻辑extent与clip。

#### Scenario: 精确条宽与布局覆盖

- **WHEN** fraction=0.5且分配宽分别0、1、20，或主题/显式宽高改变实际分配
- **THEN** 满格数分别0、0、10；无除零，无越界；自然20×1不通过显式width20压住主题

#### Scenario: 无效值与paint-only

- **WHEN** fraction为NaN、无穷、负值、大于1，即使分配宽0；或仅合法fraction变化
- **THEN** 无效值统一InvalidProperty；合法变化只增加paint依赖失效而不将fraction加入measure读集，M1完整measure调用仍允许

### Requirement: 菜单保持业务数据与稳定身份

MenuEntry SHALL 为稳定非空key、单行label、默认true的enabled不可变数据。菜单 SHALL 使用ForEach/保留ListItem.value，不排序业务数据，不推断业务命令，不捕获首次值；重复key由原Runtime C预检拒绝。

#### Scenario: 同key换值和重排

- **WHEN** items getter替换同key的label/enabled并重排
- **THEN** 节点及有效焦点身份保留且读取新值；应用源数组不被修改，禁用当前项时由公共焦点修复规则接管

#### Scenario: 重复与重新加入

- **WHEN** 一批出现重复key，或删除后重新加入相同key
- **THEN** 重复批DuplicateKey且没有部分新挂载；重新加入是新代际，旧ref不复活

### Requirement: 菜单实际键盘导航

HorizontalMenu SHALL 按左右、PopupMenu按上下循环eligible own entries，Home/End取首尾；Enter/Space请求onChoose稳定key一次。导航 SHALL 依据公开children实际顺序过滤自己创建的entry refs，不读私有树或解析任意孩子。Tab沿框架顺序且不trap。

#### Scenario: disabled、单项、空集合与手动move

- **WHEN** 菜单中有disabled项、只剩一个eligible项、全部disabled，或应用公开同父move其entry
- **THEN** disabled被跳过；单项导航键仍消费但不发选择回调；全空无候选/无激活；move后箭头与实际呈现顺序一致

#### Scenario: 不属于菜单的按键或孩子

- **WHEN** Popup收到左右键、Horizontal收到上下键，或焦点是应用手动添加的非entry孩子
- **THEN** 菜单不猜测业务语义，不执行菜单导航/选择，可由正常祖先viewport处理

### Requirement: Popup复用公共覆盖层

PopupMenu SHALL 是普通Column内容、使用公开opaque surface而不显式background(Default)，通过应用openOverlay和持有的handle组合。控件不自动开Application、嵌套层或选中即关闭；Escape、modal域、owner/anchor、关闭恢复由overlay权威处理。

#### Scenario: 选择及取消

- **WHEN** Popup在overlay中选择entry或按Escape，或同内容内联使用
- **THEN** 选择只调用onChoose，是否close由应用决定；Escape遵当前层closeOnEscape并恢复焦点，内联内容不伪造层关闭

#### Scenario: 空层与父层关闭

- **WHEN** takeFocus popup全部disabled，或其owner父层关闭
- **THEN** 公共activeTarget仍让允许的Escape可达，父层依赖闭包正确关闭且下层显示最新业务数据，无孤儿菜单

### Requirement: StatusBar与SplitPane为普通布局组合

StatusBar SHALL 是Row role StatusBar的自然高度，不强制显式height1、不自动贴屏幕底部；应用可显式height(1)，主题可正常配置高度。SplitPane SHALL 按不可变SplitAxis选择Row/Column并使用ThemeRole.SplitPane，不添加分隔glyph、隐式权重、拖动或新布局算法。

#### Scenario: 状态栏自然尺寸和主题

- **WHEN** body为空、普通单行、多行，或主题height1/用户显式height冲突
- **THEN** 严格采用原Row自然尺寸与四级样式优先级；普通单行无装饰时通常为1，不能隐含私有intrinsic规则

#### Scenario: 窄屏、嵌套分区与固定栏组合

- **WHEN** 应用组合菜单、主体ScrollView、StatusBar及横纵SplitPane，实际终端变窄/为零或弹性余量不能整除
- **THEN** 原布局稳定分配与实际clip生效，业务visible不被修改；固定栏只由应用布局表达，无强撑虚拟最小画布

### Requirement: 独立证据与准入诚实

本件 SHALL 在正常SDK签名验证、上游含I012的固定接受输入、独立preflight后才进入产品ready。153–157与158–162各遵测试/产品/审核/执行/验收五独立角色，静态文档/hash/语言微编译不代替产品行为证据。

#### Scenario: 前置尚未接受

- **WHEN** Runtime080、Rich084、Theme088、glyph097、交互A/I012、S/M共同所需117或M所需107/112未获固定接受证据
- **THEN** 相应产品任务维持planned/blocked并列明缺口，不宣称控件API已实现或Linux全部完成
