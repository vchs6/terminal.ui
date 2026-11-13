# TASK-110 固定 C 覆盖层独立源码审核
BASE `fd2861747912f9778582ea3968c2be48cca296b5` → HEAD `61e4de9d5c9d2681ea94242f0ffe64f2fd7fafef`。
**规格 FAIL；质量 FAIL；Critical 0 / Important 10 / 新 Minor 0。** 全量有限源码审核已完成；详细位置、反例、预期及逐项双 verdict 见 `findings.json`。

| ID | Important 发现 | 位置 | 证据 |
|---|---|---|---|
| C-I01 | 删除普通 owner 时先执行附层 cleanup，owner 仍有效且可接受 post，未先撤销完整闭包 | runtime_session.cj:1035 | focused2：`cleanupOwnerValid=true cleanupPostAccepted=true` |
| C-I02 | If/ForEach 替换先撤销 owner，关闭逻辑跳过失效 owner，遗留有效 Modal 孤层 | runtime_session.cj:724；dynamic_group.cj:101 | focused3：`open=true contentValid=true cleanup=0 activeTarget=true` |
| C-I03 | overlay content 根 visible(false) 后仍画；reserved/modal activeTarget 也未检查有效可见/启用 | layout.cj:319；application.cj:166 | original：隐藏前后均 `BPB`，visible=false |
| C-I04 | ensure 滚动后仍采用之前缓存的 anchor/host 几何 | layout.cj:405、429 | original：offset=3，anchor离屏，层仍open且画P |
| C-I05 | 主题候选只验普通根布局，overlay 溢出在 Applied 后才终止 session | layout.cj:289 | original：`Applied / minimum sum overflow / Next / active=false` |
| C-I06 | 主题预检把 overlay 权重加入逻辑 owner 的普通孩子预算，合法主题误拒 | theme_candidate_validation.cj:28 | original：完全相同布局主题 `Failed / Old` |
| C-I07 | 默认内建根宿主作为显式 host 被错误拒绝 | runtime_session.cj:558 | original：`ROOT_HOST InvalidOverlayHost` |
| C-I08 | pending 开层后同 batch 撤销 host 能力，提交未复核仍挂载 | runtime_session.cj:621 | original：`REVOKED_HOST error=[] open=true` |
| C-I09 | 显式 dispatch 允许 Passive 成为键盘目标并调用 owner handler | application.cj:358 | focused2：`error=[] ownerKeyCalls=1` |
| C-I10 | 纯 render 导出使用历史 committed host/anchor 几何；首次 render 前这些值为零，遗漏已挂载层 | layout.cj:347、384、404 | 源码直接反例：start→batch开root锚定层→首次render(root,3,2)，未另运行 |

逐项：C.1/C.2/C.3/C.4/C.6/C.7、shared errors、T008 均 FAIL；C.5 的 surface/Frame/单 resolver 机制源码审阅通过，交叉事务缺陷为 C-I05/06。C-01–05 均有上述阻塞。
保留正确主链：单 Runtime/真实节点/ordinary children 隔离、owner事件路径、modal默认时序、共享 Frame/Unicode/caret、单 resolver 的 surface fill、实体独立小写文件；没有第二组件树、截图恢复或控件输入特判。
P05 已审闭合 record 传递引用：description/root 清空，owner/options/savedFocus/savedOrder 为数字 NodeRef，dispose解除全部 binding observers；**dispose 后弱拥有源码核对通过**，未把 GC observation 当确定性证明。opaque 构造器源码不可对外调用，现有外包构造失败 raw 相符。
原探针 `raw/probe-original-main.cj` / `raw/run.stdout` 的 product hashes 与固定 HEAD 一致；原 REVOKE 开错 owner，已弃作该项证据，用 focused2 替代。focused2、focused3 各 build/run=0，仅执行具体疑点，未重跑正式套件。
原纯 raw `c-formal2/c-device-final/bundle-final/clean-final/opaque-probe/export-probe-red2/export-probe-green` 只作已有证据；作者报告未读取。源文件与固定 git HEAD、现有 probe dependency 核对无差异，hash见 `raw/manifest.json`。
独立正式测试修正 2165212/b82e9d1 及新增 bcaf5c19849a44db9cea884d40d28ed102ab8c46（X01/X02）已纳入输入；681 的 red 不能当作61e执行结果，未重复运行；C-I10不等同X01的保留状态断言。
旧 B-M01（getter axes / onMount Off）仍 deferred TASK024，未宣称修复；TASK111/112、正常包与跨宿主验收不由本源码结论关闭。后续只复核修复 delta 与相关失败证据。
