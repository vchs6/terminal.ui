# Rich text implementation plan

> For agentic workers: REQUIRED SUB-SKILL superpowers:subagent-driven-development；完成后连续推进Linux总计划。

**Goal:** 显式typed富文本和安全有界ANSI适配，不主动美化。
**Architecture:** 单一Text/LayoutNode/Frame路径，整篇Unicode分簇，白名单SGR薄适配。
**Tech Stack:** SDK1.2.0、ansies1.3.113及现Unicode依赖，产品0.0.0，无新依赖。
**Spec:** design.md、REQ001.4/005.1–.4、原AC009；父AC010可见层等后续018。

## Global constraints

独立测试/产品/审核/执行/验收，主代理只契约与集成；一类型一文件。原严格String接口、布局/宽字符/颜色/快照断言保留。与runtime唯一Component/typed绑定集成，不复制渲染/ANSI/Unicode内核。正式产品作者等runtime固定版本及本081测试准入，禁止并行改同一权威文件。仅调查/测试可并行准备，缺API RED可先针对现产品。

## Review focus

1. UTF8 continuation数值像C1不能变控制，非法UTF8fail-close。
2. 超限控制串不放回正文，嵌套ESC/CAN不释放隔离。
3. SGR未知/非法整条不部分应用，空字段与复位/unset不同。
4. 跨span簇/CRLF一次分段，Frame和组件相同样式/裁剪。
5. 可变数组别名与String/RichText绑定替换不能使内容或订阅偷偷改变。

## Tasks

- [x] TASK-081（WP005/testing）：冻结tests/rich-text公共消费者、字节分块/手工样式golden/错误与真实RED。
- [ ] TASK-009（WP002/implementation）：有界decoder/typed文本/Frame及组件一体集成，固定产品提交。
- [ ] TASK-082（WP005/verification）：固定完整技术diff独立spec/quality审核。
- [ ] TASK-083（WP005/testing）：独立新矩阵、受影响帧/布局/runtime回归、正常bundle/公开包消费者。
- [ ] TASK-084（WP005/acceptance）：原AC009及有限文本集成证据/元数据，仍不提前关闭完整010/Linux。

## Shared admission / L3 cards

各项为L3；081/082/083/084父WP005/REQ007，009父WP002/REQ005。classification execution：用户已定ANSI仅文本样式/框架自动降级，主代理据已验依赖缺口选最小边界；change本目录，workflow本tasks。必要skills：主代理brainstorming/writing-plans/SDD，作者TDD/仓颉coding/调试/verification，审核review，验收verification；实际使用归progress。指定模型081 Sol/high，产品Sol/high（AGENTS13.2：适合仓颉语言任务），审核/验收Astra/high，执行Sol/medium，实际serving未暴露时不伪证。

inputs：Frame5c2a7e7后同源已验输入、颜色R10、现严格Text、ansies真实API探针`/workspace/work/text-contract-audit`、runtime已冻结合同a947857。081等独立preflight ready后写测试；009等081固定与runtime A+B产品已集成（072–075），不越过相关并发写屏障。082→083→084按固定产品顺序。009原TASK003/006只消费已证明公共依赖与颜色，不提前关闭完整003。010仍由docs/tasks原状态保持。

scope/impact：新增typed spans/decoder，修改Frame/Text/测量绘制共享数据、getter失效和公开导出；排除键盘/paste、设备控制执行、主题配置、overlay、M2。必要性：原纯String不能承载ANSI样式；canonical owner：TextStylePatch未解析内容，Style最终值，AnsiTextDecoder唯一输入流，现LayoutNode/Frame唯一渲染。旧路径保留String公开入口并共享单span表示，不留两个width/SGR策略；没有用户持久数据迁移。复杂度新增有界状态/样式映射是薄适配缺口，不做终端状态机。风险/失败边界与全部资源确值见design5/6。

deliverables：081 tests/rich-text/cjpm.toml、src/main.cj及单实体helper、run.sh/tests说明/run-slice分支（等runtime/dynamic接线已固定后顺序追加）；009 src/style/text_style_patch.cj、src/text/{text_span,rich_text,ansi_text_limits,ansi_text_issue,ansi_text_diagnostic,ansi_text_batch,ansi_text_result,ansi_text_exception,ansi_text_decoder}.cj（按实际package循环关系可内聚调整，但不得跨包额外公开内部可变状态），src/frame.cj/component.cj/layout_node.cj/layout.cj/exports.cj、产品README、examples/rich-text公共项目；082报告/findings，083真实raw/哈希/源码包和纯路径消费者，084逐AC证据结论与集成投影。

L4：081先手算span/Cell/字节golden，全部byte切分、组合簇、4095/4096/4097和63/64/65、ST/BEL、C1/UTF8非法、所有SGR及原String拒绝，再旧库正常build和直接consumer缺API RED，冻结test-only。009先typed不可变值/共享簇映射，再有界decoder，随后Frame/组件绑定集成；固定新测试及受影响旧断言，product-only提交。082检查baseline至固定产品与tests/spec，不读作者自评，双verdict；发现缺陷回对应测试/实现作者修。083独立cache/配置正常构建并直接binary实际exit，按相关内容复用旧有效证据，普通bundle不skip，解包consumer只改manifest路径，记录环境/源/hash/UTC。084只核原件/副本/制品/hash/实际执行与原AC，不机械重跑suite；文档与状态单权威。本增量证据归R14（R13保留动态结构）。

preflight：081自洽性=公共不依赖实现golden；009=先验证整值再写Frame，控制流无透传；082/083/084各自固定输入和独立结论。081→009共用精确design，009→runtime只加typed内容/getter，不建新Runtime；009→082→083→084无环且上游等待明确。shared frame/layout文件只允许前一runtime作者已完成后再改。原AC009状态需转移到此tasks，docs/tasks只留引用；尚未获得独立DQ准入不得产品实施。详细DQ01–14由独立preflight核。

正式081准入：独立preflight固定7a33ddc最终ready，无剩余Important；原009状态已转本表、AC081–084在docs/acceptance唯一维护。DQ13来源/安装记录复用[已验证开发技能](../../../docs/reviews/R11/skills.json)，主代理实际本次使用cloud using/brainstorming/writing-plans/SDD及preflight，过程见progress；作者按其职责实际读TDD/cangjie-coding/search_docs并在交接记录调用。用户仓颉工具固定277f2e1、rules40bacab，Skill使用不引入产品依赖。此准入仅081测试，009产品仍严格等固定tests与runtime/shared文件屏障。
