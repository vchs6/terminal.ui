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
