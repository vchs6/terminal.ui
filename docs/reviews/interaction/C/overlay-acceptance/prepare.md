# TASK112 — PREPARE / READY，尚无接受结论

执行型、独立有限C验收；仅本目录写入。输入源码预期 `f331995c760edd8f65e85d8dcf4a298da7df2707`。正式 ACTUAL GO 及固定111产物到达前，不运行产品/构建/测试，不复制SDK/仓库/raw，不改规格、测试、产品、main，不归档。

已读：`terminal.ui/AGENTS.md`、`task-112-brief.md`、`implement-public-interaction/tasks.md` Shared L3/111/112/C-01–05、其 `design.md` C.1–C.7/shared errors/I014、`implement-theme-styles/design.md` T008、`docs/tasks.md` TASK018原卡及 `docs/acceptance.md` AC018。已读独立110 `overlay-review/round2/{report.md,findings.json,rawmanifest.json}`：仅 source spec/quality PASS，非交付验收。本阶段未作hash接受判定。

| 有限项 | 必核可观察义务 | 待固定原件／状态 |
|---|---|---|
| C-01 | 三级层当前域、app/legacy零调用、域外拒绝、Escape顺序、未prevent interrupt退出 | 108固定trace + 111执行/真实PTY；待交接 |
| C-02 | owner隐藏/卸载完整依赖闭包、非顶兄弟保留、仅disabled不禁层；有效/失效焦点一次恢复，I014空层保留 | 108生命周期/焦点 + 111 raw；待交接 |
| C-03 | 默认modal表面/主题、hole与opaque、阴影/caret、根及非根host clip、滚动anchor/AnchorGone、关闭呈现最新底层 | 108人工网格 + 111输出/宿主；T008候选失败保旧主题、无getter/build/mount重跑；待交接 |
| C-04 | pending取消、重复预留/挂载、stale/跨域、host/anchor错误、预算/cleanup、撤销及异常恢复 | 108失败fixture + 110审核 + 111 raw；待交接 |
| C-05 | 同SettingsPanel类型两实例共享model、公共绑定一致、普通children排除层根、节点/主题/offset按合同保留 | 固定消费者/例子 + 正常bundle/干净消费；待交接 |

真正待交接（不是已确认失败）：① root正式 ACTUAL GO，以及111稳定manifest路径/hash和证据root；② product/test/contract/config/依赖/SDK身份、命令/exit及源前后未变依据，108固定测试与C项映射、有效suite复用范围；③ mandatory lint、正常build/bundle的原始输出、cjp hash/成员及干净解包消费者/例子仅改manifest路径的证据；④真实PTY及不同真实宿主版本/配置/尺寸/能力来源、输入输出/termios/native恢复、实际PNG及hash。110各轮原件位置已知，不列为缺项。只核必要原件hash、适用义务与父AC残余，不建立逐资产额外审核层或重跑有效suite。

父TASK018完整AC原文：“父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态”。四部分分别映射 C-02／C-01／C-02／C-03，均待证；全部满足方可建议018范围结论。019菜单/标准Modal、027完整主题展示、020完整会话恢复、028/029/030、023/024、M2及Linux整体仍独立未关闭；B-M01 getter axes/onMount Off继续 deferred TASK024。109/110最终metadata不得只凭source PASS关闭。

技能：已读取云 `c5/verification-before-completion`（2026-11-13）；依AGENTS §11.1和派单复用有效原件，不将技能解释为重复执行授权。`using-superpowers`已读取，其SUBAGENT-STOP适用。OpenSpec入口沿用现有变更与任务卡；本准备页不另设权威任务状态。请求模型Astra/high仅派单配置，不认证实际serving。正式交付仅 `acceptance.md` 与 `evidence-index.json`，当前均不生成。
