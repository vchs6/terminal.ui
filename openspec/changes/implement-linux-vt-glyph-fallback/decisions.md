# Decision record — candidate for main-agent freeze

状态：主代理已选择下述方向；正式OpenSpec合同仍待独立preflight，不是产品已实现。

| 决策 | 采用 | 排除/原因 |
|---|---|---|
| 缺字处理 | A整簇等原width ASCII；单mapped BMP单列可原样 | B删缺失mark改变重音语义且增加判断；NFC缺API且实测错误，禁止手写 |
| 未知PTY | 保持Unicode输出、coverage unknown | TERM/terminfo推断字体不成立；未知默认毁损文本缺证据 |
| 原生读取 | 实际stdout具体文本VT+有界一次GIO_UNIMAP | 读stdin/打开别的tty/字体扫描不代表输出设备；无fontload/GUI |
| 公共入口 | GlyphMode三个值、现两个init追加一个参数、同名setter/getter和独立只读cap | 不新增构造家族、bitmap公共API或新公共policy层；颜色cap语义不混用 |
| 离线 | snapshot/render显式mode默认Unicode、Auto也按Unicode | 不暗读上次run能力，app设备Ascii不影响默认文件生成标记；原文始终logical |
| 生成…与原文… | 生成标记以实际ambiguousWide选单列…或...，Theme013先预留再取前缀；字面…编码只等宽? | encoder里1列…扩为3列...破坏网格；为headless新建布局核不可接受 |
| 接口分段 | 093–097交policy/marker/context、device投影；013/085追加/088交完整ellipsis | 当前无TextOverflow产品，不能抢先改085冻结API或假称helper代表排版完成 |
| 缓存/diff | 单Runtime缓存加policy键，旧/新各profile比较同投影row | raw字素/续格直接changed误报；新造device Frame重复权威 |
| 时序/验收 | 080+084之后，theme产品之前；041最终AC继续待全场景 | 不让有限glyph调查或截图代替输入/尺寸/故障恢复/全组件/最终制品验收 |

初始源码/依赖事实见根draft.md与raw。公共签名shape-only验证正常SDK1.2.0编译，不与产品验收混淆。skills使用：已调用brainstorming/writing-plans（云skill），并读取用户固定CangjieSkills；本任务明确只输出供主代理冻结的文档，不创建产品，不派下级。原调查及api-probe是授权隔离探针，不加入产品依赖。

主代理明确接受离线参数分工与ellipsis接口分段；本记录不自行改变Theme085 frozen API。generatedEllipsis包内签名显式接收`ambiguousWide!:Bool=false`，调用者传现会话实际值；这不改Theme085公共API。094产品角色固定Terra/high。具体本地文档哈希见根freeze-candidate.sha256；后续preflight输入应固定该hash，修改后重新提供受影响内容哈希，不沿用旧审查结论。
