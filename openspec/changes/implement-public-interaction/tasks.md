# Public interaction implementation plan

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development；按用户已指定独立角色推进。当前作者只准备合同，不启动执行或派代理。

**Goal:** 交付用户与内置组件同权的公共绘制/焦点、统一视口与owner覆盖层。
**Architecture:** 单Component/RuntimeNode/LayoutNode/Frame/样式resolver；两类绘制依赖、统一UI边界、普通子序列与层所有权关系区分。
**Tech Stack:** 仓颉SDK1.2.0、既有Unicode/Unicodewidth/ansies与主题088冻结依赖；无新运行时。
**Spec:** design.md（I001–I015优先）及specs/ui-runtime、ui-construction、terminal-output；源需求REQ001/003/009。

## Global constraints

- 正式父项为A→TASK-017、B→TASK-037、C→TASK-018；稳定编号不改。028编辑、019菜单状态条、029基础widgets、020退出恢复、030可选会话仍保留完整责任。
- 支持任务098–112的状态权威仅本tasks.md；主代理集成后docs/tasks.md只加编号/依赖映射，不复制另一套勾选。当前全部planned，AC pending，不能把文件存在当ready。
- 角色独立上下文/目录或worktree；测试、产品、审查、执行、验收分别交付。只交需求、冻结源码/测试、可复现命令及raw/hash，不交产品作者推理、自评或预设通过结论。
- 一类型一小写下划线文件，成员归实体文件；根包持有Runtime/NodeRef/PaintContext，纯style/theme不能反向依赖根包。禁止第二树/renderer/Unicode/主题resolver、Button/Input私有kind。
- 全部新增签名尚未编译验证。原StyleRule候选with退役为当前T016 withValue；KeyEvent仍只有code/text。普通getter可只读查询，不能写节点或跨session mutation。
- A仅最小HT/tab、CSI Z/backtab设备增量；完整键盘/编辑/paste/clipboard另阶段。B默认ScrollView Vertical，指南主体默认滚动、固定菜单状态条不滚，普通非root Column不隐式滚；Application根默认Vertical兜底、显式Off关闭，I009最多两pass保短内容分配。
- M1全局render完整参考保留：detached不隐建root viewport，mounted消费session已提交viewport/offset/层栈，不访问M2缓存。paint-only失效不等同已实现M2；min不凌驾实际viewport；不自动改业务排序/显隐。无鼠标、拖动、发布。

## Admission and handoff

实际SDK签名微编译先于独立preflight：由主代理在独立临时包安排声明-only探针，覆盖Canvas闭包、全部重载/命名默认参数、Option/enum/struct只读成员、根重导出及Color/Style/TextStylePatch/RichText/Rect互用。保存源码、SDK/cjpm版本、命令、stdout/stderr、exit和hash到`docs/reviews/interaction/admission/api-probe/`；声明stub只能证明语言形式，不能证明产品实现。禁止用产品伪实现通过探针；产品正常公开CJPM消费者证据仍由098/099/101承担。

微编译后由独立Astra/high做preflight，逐DQ01–14检查当前合同/任务/三spec与接口probe；记录`docs/reviews/interaction/admission/preflight.md`，有Critical/Important先由主代理处理后冻结版本，不派产品。A的可执行准入还需080(runtime C)、084(RichText)、088(基础Theme)验收已接受的固定源与hash；不要求092异步加载。本稿不宣称前置完成，不建立短期假Theme/动态树兼容分支。

`docs/reviews/interaction/admission/interface-map.json`由主代理在上述固定输入到位时记录：source SHA、公开签名引用、主题唯一resolver实际路径、现设备caret/恢复桥接路径、受影响现回归命令；它是定位清单而非另一套规范。下文确切新增路径不变；上游尚未交付的resolver文件名只沿088真实清单定位，不能先创建同名平行实现。该映射缺失时DQ03/06/10/13不能ready。

每单位依次测试→产品→审查→执行→验收；B等102固定接受源，C等107固定接受源。审查发现回主代理，由原测试角色补必要反例、产品角色定点修复、审核角色复核，再执行受影响检查；不得产品作者改预期让实现通过。未改内容的有效执行证据按hash复用，不因为角色交接机械全量重跑。

## Shared L3 card fields

本节与每张任务卡合并才构成完整L3定义，适用于098–112，无省略字段：

- `level=L3; goal=G-001; classification=execution`：用户目标已定、I001–I015收敛工程选择；若签名实证迫使外部行为变化，先修合同/preflight，不由实现者自由补约。
- `openspec_change_ref=implement-public-interaction; workflow_ref=本tasks.md; decision_refs=design I001–I015`。具体`parent/parent_task/requirement_refs/type/inputs/depends_on/deliverables/acceptance/steps`见各卡。
- `preconditions`：通用admission、该卡全部依赖、固定hash和角色隔离成立。`status=planned; evidence_refs=[]; blockers=admission及该卡依赖尚未由本角色核验完成`。不是实施授权缺失，不重复索要用户许可。
- `required_skills`：测试=TDD/verification；产品=TDD/SDD/verification，遇故障再systematic-debugging；审查=requesting-code-review及verification（反馈修复用receiving-code-review）；执行/验收=verification，失败按需systematic-debugging。所有角色按实际工作使用已读AGENTS的仓颉参考及OpenSpec apply工作流。已具备的技能来源复用仓库固定记录；`skill_evidence_refs`进入ready时记录实际发现/读取/适用版本到`docs/reviews/interaction/<A|B|C>/<task-id>/skills.json`，不能将安装当实际使用。
- `compatibility`：现Text/Row/Column/Frame/Style/KeyEvent/UIKeyEvent入口、事件过期、跨session、native恢复保留；本变更可观察新增/退役仅design列出的设备目标、统一默认、viewport/layer桥接。无发布ABI或旧widgets入口兼容承诺，兼容例外为空。
- `quality_governance.necessity`：现公共构造缺本单元必要能力；`canonical_owner`=Component声明、Runtime节点/命令/焦点/层记录、唯一布局/resolver/Frame；`complexity_delta`=仅本单元所需依赖/offset/owner状态，禁止并行权威；具体`old_path_disposition`见文件表/各产品卡。非产品角色只交证据，不改运行路径。
- `risks`：共享文件竞写、回调失败遗漏清理、主题状态误当业务状态、坐标/宽簇clip错误、假性能/假设备证据；本单位AC与Review focus给可观察界线。`impact`见单位文件表。无部署/发布，回滚仅由主代理在未接受产品变更内处理。
- 模型是派单请求配置，非serving证明：测试Sol/high、产品Terra/high、审查和验收Astra/high、确定命令执行Sol/medium。无法独立核验实际serving时明示不认证，不按价格或延迟猜测。

## File responsibility

| 单元 | 新增实体/函数文件 | 修改/沿用唯一权威 | 测试、公开消费者和文档 |
|---|---|---|---|
| A | `src/size.cj`, `constraints.cj`, `paint_context.cj`, `caret_snapshot.cj`, `default_action_phase.cj`, `focus_manager.cj`, `paint_scope.cj`, `caret_request.cj`；工厂纯函数`canvas.cj`、路由函数`focus_routing.cj` | `component.cj`, `node_ref.cj`, `runtime_session.cj`, `runtime_node.cj`, `binding.cj`, `binding_dependency.cj`, `application.cj`, `layout_node.cj`, `layout.cj`, `frame.cj`, `input_decoder.cj`, `exports.cj`；theme088既有resolver按admission清单扩selected投影；既有设备输出/恢复桥按同清单接caret，不能另开stdout | `tests/interaction_a/{cjpm.toml,src/main.cj,run.sh,README.md}`、分实体helper/pty脚本；`examples/interaction_primitives/{cjpm.toml,src/main.cj}`及按实体示例；`docs/product/interaction.md` |
| B | `src/scroll_axes.cj`, `scroll_align.cj`, `viewport_snapshot.cj`, `viewport_state.cj`, `scroll_command.cj`, `vertical_overflow_summary.cj`；公共组合函数`scroll_view.cj` | A的`component.cj,node_ref.cj,runtime_session.cj,runtime_node.cj,layout_node.cj,layout.cj,paint_context.cj,focus_manager.cj,exports.cj`；Frame/文本规则不另建 | `tests/interaction_b/{cjpm.toml,src/main.cj,run.sh,README.md}`及分实体helper；`examples/scrolling/{cjpm.toml,src/main.cj}`；`docs/product/interaction.md`的主体/固定栏指南 |
| C | `src/overlay_mode.cj`, `overlay_placement.cj`, `overlay_close_reason.cj`, `surface_mode.cj`, `overlay_options.cj`, `overlay_handle.cj`, `overlay_record.cj`, `overlay_manager.cj`；几何纯函数`overlay_placement_layout.cj` | `component.cj,node_ref.cj,runtime_session.cj,runtime_node.cj,application.cj,focus_manager.cj,layout_node.cj,layout.cj,frame.cj,exports.cj`；主题唯一resolver/fill与A caret合成桥，不复制渲染器；普通ChildSequence语义不变 | `tests/interaction_c/{cjpm.toml,src/main.cj,run.sh,README.md}`及分实体helper；`examples/overlay_composition/{cjpm.toml,src/main.cj}`；`docs/product/interaction.md`的owner/host与复用指南 |

上表所有短文件名均相对src/。每个列名只表示一个实体或一组内聚纯函数，不能将多个类型塞一个文件。新增内部类型确有必要时先在实际文件清单登记职责，不要求为每个概念造空类。测试入口只由测试作者创建，产品例子只由产品作者创建；`tests/run-slice.sh`与tests说明按A/B/C顺序接线，不并行编辑。`docs/product/README.md`增加文档链接；cjpm include现有/examples及/docs/product路径足够时不无故改清单。

退役安排：A退役Application设备固定root选择与独立interrupt默认分支，复用唯一InputDecoder加tab/backtab、保留原unknown/control隔离；B将相关布局偏移/clip交同viewport变换，不保ScrollView内部第二offset；C保留Frame合成与普通children，增加同node的overlay关系，禁止旧截图恢复或另建layer组件生命周期。当前无已实现私有widgets可删，不制造伪兼容层。

## Review focus

1. 只读getter误入requireContext写guard或借只读进入异session → A-04及098.S2，读合法/写拒绝、错误优先级可见。
2. 图像不变但caret改变/透明或opaque遮挡 → A-03/A-05与C-03，101真实PTY、111层合成证据，非像素差分推断caret归属。
3. viewport零维/内容缩短/新caret与旧帧resize竞争 → B-02/B-03与103.S2，终端真实边界和最后显式意图不被旧帧覆盖。
4. modal owner按钮disabled、owner隐藏/卸载、非顶层关闭 → C-01/C-02与108.S2，行为继承不跨overlay、依赖关闭不误关兄弟。
5. cleanup或用户draw异常穿越native恢复、旧handle/ctx复活 → A-06/C-04与098/108.S2，101/111原始恢复/错误聚合；020完整会话AC另保留。

## Acceptance catalog

这些是可独立断言的合同观察点，不是本作者编写的正式测试；独立测试作者须自行构造固定期望并记录RED。

| ID | 条件/动作 → 可观察结果 | 验证方式与所属单元 |
|---|---|---|
| A-01 | 普通公开消费者构造Text-button/Canvas-progress/Canvas-caret → 无私有kind/Frame/ANSI，所有新增API及跨包类型正常编译；Canvas非法属性诊断 | 098公开CJPM消费者、099实现、101干净bundle路径 |
| A-02 | user capture/bubble/app/legacy、Target、framework、Ancestor → 固定trace；stop继续默认、prevent跳过、事件过期拒绝；真实HT/CSI Z按tab/backtab选目标 | 098独立trace/分块解码fixture；101真实PTY |
| A-03 | paint独有状态改变 → paint依赖失效而不扩measure集合；所有绘制均祖先clip内，宽簇完整、selected逐字段优先 | 098手工网格/依赖观察、101运行；M1不要求measure计数不增 |
| A-04 | key重排、manual穿插、disabled/hidden/unmount → 按真实序列/代际保留或回退；getter读ref/focus合法且跨session/变更拒绝 | 098动态080组合消费者；101执行 |
| A-05 | caret-only移位、clip外/零维/continuation → 正确显示或隐藏，frame网格相同仍有caret输出 | 098 headless与PTY fixture、101终端输出raw/恢复 |
| A-06 | 保存ctx、wrong thread/session、draw/cleanup异常、限制超出 → 固定错误、清理一次、旧ref不复活、native恢复 | 098边界fixture、100审查、101执行 |
| B-01 | 裸App根80×24的100行、主体ScrollView+固定栏、横向宽表 → 所有内容可访问而固定栏不滚、Frame仍80×24，不更改业务visible | 103手工坐标/网格、104公开指南例子、106PTY与消费者 |
| B-02 | 隐式根自然高1/3权重保持5/5、8/1溢出第二pass为9/1、wrap后overflow、fixed-height屏障、root Off、resize/缩短/axes/0尺寸及极值 → offset按最新extent安全钳制、key身份保留，不分配巨大Frame | 103状态/资源边界、106执行 |
| B-03 | 嵌套ensureVisible及行末1×1caret、新显式caret与旧帧resize同turn → 内到外最小滚动、显式新意图优先、paint无命令循环 | 103公共序列fixture、105审查、106执行 |
| B-04 | 用户Ancestor先于同节点viewport标准滚；Target或Ancestor prevent则不滚，stop仍默认；最近viewport能移动即prevent后续，边界才外移；Bool只表示接受变化 | 103trace/offset fixture、106执行 |
| C-01 | modal→popup→确认层及域外dispatch → 当前域隔离，base app/legacy为0次，域外FocusOutsideDomain，未prevent interrupt退出全app | 108 trace fixture、111PTY/运行 |
| C-02 | owner隐藏/卸载、非顶层关闭、保存焦点失效 → 闭包关闭、兄弟保留、一次确定恢复；owner仅disabled不禁用层 | 108生命周期/焦点fixture、111执行 |
| C-03 | 无本地background modal、透明hole/opaque空格/阴影遮caret、host边界和滚动anchor → 同resolver/Frame结果与正确clip，AnchorGone，不恢复旧底层帧 | 108手工网格/主题088组合、111执行 |
| C-04 | pending close、双挂载、stale handle、非法host/anchor、cleanup异常 → 固定错误与资源释放、正常退出恢复 | 108失败fixture、110审核、111执行 |
| C-05 | 同SettingsPanel类型普通/层两实例共享业务model → 同公共参数/绑定正确更新，普通children不含layer根、节点/主题/滚动状态按设计保留 | 108消费者、109例子、111干净bundle、112综合验收 |

## 1. Unit A

- [x] 1.1 TASK-098：冻结独立公共测试与RED；以本卡输入hash、A-01–A-06对应原始证据与明确结论验收。
- [ ] 1.2 TASK-099：实现有限公共单元并自验；以本卡输入hash、A-01–A-06对应原始证据与明确结论验收。
- [ ] 1.3 TASK-100：固定源码独立规格与质量审查；以本卡输入hash、A-01–A-06对应原始证据与明确结论验收。
- [ ] 1.4 TASK-101：独立执行与正常制品消费；以本卡输入hash、A-01–A-06对应原始证据与明确结论验收。
- [ ] 1.5 TASK-102：有限合同与父AC映射独立验收；以本卡输入hash、A-01–A-06对应原始证据与明确结论验收。

### TASK-098: 冻结独立公共测试与RED

`parent=WP-005; parent_task=TASK-017; type=testing; requirement_refs=REQ-001.8、REQ-003.2/.7、REQ-009.1; model=Sol/high; depends_on=TASK-080、TASK-084、TASK-088及admission微编译/preflight`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 形成可由另一实现者复现的公开行为预期、负例和旧产品缺口，不写产品代码。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-080、TASK-084、TASK-088及admission微编译/preflight；design本单位精确签名/错误、specs及Acceptance catalog；不读取产品作者自评。 产生design A全部公开签名；消费080的NodeRef/真实children/Observable/dispatch/生命周期，084的RichText/TextStylePatch，088的StyleRule.withValue/VisualStates/唯一resolver及fill来源。

**Deliverables/files:** 文件表tests/interaction_a正式消费者/必要fixture与test-only固定提交；docs/reviews/interaction/A/TASK-098/red/原始命令、stdout/stderr、exit、source/test/hash清单和用例→AC映射。

**Acceptance/verification:** 全部A-01–A-06至少有正常及相关边界/失败观察；基线正常编译后新公共API出现可复现RED；期望不由待测renderer/resolver生成；测试没有私有hook或产品修补。

**L4:**

- [x] 1.1.1 TASK-098.S1：按A-01建立只import正式包的三小消费者与全部新增签名检查，固定test-only版本；在固定080/084/088基线正常build后直接编译取缺API RED，不能用桩冒充产品。
- [x] 1.1.2 TASK-098.S2：依据A-02–A-06自行写手工trace/网格、动态key与manual顺序、readonly/跨session、ctx过期、selected/宽簇/零维、异常清理/限制fixture；解码覆盖HT、CSI Z分块和SS3 Z/带参Z拒绝。
- [x] 1.1.3 TASK-098.S3：建立真实PTY输入/目标可视标记/caret输出/退出恢复fixture；记录原始输入、输出、尺寸和termios，不能只用Application.dispatch或改TERM充当设备证明。
- [x] 1.1.4 TASK-098.S4：冻结测试及运行说明，入口为bash tests/interaction_a/run.sh；明确其内部正常cjpm build和直接binary执行命令及预期exit，记录docs/reviews/interaction/A/TASK-098/manifest.json后交主代理。

### TASK-099: 实现有限公共单元并自验

`parent=WP-004; parent_task=TASK-017; type=implementation; requirement_refs=REQ-001.8、REQ-003.2/.7、REQ-009.1; model=Terra/high; depends_on=TASK-098固定产物`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 交付Canvas/独立measure-draw/受控PaintContext/selected resolver、enabled/focus/readonly guard、默认动作、caret与最小Tab解码，独立满足A-01–A-06的公开行为。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-080、TASK-084、TASK-088及admission微编译/preflight、TASK-098固定测试与本design；读取正式入口/实际resolver映射，不依赖其他作者私有缓存或自评。 产生design A全部公开签名；消费080的NodeRef/真实children/Observable/dispatch/生命周期，084的RichText/TextStylePatch，088的StyleRule.withValue/VisualStates/唯一resolver及fill来源。

**Deliverables/files:** 文件表Unit A产品源/公共例子/文档及product-only提交；正常构建和必要自验raw/hash归docs/reviews/interaction/A/TASK-099/self-check/；更新API实际编译状态须有公开消费者证据。

**Acceptance/verification:** 冻结公开测试和受影响原回归通过，正常lint/build不skip；无A之外的控件/协议扩范围，不更改测试或规范迎合实现；退役规则：移除设备固定root和旧interrupt平行分支；InputDecoder只增HT与无参数CSI Z，未知CSI/SS3 Z及控制串原隔离不放宽。

**L4:**

- [ ] 1.2.1 TASK-099.S1：按文件表公开Canvas/Size/Constraints/PaintContext，复用绑定版本协议分别登记measure/draw依赖，所有控件共用一个primitive；实现ctx过期/clip/文本样式但不暴露Frame。
- [ ] 1.2.2 TASK-099.S2：将readonly guard用于reference与查询，现真实children焦点资格/回退接activeTarget；Target→framework→Ancestor取代旧默认，最小Tab输入走同decoder。
- [ ] 1.2.3 TASK-099.S3：接会话caret与设备成功基线/恢复，保存已完成帧局部rect供B复用；补公开三消费者与文档，产品正常编译/定点回归后固定product-only提交。
- [ ] 1.2.4 TASK-099.S4：运行bash tests/interaction_a/run.sh及admission清单列出的受影响既有检查，记录实际exit；检查技术diff/实体文件/旧路径退役，提交产品hash给主代理。作者自验不是独立验收。

### TASK-100: 固定源码独立规格与质量审查

`parent=WP-005; parent_task=TASK-017; type=verification; requirement_refs=REQ-001.8、REQ-003.2/.7、REQ-009.1; model=Astra/high; depends_on=TASK-099固定产物及TASK-098固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 独立判断固定产品是否符合冻结合同与质量治理，给具体反例及双verdict。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** 本单位base..TASK-099固定product技术diff、TASK-098测试、design/specs/源需求和admission清单；不读取作者说明中的自评结论。 产生design A全部公开签名；消费080的NodeRef/真实children/Observable/dispatch/生命周期，084的RichText/TextStylePatch，088的StyleRule.withValue/VisualStates/唯一resolver及fill来源。

**Deliverables/files:** docs/reviews/interaction/A/TASK-100/findings.json及review.md，逐项spec/quality verdict、source/test/contract hash、定位与可复现条件；不改产品或正式测试。

**Acceptance/verification:** A-01–A-06及Review focus有独立核对；所有Critical/Important修复或经主代理明确裁决后复核；不能只评价作者报告或测试数量。

**L4:**

- [ ] 1.3.1 TASK-100.S1：锁定base/product/test/contract hash，逐公开接口核对design本单位与A-01–A-06、上游交叉及错误优先级，交可达反例而非泛泛建议。
- [ ] 1.3.2 TASK-100.S2：检查文件职责/单Runtime/单resolver/Frame/宽簇、生命周期与资源上限；核对退役安排“移除设备固定root和旧interrupt平行分支；InputDecoder只增HT与无参数CSI Z，未知CSI/SS3 Z及控制串原隔离不放宽。”。
- [ ] 1.3.3 TASK-100.S3：输出spec/quality双verdict与发现严重度；发现回主代理，不私改代码/断言。收到新固定修复后仅复核受影响diff和相关失败证据，保留前次记录。

### TASK-101: 独立执行与正常制品消费

`parent=WP-005; parent_task=TASK-017; type=testing; requirement_refs=REQ-001.8、REQ-003.2/.7、REQ-009.1; model=Sol/medium; depends_on=TASK-100固定产物及TASK-098固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 在独立环境执行冻结产品和测试，证明真实公开消费/设备行为，记录实际命令与exit。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-100审核接受的product/test/contract hash、测试run入口、admission必要回归清单；不复用作者target作为制品。 产生design A全部公开签名；消费080的NodeRef/真实children/Observable/dispatch/生命周期，084的RichText/TextStylePatch，088的StyleRule.withValue/VisualStates/唯一resolver及fill来源。

**Deliverables/files:** docs/reviews/interaction/A/TASK-101/run/与bundle/原始stdout/stderr/exit、SDK/依赖/尺寸/PTY恢复/输入输出、source/artifact/hash；成功/失败逐AC清单。

**Acceptance/verification:** A-01–A-06适用项执行有原始证据，正常CJPM build/bundle不skip、干净解包消费者只改manifest path仍通过；设备声明有真实PTY，不能仅headless注入。缺环境明确insufficient_evidence。

**L4:**

- [ ] 1.4.1 TASK-101.S1：在自己的SDK/registry/cache配置下核hash，执行bash tests/interaction_a/run.sh并保存真实exit；随后仅执行admission清单相关既有回归，复用未变内容的有效证据。
- [ ] 1.4.2 TASK-101.S2：正常cjpm bundle（不skip）后干净解包，正式公共消费者与例子仅改manifest路径构建运行；SDK/stdx前置按088交付记录，不借作者私有cjo。
- [ ] 1.4.3 TASK-101.S3：执行真实PTY HT/CSI Z焦点/caret-only输出/异常退出恢复；记录输入字节和termios。
- [ ] 1.4.4 TASK-101.S4：保存逐命令raw、source/test/bundle/consumer SHA256与AC结果，发现失败回主代理而非直接修产品/测试；不以同PTY换TERM冒充多个真实宿主。

### TASK-102: 有限合同与父AC映射独立验收

`parent=WP-005; parent_task=TASK-017; type=verification; requirement_refs=REQ-001.8、REQ-003.2/.7、REQ-009.1; model=Astra/high; depends_on=TASK-101固定产物及TASK-098固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 依据原始证据给单元A有限验收，决定可否交给下一单元，不把基础API当全部控件完成。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-100独立审核、TASK-101原始执行、固定测试/产品/合同/制品及TASK-017原AC全文；不依赖作者自评。 产生design A全部公开签名；消费080的NodeRef/真实children/Observable/dispatch/生命周期，084的RichText/TextStylePatch，088的StyleRule.withValue/VisualStates/唯一resolver及fill来源。

**Deliverables/files:** docs/reviews/interaction/A/TASK-102/acceptance.md、evidence-index.json及hash核对；逐A-01–A-06pass/fail/insufficient_evidence与父项残余映射，主代理据此集成。

**Acceptance/verification:** 所有A-01–A-06必需证据可追溯且无未决严重缺陷；版本/命令/制品/环境和实际结果一致；不得因支持任务完成提前关闭019/028/029/020/030/M2/Linux。

**L4:**

- [ ] 1.5.1 TASK-102.S1：从原件核对A-01–A-06到测试、执行raw与技术diff的映射及hash，确认公开消费者和真实设备声明各有相应证据，不重复已有效suite。
- [ ] 1.5.2 TASK-102.S2：核对父TASK-017完整AC与本单位边界：017焦点部分可按实际全范围证据判定，028编辑/029标准组件/018多层仍未由A交付。
- [ ] 1.5.3 TASK-102.S3：给有限结论与缺口列表，失败保持verifying/blocked并注明恢复条件；通过由主代理投影长期AC/任务并交下一单元，不凭任务勾选归档全部Linux。

## 2. Unit B

- [ ] 2.1 TASK-103：冻结独立公共测试与RED；以本卡输入hash、B-01–B-04对应原始证据与明确结论验收。
- [ ] 2.2 TASK-104：实现有限公共单元并自验；以本卡输入hash、B-01–B-04对应原始证据与明确结论验收。
- [ ] 2.3 TASK-105：固定源码独立规格与质量审查；以本卡输入hash、B-01–B-04对应原始证据与明确结论验收。
- [ ] 2.4 TASK-106：独立执行与正常制品消费；以本卡输入hash、B-01–B-04对应原始证据与明确结论验收。
- [ ] 2.5 TASK-107：有限合同与父AC映射独立验收；以本卡输入hash、B-01–B-04对应原始证据与明确结论验收。

### TASK-103: 冻结独立公共测试与RED

`parent=WP-005; parent_task=TASK-037; type=testing; requirement_refs=REQ-003.10/.11、REQ-009.1; model=Sol/high; depends_on=TASK-102已接受A固定源及本单位签名/前置复核`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 形成可由另一实现者复现的公开行为预期、负例和旧产品缺口，不写产品代码。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-102已接受A固定源及本单位签名/前置复核；design本单位精确签名/错误、specs及Acceptance catalog；不读取产品作者自评。 产生design B全部公开签名；消费A Canvas测量/clip、默认动作阶段、focus/caret已完成帧记录和原NodeRef代际。

**Deliverables/files:** 文件表tests/interaction_b正式消费者/必要fixture与test-only固定提交；docs/reviews/interaction/B/TASK-103/red/原始命令、stdout/stderr、exit、source/test/hash清单和用例→AC映射。

**Acceptance/verification:** 全部B-01–B-04至少有正常及相关边界/失败观察；基线正常编译后新公共API出现可复现RED；期望不由待测renderer/resolver生成；测试没有私有hook或产品修补。

**L4:**

- [ ] 2.1.1 TASK-103.S1：固定B-01的100行/固定栏/宽表及同Canvas水平输入消费者，手工产生屏幕与offset期望；在102固定源取真实缺viewport API RED。
- [ ] 2.1.2 TASK-103.S2：按B-02/B-03覆盖缩短/axes/零维/Int64极端、weighted自然基准与I009全部root例表/overflow屏障/最多两pass、detached与mounted render差异、嵌套ensure、末尾caret占位、旧帧resize与新显式caret同turn；验证无paint→scroll反馈。
- [ ] 2.1.3 TASK-103.S3：按B-04设计Target消费/用户Ancestor-before-viewport/stop与prevent/裸root与ScrollView同通道不重复注册/祖先边界回落/接受Bool的trace；已有方向键真实PTY访问100行，PageUp等尚未设备解码的规范code只作headless默认行为验证并记录限制。
- [ ] 2.1.4 TASK-103.S4：冻结测试及运行说明，入口为bash tests/interaction_b/run.sh；明确其内部正常cjpm build和直接binary执行命令及预期exit，记录docs/reviews/interaction/B/TASK-103/manifest.json后交主代理。

### TASK-104: 实现有限公共单元并自验

`parent=WP-003; parent_task=TASK-037; type=implementation; requirement_refs=REQ-003.10/.11、REQ-009.1; model=Terra/high; depends_on=TASK-103固定产物`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 交付通用viewport/ScrollView/受控滚动与ensureVisible及主体默认纵滚指南，独立满足B-01–B-04的公开行为。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-102已接受A固定源及本单位签名/前置复核、TASK-103固定测试与本design；读取正式入口/实际resolver映射，不依赖其他作者私有缓存或自评。 产生design B全部公开签名；消费A Canvas测量/clip、默认动作阶段、focus/caret已完成帧记录和原NodeRef代际。

**Deliverables/files:** 文件表Unit B产品源/公共例子/文档及product-only提交；正常构建和必要自验raw/hash归docs/reviews/interaction/B/TASK-104/self-check/；更新API实际编译状态须有公开消费者证据。

**Acceptance/verification:** 冻结公开测试和受影响原回归通过，正常lint/build不skip；无B之外的控件/协议扩范围，不更改测试或规范迎合实现；退役规则：viewport offset/坐标/clip保持节点唯一权威，不给ScrollView另保存副本；普通非root Column/显式Off保原flex；隐式root先旧布局、有未承接overflow才B2第二pass，最多两pass。

**L4:**

- [ ] 2.2.1 TASK-104.S1：将viewport能力加到通用节点、布局约束与有限extent中；显式轴直接B2，隐式App根保存viewport声明presence，旧有限布局产未承接overflow摘要后最多一次B2重协商，严格按I009例表保短内容5/5与固定栏边界；实现唯一offset/snapshot及pending命令，不分配全文Frame。
- [ ] 2.2.2 TASK-104.S2：在同安全边界布局/钳制后处理ensure；用最后已完成caret rect做一次resize确保，新显式意图优先；Scalar坐标复用统一变换与整簇clip。
- [ ] 2.2.3 TASK-104.S3：让每节点用户Ancestor先、未prevent再执行同viewport标准键滚；用公开Column+viewport+focusable组合ScrollView，删除重复滚动回调，写主体默认Vertical/固定栏/宽表例子与文档；按固定测试验证后提交product-only。
- [ ] 2.2.4 TASK-104.S4：运行bash tests/interaction_b/run.sh及admission清单列出的受影响既有检查，记录实际exit；检查技术diff/实体文件/旧路径退役，提交产品hash给主代理。作者自验不是独立验收。

### TASK-105: 固定源码独立规格与质量审查

`parent=WP-005; parent_task=TASK-037; type=verification; requirement_refs=REQ-003.10/.11、REQ-009.1; model=Astra/high; depends_on=TASK-104固定产物及TASK-103固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 独立判断固定产品是否符合冻结合同与质量治理，给具体反例及双verdict。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** 本单位base..TASK-104固定product技术diff、TASK-103测试、design/specs/源需求和admission清单；不读取作者说明中的自评结论。 产生design B全部公开签名；消费A Canvas测量/clip、默认动作阶段、focus/caret已完成帧记录和原NodeRef代际。

**Deliverables/files:** docs/reviews/interaction/B/TASK-105/findings.json及review.md，逐项spec/quality verdict、source/test/contract hash、定位与可复现条件；不改产品或正式测试。

**Acceptance/verification:** B-01–B-04及Review focus有独立核对；所有Critical/Important修复或经主代理明确裁决后复核；不能只评价作者报告或测试数量。

**L4:**

- [ ] 2.3.1 TASK-105.S1：锁定base/product/test/contract hash，逐公开接口核对design本单位与B-01–B-04、上游交叉及错误优先级，交可达反例而非泛泛建议。
- [ ] 2.3.2 TASK-105.S2：检查文件职责/单Runtime/单resolver/Frame/宽簇、生命周期与资源上限；核对退役安排“viewport offset/坐标/clip保持节点唯一权威，不给ScrollView另保存副本；普通非root Column/显式Off保原flex；隐式root先旧布局、有未承接overflow才B2第二pass，最多两pass。”。
- [ ] 2.3.3 TASK-105.S3：输出spec/quality双verdict与发现严重度；发现回主代理，不私改代码/断言。收到新固定修复后仅复核受影响diff和相关失败证据，保留前次记录。

### TASK-106: 独立执行与正常制品消费

`parent=WP-005; parent_task=TASK-037; type=testing; requirement_refs=REQ-003.10/.11、REQ-009.1; model=Sol/medium; depends_on=TASK-105固定产物及TASK-103固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 在独立环境执行冻结产品和测试，证明真实公开消费/设备行为，记录实际命令与exit。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-105审核接受的product/test/contract hash、测试run入口、admission必要回归清单；不复用作者target作为制品。 产生design B全部公开签名；消费A Canvas测量/clip、默认动作阶段、focus/caret已完成帧记录和原NodeRef代际。

**Deliverables/files:** docs/reviews/interaction/B/TASK-106/run/与bundle/原始stdout/stderr/exit、SDK/依赖/尺寸/PTY恢复/输入输出、source/artifact/hash；成功/失败逐AC清单。

**Acceptance/verification:** B-01–B-04适用项执行有原始证据，正常CJPM build/bundle不skip、干净解包消费者只改manifest path仍通过；设备声明有真实PTY，不能仅headless注入。缺环境明确insufficient_evidence。

**L4:**

- [ ] 2.4.1 TASK-106.S1：在自己的SDK/registry/cache配置下核hash，执行bash tests/interaction_b/run.sh并保存真实exit；随后仅执行admission清单相关既有回归，复用未变内容的有效证据。
- [ ] 2.4.2 TASK-106.S2：正常cjpm bundle（不skip）后干净解包，正式公共消费者与例子仅改manifest路径构建运行；SDK/stdx前置按088交付记录，不借作者私有cjo。
- [ ] 2.4.3 TASK-106.S3：执行真实PTY方向滚动/resize及恢复；未解码PageUp等仅报告headless默认动作覆盖，不扩协议支持声明。
- [ ] 2.4.4 TASK-106.S4：保存逐命令raw、source/test/bundle/consumer SHA256与AC结果，发现失败回主代理而非直接修产品/测试；不以同PTY换TERM冒充多个真实宿主。

### TASK-107: 有限合同与父AC映射独立验收

`parent=WP-005; parent_task=TASK-037; type=verification; requirement_refs=REQ-003.10/.11、REQ-009.1; model=Astra/high; depends_on=TASK-106固定产物及TASK-103固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 依据原始证据给单元B有限验收，决定可否交给下一单元，不把基础API当全部控件完成。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-105独立审核、TASK-106原始执行、固定测试/产品/合同/制品及TASK-037原AC全文；不依赖作者自评。 产生design B全部公开签名；消费A Canvas测量/clip、默认动作阶段、focus/caret已完成帧记录和原NodeRef代际。

**Deliverables/files:** docs/reviews/interaction/B/TASK-107/acceptance.md、evidence-index.json及hash核对；逐B-01–B-04pass/fail/insufficient_evidence与父项残余映射，主代理据此集成。

**Acceptance/verification:** 所有B-01–B-04必需证据可追溯且无未决严重缺陷；版本/命令/制品/环境和实际结果一致；不得因支持任务完成提前关闭019/028/029/020/030/M2/Linux。

**L4:**

- [ ] 2.5.1 TASK-107.S1：从原件核对B-01–B-04到测试、执行raw与技术diff的映射及hash，确认公开消费者和真实设备声明各有相应证据，不重复已有效suite。
- [ ] 2.5.2 TASK-107.S2：核对父TASK-037完整AC与本单位边界：037纵/横视口与resize可按实际全范围证据判定，028完整单多行编辑仍未交付。
- [ ] 2.5.3 TASK-107.S3：给有限结论与缺口列表，失败保持verifying/blocked并注明恢复条件；通过由主代理投影长期AC/任务并交下一单元，不凭任务勾选归档全部Linux。

## 3. Unit C

- [ ] 3.1 TASK-108：冻结独立公共测试与RED；以本卡输入hash、C-01–C-05对应原始证据与明确结论验收。
- [ ] 3.2 TASK-109：实现有限公共单元并自验；以本卡输入hash、C-01–C-05对应原始证据与明确结论验收。
- [ ] 3.3 TASK-110：固定源码独立规格与质量审查；以本卡输入hash、C-01–C-05对应原始证据与明确结论验收。
- [ ] 3.4 TASK-111：独立执行与正常制品消费；以本卡输入hash、C-01–C-05对应原始证据与明确结论验收。
- [ ] 3.5 TASK-112：有限合同与父AC映射独立验收；以本卡输入hash、C-01–C-05对应原始证据与明确结论验收。

### TASK-108: 冻结独立公共测试与RED

`parent=WP-005; parent_task=TASK-018; type=testing; requirement_refs=REQ-003.4/.5/.7/.8、REQ-009.1、REQ-001.5; model=Sol/high; depends_on=TASK-107已接受B及A固定源、overlay/surface声明微编译与本单位前置复核`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 形成可由另一实现者复现的公开行为预期、负例和旧产品缺口，不写产品代码。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-107已接受B及A固定源、overlay/surface声明微编译与本单位前置复核；design本单位精确签名/错误、specs及Acceptance catalog；不读取产品作者自评。 产生design C全部公开签名；消费A focus/default/caret、B统一变换/ensure、080真实children和生命周期、088唯一resolver/fill、Frame透明合成。

**Deliverables/files:** 文件表tests/interaction_c正式消费者/必要fixture与test-only固定提交；docs/reviews/interaction/C/TASK-108/red/原始命令、stdout/stderr、exit、source/test/hash清单和用例→AC映射。

**Acceptance/verification:** 全部C-01–C-05至少有正常及相关边界/失败观察；基线正常编译后新公共API出现可复现RED；期望不由待测renderer/resolver生成；测试没有私有hook或产品修补。

**L4:**

- [ ] 3.1.1 TASK-108.S1：按C-01/C-05建立同type普通/层实例和三级modal/popup消费者，人工trace域边界、app/legacy零调用、interrupt与Escape顺序；在107固定源取缺overlay API RED。
- [ ] 3.1.2 TASK-108.S2：按C-02/C-04覆盖owner隐藏/卸载/仅disabled、非顶层关闭不误关兄弟、pending cancel、失效恢复、双挂载、非法host/anchor、stale/跨session与cleanup异常。
- [ ] 3.1.3 TASK-108.S3：按C-03固定透明/opaque/主题无背景modal/阴影/caret与host clip网格，滚动锚点完全不可见触发AnchorGone；底层状态变更后关闭显示最新内容。
- [ ] 3.1.4 TASK-108.S4：冻结测试及运行说明，入口为bash tests/interaction_c/run.sh；明确其内部正常cjpm build和直接binary执行命令及预期exit，记录docs/reviews/interaction/C/TASK-108/manifest.json后交主代理。

### TASK-109: 实现有限公共单元并自验

`parent=WP-004; parent_task=TASK-018; type=implementation; requirement_refs=REQ-003.4/.5/.7/.8、REQ-009.1、REQ-001.5; model=Terra/high; depends_on=TASK-108固定产物`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 交付owner层关系/host-clip/anchor、modal域与关闭恢复、主题surface和统一层caret合成，独立满足C-01–C-05的公开行为。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-107已接受B及A固定源、overlay/surface声明微编译与本单位前置复核、TASK-108固定测试与本design；读取正式入口/实际resolver映射，不依赖其他作者私有缓存或自评。 产生design C全部公开签名；消费A focus/default/caret、B统一变换/ensure、080真实children和生命周期、088唯一resolver/fill、Frame透明合成。

**Deliverables/files:** 文件表Unit C产品源/公共例子/文档及product-only提交；正常构建和必要自验raw/hash归docs/reviews/interaction/C/TASK-109/self-check/；更新API实际编译状态须有公开消费者证据。

**Acceptance/verification:** 冻结公开测试和受影响原回归通过，正常lint/build不skip；无C之外的控件/协议扩范围，不更改测试或规范迎合实现；退役规则：不建立第二Component树/Runtime/renderer或截图恢复；overlay边不进入普通children，不给theme新增第二fill解析；A框架Escape无层时无动作，在本期接真实层取消。

**L4:**

- [ ] 3.2.1 TASK-109.S1：在同Runtime节点上增加owner关系种类与有界层记录，open/close预留与提交接原代际/cleanup；host只管几何clip，普通children序列及动态组语义保留。
- [ ] 3.2.2 TASK-109.S2：接当前modal域、nonmodal目标层/Tab序列、Passive规则、Escape与依赖闭包关闭的一次焦点恢复；禁止域外dispatch，错误统一FocusOutsideDomain。
- [ ] 3.2.3 TASK-109.S3：接surface额外fill意图/同resolver与Frame透明合成、anchor定位/旧新阴影失效/caret遮挡；公开同type复用例子和文档，验证固定测试与必要回归后提交product-only。
- [ ] 3.2.4 TASK-109.S4：运行bash tests/interaction_c/run.sh及admission清单列出的受影响既有检查，记录实际exit；检查技术diff/实体文件/旧路径退役，提交产品hash给主代理。作者自验不是独立验收。

### TASK-110: 固定源码独立规格与质量审查

`parent=WP-005; parent_task=TASK-018; type=verification; requirement_refs=REQ-003.4/.5/.7/.8、REQ-009.1、REQ-001.5; model=Astra/high; depends_on=TASK-109固定产物及TASK-108固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 独立判断固定产品是否符合冻结合同与质量治理，给具体反例及双verdict。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** 本单位base..TASK-109固定product技术diff、TASK-108测试、design/specs/源需求和admission清单；不读取作者说明中的自评结论。 产生design C全部公开签名；消费A focus/default/caret、B统一变换/ensure、080真实children和生命周期、088唯一resolver/fill、Frame透明合成。

**Deliverables/files:** docs/reviews/interaction/C/TASK-110/findings.json及review.md，逐项spec/quality verdict、source/test/contract hash、定位与可复现条件；不改产品或正式测试。

**Acceptance/verification:** C-01–C-05及Review focus有独立核对；所有Critical/Important修复或经主代理明确裁决后复核；不能只评价作者报告或测试数量。

**L4:**

- [ ] 3.3.1 TASK-110.S1：锁定base/product/test/contract hash，逐公开接口核对design本单位与C-01–C-05、上游交叉及错误优先级，交可达反例而非泛泛建议。
- [ ] 3.3.2 TASK-110.S2：检查文件职责/单Runtime/单resolver/Frame/宽簇、生命周期与资源上限；核对退役安排“不建立第二Component树/Runtime/renderer或截图恢复；overlay边不进入普通children，不给theme新增第二fill解析；A框架Escape无层时无动作，在本期接真实层取消。”。
- [ ] 3.3.3 TASK-110.S3：输出spec/quality双verdict与发现严重度；发现回主代理，不私改代码/断言。收到新固定修复后仅复核受影响diff和相关失败证据，保留前次记录。

### TASK-111: 独立执行与正常制品消费

`parent=WP-005; parent_task=TASK-018; type=testing; requirement_refs=REQ-003.4/.5/.7/.8、REQ-009.1、REQ-001.5; model=Sol/medium; depends_on=TASK-110固定产物及TASK-108固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 在独立环境执行冻结产品和测试，证明真实公开消费/设备行为，记录实际命令与exit。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-110审核接受的product/test/contract hash、测试run入口、admission必要回归清单；不复用作者target作为制品。 产生design C全部公开签名；消费A focus/default/caret、B统一变换/ensure、080真实children和生命周期、088唯一resolver/fill、Frame透明合成。

**Deliverables/files:** docs/reviews/interaction/C/TASK-111/run/与bundle/原始stdout/stderr/exit、SDK/依赖/尺寸/PTY恢复/输入输出、source/artifact/hash；成功/失败逐AC清单。

**Acceptance/verification:** C-01–C-05适用项执行有原始证据，正常CJPM build/bundle不skip、干净解包消费者只改manifest path仍通过；设备声明有真实PTY，不能仅headless注入。缺环境明确insufficient_evidence。

**L4:**

- [ ] 3.4.1 TASK-111.S1：在自己的SDK/registry/cache配置下核hash，执行bash tests/interaction_c/run.sh并保存真实exit；随后仅执行admission清单相关既有回归，复用未变内容的有效证据。
- [ ] 3.4.2 TASK-111.S2：正常cjpm bundle（不skip）后干净解包，正式公共消费者与例子仅改manifest路径构建运行；SDK/stdx前置按088交付记录，不借作者私有cjo。
- [ ] 3.4.3 TASK-111.S3：执行真实PTY多层域/取消/interrupt/caret遮挡与退出恢复，另保存headless手工golden对应输出。
- [ ] 3.4.4 TASK-111.S4：保存逐命令raw、source/test/bundle/consumer SHA256与AC结果，发现失败回主代理而非直接修产品/测试；不以同PTY换TERM冒充多个真实宿主。

### TASK-112: 有限合同与父AC映射独立验收

`parent=WP-005; parent_task=TASK-018; type=verification; requirement_refs=REQ-003.4/.5/.7/.8、REQ-009.1、REQ-001.5; model=Astra/high; depends_on=TASK-111固定产物及TASK-108固定测试`。通用L3字段、状态及skills继承Shared L3 card fields。

**Objective/scope:** 依据原始证据给单元C有限验收，决定可否交给下一单元，不把基础API当全部控件完成。 范围排除完整widgets/编辑/M2；本角色只编辑其责任目录。

**Inputs/interfaces:** TASK-110独立审核、TASK-111原始执行、固定测试/产品/合同/制品及TASK-018原AC全文；不依赖作者自评。 产生design C全部公开签名；消费A focus/default/caret、B统一变换/ensure、080真实children和生命周期、088唯一resolver/fill、Frame透明合成。

**Deliverables/files:** docs/reviews/interaction/C/TASK-112/acceptance.md、evidence-index.json及hash核对；逐C-01–C-05pass/fail/insufficient_evidence与父项残余映射，主代理据此集成。

**Acceptance/verification:** 所有C-01–C-05必需证据可追溯且无未决严重缺陷；版本/命令/制品/环境和实际结果一致；不得因支持任务完成提前关闭019/028/029/020/030/M2/Linux。

**L4:**

- [ ] 3.5.1 TASK-112.S1：从原件核对C-01–C-05到测试、执行raw与技术diff的映射及hash，确认公开消费者和真实设备声明各有相应证据，不重复已有效suite。
- [ ] 3.5.2 TASK-112.S2：核对父TASK-018完整AC与本单位边界：018层所有权/模态/焦点恢复可按实际全范围证据判定；019菜单与标准Modal/027全主题展示另阶段，020完整恢复合同仍需其全部证据。
- [ ] 3.5.3 TASK-112.S3：给有限结论与缺口列表，失败保持verifying/blocked并注明恢复条件；通过由主代理投影长期AC/任务并交下一单元，不凭任务勾选归档全部Linux。

## DQ and source checks

当前起草者仅做文档自检，不替代独立preflight。DQ01/02：15个支持L3各有独立结果，三单位按接受源串行；DQ03/05/11：共享卡+各卡+AC+L4组成完整输入输出及可观察结果；DQ04/07/08/09：父017/037/018及后续控件边界明确，A→B→C跨界分别在102/107/112验收；DQ12：状态单权威、证据与计划区分；DQ14：文件/退役/唯一权威有明确说明。这些是本稿待独立复核的映射，不在此预填pass。

DQ06/10/13保持not_checked：实际080/084/088验收与固定源、完整签名微编译、技能可用/使用证据及独立preflight尚未由本角色核验。任一适用项不足不得标ready。OpenSpec严格schema通过也不替代这些技术门槛。

## Workflow follow-up

- 主代理集成规划目录、关联docs/tasks/长期AC时只作已冻结内容映射；本独立起草角色不改主仓。
- 三单位接受后仍按原稳定任务完成菜单/编辑/widgets/可选会话/四主题展示/M2及Linux整体目标；归档只在本变更适用证据完成时进行，不发布。

### A追加公共集成边界

098测试/099产品/100审核/101执行/102验收同时消费I011–013：NodeRef.application只读同会话服务入口、统一resolver自动disabled/focus并与声明状态OR合成、ScrollAxes.Off保持裸Option None源码兼容。A hand-written detached/ancestor-disabled/后链覆盖/focus+selected样例必须实际验证，不能等widgets再用私有节点补洞。Off签名微验证只是语言事实，不是B滚动已实现。

I014补冻初始基础域首eligible自动焦点，None后新增候选与显式takeFocus空层保留例外，098/108各补手写期望；正式test冻结前单独preflight限定核，不以隐式选择让实现者自由决定。

### I015新增前置与A测试/产品L4

正式098/099保留080/084/088并新增152实际固定接受source/writer输入；root顺序为084→有限148–152→Glyph097→Theme088/092→A098–102→B/C→Keyboard113–117。152不包含完整paste/cut、020/041，无反向依赖A，不制造环。A099在同一InputDecoder只增原I007与I015精确reply路径，唯一native writer/byte计数/unsafe闩由149负责，禁止A另写一套。新增文件caret_probe.cj（内部ledger/单一实体），现terminal_capabilities.cj只读字段，native桥cjt_monotonic_ms；具体原功能文件按现表沿用。

098手写时序/byte/显隐/只读诊断golden，覆盖design I015第7节。099先接已验writer和C单调时钟，再唯一decoder内部report接点、Application异步一次窗口/空闲计时、同一设备caret成功基线/cleanup，最后文档说明Unknown效果；不能为query丢普通输入或重置decoder。100以完整固定技术diff审核I015无第二parser/queue及错误路径；101只对变化跑相关正式检查/实际三host两原态原图；102核逻辑caret、协议授权、实际显隐/恢复、自动降级四层证据，不以未知分支PASS宣称所有host原生显隐可控。
