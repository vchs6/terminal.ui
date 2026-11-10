# Frame composition implementation plan

> For agentic workers: REQUIRED SUB-SKILL Superpowers subagent-driven-development，持续执行，不以设计稿替代实现。

**Goal:** 在现有 Frame 完成有界透明合成、宽字符复制/清空/缩放和文件快照原语。
**Architecture:** 复用 Cell/Frame/Style 和现有字符/ANSI 适配；不新建帧内核。
**Tech Stack:** 仓颉 SDK 1.2.0、现有三个中心仓依赖、产品 0.0.0。
**Spec:** design.md、REQ-004.3/.4/.5、REQ-005.5/.6、NFR-03。

## Global constraints

主代理仅契约/集成。独立测试→实现→审核→执行→验收，各自目录与固定版本，不互传作者推理。每仓颉类型一文件；旧断言/字节不弱化；不改第三方/颜色/布局语义。前置消费 R8–R10 已验 Frame/Unicode/Style 与本 design 的 TASK-004 子接口，完整 001–004/010 父 AC 不提前关闭。

## Review focus

透明不能由空格/Default 推断；宽簇裁剪不能留下半字符；自身重叠必须源快照；极值不能溢出或循环；文件失败不得报成功。全部由 067 独立固定网格/错误断言覆盖。

## Tasks

- [x] TASK-067（WP-005 testing）：冻结 tests/composition 公共消费者与 runner、原始 RED、固定期望/失败场景。只改 tests 与测试说明；不改实现。
- [x] TASK-005（WP-002 implementation）：现有字符簇写入扩展至透明 clear/copy/resized/composite，所有宽簇边界及预算通过；依赖 067。
- [x] TASK-007（WP-002 implementation）：完整透明/不透明 Frame 合成与文件原语，共用 005 同一实现提交及测试周期；依赖 005/006，单一产品作者，不人为拆成平行内核。
- [x] TASK-068（WP-005 verification）：固定完整 diff 的 spec/quality 独立审核及必要 scoped 修复复核；无未决 Critical/Important。
- [x] TASK-069（WP-005 testing）：独立构建、新消费者、旧 contract/coordinates/colors/layout/decoration 受影响回归、标准 bundle 与普通包消费者；记录实际 exit/raw/source/hash。完整 release 仍有后续交付，不冒充通过。
- [ ] TASK-070（WP-005 acceptance）：逐 AC-005/007 及本变更文件原语有限验收、最终元数据核对，合入 main 后自动继续总计划。

001–004 子输入、005/007 canonical_owner 和 compatibility 见 design；010 状态仍由 docs/tasks.md 持有，文件原语为部分交付。067–070为本变更唯一支持状态，对应新增 AC 同号，父 WP-005/REQ-007。

## Interfaces / file ownership / L4

067 消费 design 精确签名；产出 tests/composition/cjpm.toml、src/main.cj、run.sh 以及 tests/run-slice.sh 新分支/all 和 tests/README.md。先正常构建旧产品，直接执行/编译取得真实缺 API RED并保存原始 stdout/stderr/exit。

005/007 消费已冻结 tests；修改 src/cell.cj、src/frame.cj，必要纯函数放 src/frame_composition.cj（不另定义 Frame/Cell），产品说明 docs/product/README.md。模型/预算→合成/宽簇→复制/文件→必要 cjfmt→针对验证→product-only 固定提交。

068 消费 BASE31a7017..固定完整技术 diff/本设计/冻结 tests，不读作者分析报告；给双 verdict/反例/必要修复，最多三轮 scoped 复核，必要时按总治理裁决，不无限回扫。

069 消费已审固定版本，自己的 SDK/私有缓存/忽略 registry 配置；正常 build 后直接 binary；依范围复用有效同源结果，不重复既有不受影响会话/能力探针。新 compositor 受影响旧帧行为必须真跑；包检查保持真实有限边界。

070 消费原件/固定代码/审核，不重复功能套件，核文件 hash/状态与父任务有限范围；结果归 docs/acceptance.md，不能把该增量提升为 Linux 全阶段完成。

## Shared admission card / DQ

| 字段 | 本批实际定义 |
| --- | --- |
| 分类/依据 | execution：用户已经确定字符语义、Linux全阶段及架构，现有代码可直接扩展；透明/预算/文件具体边界由本design冻结，非重新选择产品目标 |
| 输入/准入 | 基线31a7017，R8–R10正式Frame/Unicode/Style/正常消费者证据，当前design的004子接口；完整001–004父AC继续待验，相关独立输入已满足 |
| parent/refs | 005/007属WP-002/REQ004；067–070属WP-005/REQ007，实际AC在docs/acceptance.md同号；010文件原语部分交付不关闭其原AC |
| canonical owner | src/cell.cj与src/frame.cj；必要纯函数在frame_composition.cj，不建立平行Cell/Frame/宽度/编码类 |
| 旧路径 | 现有blankCell/clearAt扩展默认透明参数和预算，旧public方法保留并共享；不保留第二组旧compositor或复制Unicode算法 |
| compatibility | 设计明确新正面积预算合法域及零面积历史极值兼容；旧字节/断言保留，不为测试改契约。无已发布schema迁移或用户数据删除 |
| complexity delta | Cell一只读透明位，Frame默认空白/预算常量状态，合成必要局部/自重叠读取快照；不为每单元重新分段，不增加持久投影缓存 |
| skills / evidence | 主代理已实际读取cloud Superpowers using/brainstorming/writing-plans/SDD/preflight；阶段角色按TDD、systematic-debugging、review、verification调用；用户CangjieSkills固定277f2e1与rules40bacab沿用AGENTS14；实际语言以SDK1.2优先 |
| tools | 已有SDK/node/OpenSpec可用；独立test旧产品正常build0。新registry relay18973仅开发环境；无新产品依赖/安装/权限需求 |
| risks | 旧零面积轴预算冲突已裁决；越界宽簇/自身快照/文件实际写失败由独立golden覆盖。支持重载/身份/交互不在本变更 |

DQ复核：目标/输入/输出/可观察AC及具体文件已齐；每角色范围独立、005与007共享同一必要代码周期而不重复内核；010/全部Linux明确排除。风险与兼容处置见上表，状态/AC单一权威见docs/tasks与acceptance。本批在契约独立复核通过后ready，后续按固定测试准入产品实现。

| preflight task / interface | 检查与裁决 |
| --- | --- |
| 067 self | 手算网格和真实文件字节/失败；不调用产品compositor产生golden；保留旧empty极值断言 |
| 005/007 self | 同一Frame/Cell扩展，预算只正面积；copy/resize与composition使用同一规范，无冲突实现路径 |
| 068 self | 完整BASE至目标diff，不读作者推理；双verdict与具体反例，无重复全suite |
| 069 self | 审核固定SHA、实际exit和包源码边界；只跑受影响回归与新case，最终release不足如实记录 |
| 070 self | 代码/原件/副本hash/有限AC与metadata，不能复制局部pass成全阶段pass |
| 067→005/007 | 签名、零面积/预算/宽簇片段及文件策略完全以同一design为准 |
| 005/007→068→069 | 固定产品提交/技术diff后审核，审核通过后独立执行，修复只反馈相应作者 |
| 069→070 | 原始stdout/stderr/实际exit/受检SHA/hash交接；文件复制及状态投影有独立核对 |
| 本变更→018/031/010 | 帧原语独立交付；实际层/动态/M2消费同一类型，010父AC等待后续真实可见层汇合 |

### DQ逐项结果

受检范围为本变更当前设计/任务及转移映射；规划版本为31a7017之后本次未提交合同，独立复核固定文档hash后提交。此表核规划和067准入，后续角色仍等各自前置固定产物，不把未来执行依赖记作已交付。

| 检查 | 结果/依据 |
| --- | --- |
| DQ-01 | pass：代码项为稳定L3 005/007，L1/L2与总计划只组织 |
| DQ-02 | pass：067测试、005宽簇不变量、007合成、068审核、069执行、070验收各有独立结果；005/007共享必要同一Frame代码而非平行实现 |
| DQ-03 | pass：shared admission、design精确签名、Interfaces/L4和原AC/新增AC字段齐全 |
| DQ-04 | pass：只扩展Frame/Cell及文件原语，010应用层捕获、状态/主题/输入均排除，影响旧合法域和零轴兼容明确 |
| DQ-05 | pass：透明/空格/负偏移/半簇/selfcopy/文件错误/预算均有可判期望，具体独立golden由067交付 |
| DQ-06 | pass（规划及067）：无图环，R8–R10现有输入及精确合同可用；005/007执行等067冻结，068等产品，069等审核，070等原始执行，不提前越门 |
| DQ-07 | pass（当前范围）：REQ004/005帧原语映射005/007与070；010父AC/018/031/全Linux远期明确待验 |
| DQ-08 | pass：Frame/Cell唯一；测试/产品目录隔离，005/007同一作者同提交审核，原重叠方法扩展无第二内核 |
| DQ-09 | pass：067→实现→068→069→070及后续018/031/010接口/汇合责任明确 |
| DQ-10 | pass：标准File.writeTo已有实际消费者证据，SDK命名默认参数已验；零轴冲突已按F001改规格，关键未知未藏为代码前提 |
| DQ-11 | pass：每角色具体文件、输入、命令/退出、提交和独立核对步骤可检查 |
| DQ-12 | pass：docs/tasks唯一转移005/007和067–070，acceptance原AC与新AC齐全；计划与已执行prepare分开 |
| DQ-13 | pass（当前规划/067）：执行分类/OpenSpec/已裁决F001F002明确；[技能来源与可用性](../../../docs/reviews/R11/skills.json)、[实际读取/角色记录](progress.md)定位；后续角色按其任务实际调用，不把安装当使用 |
| DQ-14 | pass：canonical_owner、旧blank/clearAt路径、合法域兼容、复杂度/开销和例外均有定义；不替换第三方/持久用户数据 |
