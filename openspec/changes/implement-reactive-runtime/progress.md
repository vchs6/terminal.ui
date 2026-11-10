# SDD ledger — plan: openspec/changes/implement-reactive-runtime/tasks.md

Baseline6a7b240bfc89bb054b11306f257ebed519a26b5f, main clean and pushed. User explicitly authorizes all Linux work, independent roles, suitable models and direct-main. Planning uses existing approved goals; no repeated approval menu. This increment does not conclude the full Linux task.

Root adopted independent draft with final section6 overrides. Language/macro packaging facts are independently compiled, including generic/interface/parameter init, WeakRef, ThreadLocal and Component macro/type names. Namespace import requirement is explicit. Independent preflight must resolve any concrete contract defects before formal tests/product.

主代理已实际使用cloud using-superpowers、brainstorming、writing-plans、SDD及preflight reference；brainstorming因用户明确选择自主执行，不再询问方案或设计确认。仓库本地7.0.0技能用于workspace helper，cloud正文不冒充同版本。helper创建`.superpowers/sdd/tasks-implement-reactive-runtime`，ledger链接本文件；指定独立runtime_preflight Astra/high核合同，不传产品作者结论。text_contract_audit Sol/high及theme_contract_draft Astra/high为后续独立只读草稿，不能自行实施或冻结。

| preflight接口/任务 | 主代理检查与裁决 |
| --- | --- |
| 071 self | 只写测试/runner/说明，手工期望/同步race/编译诊断；无实现，也不以自测替代独立执行 |
| 072 self | Component/Runtime唯一路径，原设备恢复围栏必须保留，宏公开精确源码按真实SDK验证 |
| 073 self | spec和quality双结论，固定完整diff，不读产品自评 |
| 074 self | 真正binary exit、正常bundle、只改manifest路径消费者；旧同源有效结果可复用 |
| 075 self | 有限合同逐项原件/hash与metadata，不提前关闭稳定父任务 |
| 076 self | C表的独立golden，初期可准备，RED等A+B固定输入 |
| 077 self | 只一个ChildSequence，内部marker不是布局盒子，不复制业务排序 |
| 078 self | C增量及A+B跨界审查，重点订阅/生命周期/序列权威 |
| 079 self | 独立C执行和受影响runtime回归，保持冻结测试 |
| 080 self | 原AC015/016/032全条件才关闭，014等弹窗实证 |
| 071→072 | 同design精确API、宏导入和R001–014；默认shadow复合getter未承诺，单参数属性明确全覆盖 |
| 072→073→074→075 | 固定产品/测试/契约后双review，执行raw，验收hash/有限结论，发现缺陷回对应作者 |
| 072→076→077 | NodeRef/session/ChangeKind/public调度；C仅扩展其动态组和结构入口，无新runtime |
| 071/076 tests/run-slice.sh | 071先冻结接线，076在其固定版追加dynamic分支；主代理按次序集成，不并行覆盖 |
| 072/077 Component/Runtime/Layout | 077等075后在集成基线上修改，A+B作者不同时写，C权威序列替换必要旧字段 |
| 077→078→079→080 | 固定源码+测试→审核→独立执行→AC；不以旧A+B结果代替新结构行为 |
| runtime→后续焦点/主题/M2 | NodeRef/dirty与完整M1参考作为输入；新功能不得另建UI路径；各自AC待后续实施 |

Ruling：保留末次stats累计但dispose当前存量归0，明确用于资源释放检查；队列owner取消后pending量须归零。异步任务持续产生不参与当前turn同步稳定上限，避免合法进度流被当死循环。若独立preflight发现可达矛盾先修合同，正式测试后才写产品。

独立preflight指出组合根默认布局、无focus时设备事件目标两项Important合同空缺。主代理R015明确默认Column布局盒、run活动可见root为目标；隐藏target/祖先显式dispatch报InvalidProperty，隐藏root设备不虚构UI事件但保留旧非interrupt handler/默认interrupt停止。修正stats的paint计数为每节点paint调用，不强迫自由函数改成员。等待审查者核此限定修文后071准入；没有提前派产品。

独立preflight最终a947857 ready/design_reviewed，DQ01–14 pass，两历史Important已由R015验证关闭，无剩余Critical/Important；原件见`docs/reviews/R12/preflight`。071作者runtime_test_author指定Sol/high已获明确frozen与开工，自有`/workspace/work/runtime-tests/source`，只A+B正式测试；产品072仍未准入。语言supplement/names源码/raw已按原件复制R12/language，planning-evidence.json记录来源/副本/hash，未重跑探针。仓库OpenSpec1.14.3实际list/status/apply报告ready、0/10，planning_complete不代表产品完成。

071作者获得旧库正常build0、消费者missingAPI真实RED1，并独立声明-only scratch语法编译0（从未运行、非产品证据）；等待首个core test-only固定SHA，宏fixtures继续同合同覆盖。作者发现headless interrupt停止清理的确切时点未定，主代理R016明确dispatch返回前安全UI清理；后台stop仍只是请求，绝不后台cleanup。076作者独立C测试准备，无A+B基线故尚未正式RED；其错误码歧义由R016区分属性求值ReentrantEvaluation和结构上下文ReentrantStructure。此为限定合同澄清，回原preflight独立核，不重跑旧调查。

071完整测试固定原62facc4→489d329→ae8520c，main投影9cd654c→9bea05f→6f62eb5；core/macro正向/session真missingAPI RED1、旧库build0，测试源码/raw/报告见R12/test-design。只语法声明scratch从未执行，macro负向不得因缺包假通过。主代理机械完成071交付，实际AC071仍等075独立验收；072在R016限定ready及core固定后正式准入，已收到全部最终tests。实现者runtime_implementer指定Terra/high、自有source/cache，当前开发core/宏正向通过，PTY发现边界退出错误正定点修复；这些仅开发自测，不等于073–075完成。

076独立dynamic_test_author已准备32组手工golden/公共API草稿，静态语法/旧库build0仅环境证据，无A+B新基线故还未missingC RED/正式冻结；恢复时直接唤回该角色，不重复另派。后续richtext合同独立ready，081测试正在准备，009产品仍等072–075及共享文件屏障；不同时改同一Component/Layout权威。

072发现SDK Exception不能附加suppressed/cause，旧清理额外错误仅stderr不足，主代理R017引入UICleanupException公开保留primary原对象/有序附加列表及数组防御复制。主代理先下达编码导致作者提前写入未编译R017，后又误指示保留；读TDD实际铁律后纠正为仅删除该新类型/聚合改动、恢复先前core已通过临时路径，不保留参考副本。作者已确认删除，相关中断验证exit130不计通过；其他A+B代码/测试/证据保留。此真实时序不反写成先RED。071作者独立补R017测试/旧库真实缺API RED，原preflight限定复核；重新准入后从测试/合同重写。后续R017选择所有双失败均公开保留primary对象，D027原消息组合为前缀、计数追加末尾，不保留旧丢对象实现。

R017扩大了071的公开异常测试交付，原R001–016冻结交付保留，071当前临时重开等待独立新补充，不把前次完成自动外推到新接口。只新增相关RED/类型与聚合断言，不重跑无关旧套件。

主代理实际读取receiving-code-review、SDD fix-loop后按原要求处理：首轮4267/f07独立spec/quality FAIL，F001–006均Important，独立公共/真实PTY反例先固定为d958，源码线程身份/节点分类/idle成本按证据核；修复原e1→d46→0aa投影28a8af9→f11f82c→19b620f，分类/线程生命期等澄清R018不缩窄。0aa开发和独立CPU样本均固定512×256/2048getter/默认heap/约2s；f07基线1.30CPU秒，独立candidate0.01CPU秒，单机单次/10ms tick，不能外推绝对零CPU或跨宿主性能。原1024²OOM/探索样本不是CPU有效样本。

Task072 fix round1/5：F001–006已独立关闭；相邻owner错误出口F007仍实质且下游依赖，按原R007错误清理处理，不降Minor或拖到C。独立fc690c三case normalbuild0/directRED1，修复原01efa投影c3d743d；Task072 fix round2/5最终spec/quality PASS，无未决Critical/Important，原review/r017/fail证据保留。071原至fc690全部正式测试已固定；076 32组也已独立新A+B build0/真实missingC RED1，原3ee1a9b等待集成，不重发已完成测试。

074独立runtime_execution指定Sol/medium在c3源完成core255 PASS、宏正向、15negative有效复用审计、12PTY、六组旧Frame/布局回归、正常bundle/干净root-core-macro-reactive消费、XTerm/VTE两个实际宿主PNG/input/resize/恢复及CPU，唯旧application-lifecycle resize-success原样失败，总074 FAIL，075不得提前开始。独立resize_root_cause按systematic-debugging隔离确认双缺陷：产品两query能混pair；GNU stty两TIOCSWINSZ会真的产生中间24×3；两种raw与原306B完全相同，不能凭旧日志唯一归因；完整旧帧inflight也合法。R019冻结内部原子尺寸快照与正确settled oracle；先独立测试/真实RED，后产品作者修，再限定审核/受影响执行，不重跑无关已有效证据，不修改旧失败为通过。

R019独立test-only原dddbdd9已集成6d703bf：真实App coherence强RED1、合法inflight0、修订两legacy settled fixture旧产品0，原失败未覆盖。产品原61ce9e5已集成0912436，仅native/bridge/App三文件，开发root/native/ABI/coherence/inflight/两resize/正常bundle均0；不以自测替代独立074。073原审者正在限定复核，074随后只重验受影响native/resize/新源码包，复用无关同源宏/runtime/Frame有效证据；075尚未准入。

R019独立限定073最终spec/quality PASS，无Critical/Important；独立C probe覆盖0/1/65535组合/单GET/axis/error，重解析原始PTY验证强RED及合法inflight/最终grid/termios。报告及失败历史按原字节归R12/code-review，archive-index逐文件hash。074已在原固定0912436准入限定复验，不因main后加C/Rich/theme测试改变运行源。

074 R019限定复验最终PASS：0912436新root/native ABI/coherence/inflight/两legacy resize/正常bundle/新清包root+native+公开reactive direct真实0；原c3旧FAIL及其coherence RED保留，core255/宏/旧Frame/12PTY/真实GUI/CPU原c3范围有效复用，不冒称091实测。新cjp SHA045d4030cc461922a91a207a0bd268e610fcc52175c753dfcd39a6757ba9465d，47有效源文件同091，fullrelease composition仍待交付。764份执行原件hash核验后机械归R12/execution（含两宿主原始PNG/版本/source/time/raw），075独立runtime_acceptance Astra/high已准入，有限验收不关闭父014/015/016/032/041。

Task071–075 complete：独立075 runtime_acceptance Astra/high有限PASS，无未决行为缺口；原102审核/764执行/286补测hash及raw语义复核，报告bc2d927c530d4352ed9789d532a3441dabaf00f57f63333ba7a0d0068280179d归R12/acceptance。唯一Minor原VTE metadata字面TAB保留，追加严格JSON投影ce8e3f87d26015c886a1ea9ed05fc3215a5c4c95f1237bec1784cf601a94f2df已parse/值相等，integration-index链接两者。主代理机械登记AC071–075 passed，不提前关闭原父。076独立32组测试原3ee1a9b已集成bc91577，真实缺C RED1/旧root0，交付证据归R13/test-design；测试交付勾选不代表C行为PASS。现在准入077 fresh产品作者，继续Linux，不停在A+B。

077首次fresh Terra/high dynamic_implementer因其本次上下文/执行预算自报无法完成，未修改任何tracked产品，唯一cjpm.lock未跟踪；中止normalbuild130且无落盘raw，不是项目失败/通过证据，不集成f9313a9测试pin。root确认无权限/SDK/合同实质阻碍后，依据AGENTS13.2改派适合仓颉的fresh Sol/high dynamic_implementer_sol，从同已接受BASE独立clone、自有cache继续完整077；旧角色停止，当前仅一个产品作者，不降低C验收范围或重写测试。

077作者原167c2a3已集成266cf7e，初34前32开发PASS/正常bundle/纯包示例交付；独立078 dynamic_code_review Astra/high spec/quality FAIL，DYN-F001 Important确认：nested DeclaredGroup在外层发布/retire后才校验，两个公共probe oldcleanup看到liveparent。按实际SDD fix-loop round1/5，独立Sol/high regression作者先test-only10c4ee3（mainc066e99）正常build0/directRED1，旧32自然PASS、两新cleanup/token断言各真实失败，其余资源/业务保持断言均执行；产品修复不先于RED。

Fix round1作者同原Sol/high角色（环境恢复后续接dynamic_implementation_resume，不重写/不重跑仍有效成果），216b2ab仅2src29+/10-已集成5de716f；递归初始化未公开动态子树、initial binding clean及净credit/startup预算，开发34/26定向/core/PTY12/新bundle/纯包34均0，sourceAggregate76a7bff748f0e2cd12e4f17e73e2db89db4a9f6cf4ce6037fb79b4b1f814717e。原078者正限定复核，尚未正式PASS，079/080未准入。原FAIL及旧raw保留，所有有限支持不提前关闭Linux。
