# TASK105 独立完整 B 源码审查

固定 BASE `56c0bfdfd4b9e71d6604ba2c9a81a201da1862b4` → HEAD `252c5adf9a7ecf5a0927c0f558c314a517a7d252`。规格 **CHANGES_REQUIRED**；质量 **CHANGES_REQUIRED**。共 **7 Important、1 Minor、0 Critical**。一次完整29文件范围审查已结束，按本统一批次修复和复核。

权威为brief固定的当前design `3aa214946949afbaa79ab08a214bd2fb6bc6f9b3b2173f11d64225bc52b16ebd`，不是BASE内历史design。已审B.1–B.4/I009、B-01–B-04、相关I008/I010/R004/T008/shared约束，以及所有产品/公开示例/文档改动和固定测试入口。没有读作者报告/推理/自评、联系作者、派代理，或修改产品/正式测试/合同/main。旧interaction/theme审查原件未动。

覆盖：viewport声明presence与单节点offset；有限extent与实际Frame；I009旧分配/overflow来源/固定及独立viewport屏障/最多两次根协商；横纵约束、Unicode整簇clip与caret变换；命令顺序、Bool、共享容量、生命周期/线程/代际与取消；Ancestor-before-default；公开ScrollView组合；mounted完整M1与候选theme稳定测量集成。代码仍使用单Runtime/Frame/resolver/Unicode；未发现额外第三次根协商或extent大小Frame分配。Nearest的可达keep/两端分支已源码核对，没有编造公共等距跳跃oracle。

## 统一发现

### T105-I01 · Important · 横向滚动最终宽度分配与子节点测量不一致

位置：`src/layout_node.cj:152`, `src/layout.cj:177`。合同：B.2 滚动主轴自然/fixed/min基准、非滚动轴约束；B-01 横向内容可访问；同一布局权威。

Horizontal Row内两个weight1、Grapheme wrap Text：ABCD与EFGH；App snapshot4×1，然后scrollTo(4,0)。

**期望：** 两个孩子内容宽各4；首窗口ABCD，尾窗口EFGH。

**实际：** 首窗口[AB  ]，尾窗口[EF  ]；逻辑contentWidth=8，CD/GH被错误排到裁剪行。

constrain仍按实际viewport宽4的旧weighted分配2/2排版，layoutPass改按滚动extent8及naturalBasis分4/4，却没有对应重新约束。 最终分配宽度必须驱动相同子节点的约束测量与绘制，保留普通非滚动旧weighted规则和有限Frame。

### T105-I02 · Important · I009第二pass分配重新穿透独立纵向viewport屏障

位置：`src/layout_node.cj:173`, `src/layout_allocation.cj:32`, `src/layout.cj:177`。合同：I009/B.2 §3：独立纵向viewport边界使用第一pass已分配外盒需求，不能把其内部文档当根需求；B-02。

隐式Column根V10；第一孩子20行ScrollView weight1；第二孩子8行Text weight1。第一pass各5，后者溢出。

**期望：** 第二pass基准为独立viewport外盒5与普通Text自然8，extent13，分5/8，8行Text全部可访问。

**实际：** extent虽为13，实际内视口高9、Text只分4；根滚到底仍只看见4个A，另4行不可访问。

scrollingHeight遵守assignedHeight屏障计算13，但allocateMain的naturalBasis又使用child.naturalH=20，按20/8压缩为9/4，extent与分配依据冲突。 同一B2协商中extent和weighted基准都必须使用屏障截断后的需求，保留I009最多两pass。

### T105-I03 · Important · 内部viewport尺寸变化未触发旧caret确保

位置：`src/runtime_session.cj:1203`。合同：B.3/I008：viewport尺寸改变时使用最近完成帧的有效聚焦Canvas caret rect；B-03。

App保持4×1，内部Horizontal Canvas自然13×1，宽度getter初4，聚焦caret12，ensure End得到offset9并完成帧；getter宽改2，再snapshot4×1。

**期望：** 内部viewport宽变2应把旧有效caret确保到offset11，caret仍可见；无需终端外盒同时变化。

**实际：** 内部view2×1、offset仍9，输出[jk  ]，caret=false。

自动resize ensure只比较Application目标width/height与cachedWidth/Height，遗漏布局/样式导致的内部viewport尺寸变化。 依据实际相关viewport提交尺寸变化产生一次确保；同轮新显式caret意图仍优先，零轴/失焦/失效rect规则保持。

### T105-I04 · Important · mounted子树render改写Application已提交viewport与offset

位置：`src/layout.cj:114`, `src/layout.cj:118`, `src/layout.cj:326`。合同：B.1/I009 mounted render消费已提交viewport/offset；R004 M1同输入参考；唯一节点权威。

App根Off、内部Horizontal Canvas自然13×1；App4×1 scroll到9并snapshot得jkl空格。对该Canvas调用全局render(13,1)，再比较App.snapshot4×1和全局render(root,4,1)。

**期望：** 导出目标尺寸不改App已提交view4/offset9；随后App与M1同输入一致。

**实际：** 导出将内部view改13、offset钳为0；App缓存[jkl ]，M1[abcd]。

同一renderLayout无条件layoutPass提交RuntimeNode/ViewportState并应用pending ensure；导出几何混入持久App权威，而App目标缓存未同步。 离线导出布局使用独立临时几何结果，消费既有已提交状态；不得改App提交viewport/offset/待处理意图或缓存语义，仍复用唯一布局实现。

### T105-I05 · Important · ensureVisible以旧extent拒绝同轮新增内容目标

位置：`src/node_ref.cj:92`, `src/viewport_geometry.cj:39`。合同：B.3 先业务/结构与依赖稳定、再布局/钳制、再pending ensure；B.4 目标检查对应当前逻辑extent；B-03。

Horizontal Canvas自然宽由Observable给出，初4并snapshot4×1；同一个app.batch先extent.set(13)，后ensureVisible(Rect(12,0,1,1))。

**期望：** 先完成本轮新extent13的测量，再验证并确保新caret格12，offset9；仍拒绝负位置和真正超出最终extent的rect。

**实际：** 命令尚未排队就抛InvalidProperty，因为RuntimeNode.logicalWidth仍是上一帧4。

入口将需要本轮布局才能判定的范围检查绑定旧几何；不能用B.3正常同轮顺序定位新内容。 延后依赖当前布局的范围校验到正确提交阶段；保留确定性的参数错误与隐藏/代际/owner检查，不能靠rect强迫增长。

### T105-I06 · Important · Horizontal Canvas测量的非滚动高度轴仍无界

位置：`src/layout_node.cj:129`。合同：B.2 滚动轴解除上界为None，非滚动轴受viewport内容约束；A.1内容盒Constraints。

Horizontal Canvas measure记录收到约束并返回Size(8,4)；实际App4×2；读取本轮最后一次measure约束。

**期望：** X滚动轴maxWidth=None，非滚动Y轴最终内容约束maxHeight=Some(2)。

**实际：** 最后一次仍为maxWidth=None、maxHeight=None，虽最终view为4×2。

constrain只协商宽度，未把实际非滚动高度传给通用Canvas测量；仅在draw截断不等于满足公开measure约束。 使两轴内容测量遵守实际viewport/滚动轴约束；初始自然测量可以无界，但不能只留下无界非滚动轴结果。

### T105-I07 · Important · T008稳定测量在布局失效后再次丢失，错误发布主题并终止会话

位置：`src/layout_node.cj:46`, `src/layout_node.cj:132`, `src/layout.cj:281`, `src/runtime_session.cj:157`。合同：TASK105 brief直接T008集成义务；Theme T008提交前拒绝可预测布局错误、保留旧主题/活动session；禁止候选预检调用用户代码。

固定T008 Max零面积Row：Canvas自然宽1、有界返回constrain(Max)，另一weighted Row含两个grow样式Text。先App.snapshot(Max,0)，再mounted Canvas render(Max,0)；准备weight1/minWidthMax候选，普通Text Observable在batch变a→c触发布局失效，再snapshot。

**期望：** 候选Failed(InvalidCandidate)，旧ThemeInfo及session/节点保持；对照无export的相同失效组合已实际Failed。

**实际：** 最终probe为result=Applied，随后minimum sum overflow，info=Candidate，active=false/ref=false。

preview只从session.measuredLayout取canvasNatural/Constrained；普通Content/Layout失效将其清空后，又回退到被export改写的Canvas.measured。原三组固定回归未覆盖export之后再失效。 保留适用于候选验证的稳定测量依据及正确代际/布局来源，不能把可复用cache失效等同于丢掉最后有效事实；无可靠依据时也不可错误发布，且不得在preview调用measure/getter/build/draw。

### T105-M01 · Minor · viewport getter初值在onMount只读快照中尚未同步

位置：`src/runtime_node.cj:39`, `src/runtime_session.cj:955`, `src/runtime_session.cj:966`。合同：B.1 挂载后无布局的快照为全0与当前axes；只读生命周期查询允许。

Canvas.viewport({=>Both}).onMount读取viewportSnapshot().axes；startHeadless后再读一次。

**期望：** onMount与start返回后均为Both，几何均可保持0。

**实际：** onMount判断Both=false（初始Off），start返回后Both=true。

RuntimeNode构造时getter尚未求值；syncViewportAxes在onMount effects之后，暴露错误的prelayout axes。 在允许的只读生命周期观察点前同步已求值axes，不新增测量或重复effect。

## 根因边界与证据

I01是子节点宽度分配/测量失配；I06是公开Canvas非滚动轴约束缺失，虽同在constrain路径，属于不同义务，不能只修Row文本即可关闭二者。I02是第二pass屏障基准丢失，独立于I01。I04是App提交viewport/offset被导出污染；I07是theme预检的稳定测量随cache失效丢失，二者都涉及export但状态与失败路径不同。I03、I05、M01分别是内部resize触发、当前轮范围验证、prelayout轴初始化。

全部发现均有同一固定252c普通SDK1.2公共消费者的实际输出，最终build/direct exit均0。该exit表示探针完成，不是产品断言通过；结果差异保存在raw/final-run.stdout。探针没有私有产品hook、第二renderer或手写decoder。第一组5个具体疑问运行后，按同批剩余明确源码问题增量加入非滚动轴/T008/初始getter轴，未冷重跑B套件。156个工作用导出源文件逐Git比对0差异；源哈希捕获的真实时间保留，不补造pre-run记录。初次shell启动有一处本地brace空格语法错误，未进入构建；修正命令后真实执行结果分三组保存。T008中的30ms等待只给异步准备机会，结论依据真实Applied终态、布局异常和会话关闭，而非等待本身；无export失效对照Failed也保留于extended-run.stdout。

既有纯raw：headless7、theme-canvas-fix1、bundle2实际exit均0。各inputs.sha256与252c对应Git文件分别匹配190/190/178项，0差异；其余非Git条目是原件记录，不冒称源码。原固定T008 finite/control/subtree三组均GREEN，不能覆盖export后再有普通布局失效的I07。原件UTC和完整摘要哈希在reviewed-hashes.json，本报告未补造历史命令或额外运行前身份。

固定B原树5fa与252c相同；T008六文件树与f57相同。后续测试维护69232b9仅调整真实PTY readiness、GNU Time路径、旧A非viewport fixture显式Off并新增bare Canvas默认根正控；已读其test-only delta，原31项和manual goldens字节保持。未把父代理报告的9ea旧执行冒充本review独核的252c最终fresh运行，也未因此重启审查/重跑套件。

TASK106最终独立执行/正常制品消费和TASK107验收仍开放。本轮拒绝依据以上可达代码反例，不依据包/执行尚未完成。B/C后续边界、完整Keyboard/Page设备解码、widgets/editing/M2均未扩入范围。

## 最小交付

findings.json为同一修复批次；reviewed-hashes.json固定源码、合同、测试与外部pure raw；raw/manifest.json和artifacts.sha256固定最小探针原件。仅归档清单内文件；不包含工作source导出、SDK/cache/ELF/object、完整合同或Markdown树。
