# Layout and decoration Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development; follow independent test→implementation→review→execution→acceptance. 用户已授权连续实施和main推送，不重复询问。

**Goal:** 用公开声明式API构造可运行、可缩放的终端面板。
**Architecture:** 单一measure/arrange/paint和Frame路径，布局框与阴影绘制扩展分开；复用R8基础。
**Tech Stack:** 仓颉1.2.0，既有三依赖、Linux ANSI，版本0.0.0。
**Spec:** design.md精确签名与算法；REQ003和现有ui-runtime场景；不增加新产品要求，skip_specs=true。

## Global Constraints

- 主代理只写契约/文档/集成；测试、源码、审核、执行、验收各独立上下文及目录，不交叉编辑；只共享冻结产物。
- 保留所有R8回归与真实binary退出；依赖/许可不重做，无JS/TS/Node/Python产品运行依赖。
- 不做其他OS、主题配置、响应式、编辑、滚动、层及M2；完整要求保留，不以本片冒充全框架完成。
- TASK011/012唯一状态转至本文件，源任务只留引用；原007覆盖层不是当前单帧装饰代码前置。

## Review Focus

比例余量/极值、祖先内容裁剪、宽簇被装饰覆盖、退化边框、阴影扩展不参与布局、背景unset与显式Default、旧影清除、无主动美化；测试预期来自design，不来自实现。

## 1. Test contract

- [x] 1.1 TASK-054：独立冻结layout/decoration消费者及回归、真实RED与runner；验收AC-054：缺新API时失败，正常/边界/错误及golden可执行，旧断言不削弱。

## 2. Layout

### Task 2: TASK-011 constrained layout

- [x] 2.1 TASK-011：实现固定/min/weight/padding/gap/alignment与Rect；验收AC-011：独立整数/窄屏/极值/旧行为测试，公共接口实际构建；完成后独立局部审核再进行装饰。

**Files:** src/component.cj与src/layout.cj（建议），必要共享Frame入口；产品布局说明。**Interfaces:** design布局表/Rect；既有render/Component/Frame保持。
L4：1.读取冻结测试并确认RED；2.实现一次measure/arrange/paint和安全几何；3.自测提交交独立审核，不改tests。

## 3. Decoration

### Task 3: TASK-012 character decoration

- [x] 3.1 TASK-012：共享Frame fill/border/shadow与Component链、layout示例；验收AC-012：独立golden/裁剪/宽簇/旧影清除，真实示例和共享路径，阴影不改变layout。

**Files:** src/decoration.cj及Frame共享入口、Component布局绘制接入、examples/layout及产品说明。**Interfaces:** 已交付Rect/layout与design装饰表，不能另建字符/屏幕内核。
L4：1.确认独立装饰RED；2.共享路径实现并接入布局树；3.自测公开示例和针对回归，提交固定版本交整片审核。

## 3b. User-directed source organization

### Task 4: TASK-058 package and entity files

- [x] 3.2 TASK-058：按D026整理产品包/源码，每类型单文件，保持公开API；验收AC-058：实体/文件/包声明检查、外部消费者和最终源码包均正常。

**Inputs/depends_on:** 最新用户约束、D026、冻结测试 / TASK012。**Deliverable:** style/geometry/text包和cjtui实体文件，根public import，说明；**Scope:** 仅源码移动/必要imports/可见性与格式，不改测试/native/依赖/行为。独立Sol/high（多文件包协作）实现，TDD/cangjie-coding/verification；先SDK probe确认包/可见性，再整理和针对layout/decor构建，最终055审核和056全量复用。旧混合定义同时移除，不保留平行路径。风险：重新导出/内部访问/制品子包；用原外部消费者与cjp校验。L4：固定源和包probe→单实体文件/包重排→公共消费者构建→提交整片审核；不新增产品功能测试。

## 4. Quality gates

- [x] 4.1 TASK-055：独立代码审核及修复复核；验收AC-055：契约/质量双passed，必需发现有实际反例和闭合版本。
- [ ] 4.2 TASK-056：独立执行完整slice、新示例PTY、clean cjp消费；验收AC-056：fresh实际退出、raw/sha完整，不采用作者自测。
- [ ] 4.3 TASK-057：独立合同验收及最终集成；验收AC-057：证据/源码/状态一致，技术源未变，完整项目未虚标完成。

## L3 cards / admission

所有行为/API已在design冻结；层级L3，父WP003（测试/审核/交付属对应支持WP），具体change=implement-layout-decoration。分类：011/012为已确认方向内工程细化execution；默认分配/退化规则为已记录工程决策D023–025。版本不变、无已发布API迁移义务；旧measure/draw由单一新路径替换，不保留两套内核；原生/输入不改。无需新增依赖。必要SDK/工具复用R8并由各角色核版本，技能实际使用记progress。

| task / type | inputs / depends_on | deliverable / acceptance | quality / skills / risks |
|---|---|---|---|
| 054 testing | design与c502基线 / 无 | tests/layout、tests/decoration、runner和RED / AC054 | 独立golden，不读作者；TDD/verification；SDK签名若矛盾先报主代理 |
| 011 implementation | 已验R8 Frame及冻结layout tests / 054、已完成050 | 单一布局实现/文档 / AC011 | 不反复度量、不绕过共享Style；TDD/verification；数值/窄屏见design |
| 012 implementation | 已审核011及冻结decor tests / 011 | 装饰/共享低层API/示例 / AC012 | 撤换旧draw路径，不复制Unicode/缓冲；TDD/verification；clip与透明见design |
| 055 verification | 固定code/tests/spec / 012、058（011另有局部审核） | findings/复核 / AC055 | 冷上下文，最多3轮复核/60min；request/receive-review及verification |
| 056 testing | 固定已审核提交 / 055 | 命令/实际结果/raw/hash/例子 / AC056 | 不改产品/测试；verification/debugging；未变结果按AGENTS11复用 |
| 057 acceptance | 固定源码与各独立交付 / 056 | 逐项映射和最终集成 / AC057 | 不复述数量代验收；verification；source和证据一致、剩余范围明确 |

054 L4：按contract写期望→真实RED→冻结提交；055 L4：固定diff→独立反例→作者修复后复核；056 L4：fresh clone→运行→原始交接；057 L4：核合同/raw/source→判有限范围→核最终元数据。所有必要前置/验收/技能/风险/质量及旧路径去向可定位，DQ01–14按该有限单一目标审查。任务实际状态仅复选框，不另维护状态表。
