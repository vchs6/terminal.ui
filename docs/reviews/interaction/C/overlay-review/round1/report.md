# TASK-110 Round 1 限定 delta 复核
`61e4de9d5c9d2681ea94242f0ffe64f2fd7fafef` → `f8f0493a7f5aa3b74bd59bdc7e6d82af6696426d`；仅五产品文件修复及原10项，不扩展未修改区域。
**原 C-I01–10 全部 ADDRESSED；本轮新 Important 2 / Critical 0；规格 FAIL、质量 FAIL。**

| 原项 | 本轮状态 | 核对 |
|---|---|---|
| C-I01 | ADDRESSED | 普通owner及完整附层闭包先撤销，cleanup/post反例已绿 |
| C-I02 | ADDRESSED | stable identity关闭If/ForEach退休owner附层 |
| C-I03 | ADDRESSED | hidden层不绘制，activeTarget拒绝hidden/disabled根 |
| C-I04 | ADDRESSED | ensure后重算当帧host/anchor，离屏层AnchorGone |
| C-I05 | ADDRESSED | candidate纳入实际overlay布局；preview不调用用户Canvas measure/draw |
| C-I06 | ADDRESSED | overlayRoot不进入普通parent权重合计 |
| C-I07 | ADDRESSED | 显式根host入口被接受；新几何问题另列下项 |
| C-I08 | ADDRESSED | 提交前复用host/anchor关系检查 |
| C-I09 | ADDRESSED | 依主代理裁定，以InvalidProperty在业务route前拒绝Passive |
| C-I10 | ADDRESSED | 纯render用当次LayoutNode几何，保持committed节点/viewport |

**R1-I01 Important — 焦点恢复新回归。** `runtime_session.cj:698` 在owner已撤销时直接令ancestor=None，跳过最近存活逻辑祖先。FIRST/OWNER/NEXT均focusable，focus OWNER→其Modal→删除OWNER：f8f恢复NEXT；同一公开consumer链接61e现有产物恢复FIRST。C.4要求先取最近存活owner祖先root的首候选FIRST，再考虑原物理后继。修复需保留撤销前必要祖先身份，在完整撤销后一次恢复；不得持久强留整树。
**R1-I02 Important — 显式根宿主被普通root盒限制。** `layout.cj:344–352` 对新增放行的root host仍走普通内容区分支。root固定1×1、实际Frame5×1，默认host得到`B P  `，显式root host得到`P    `。C.2根宿主内容范围为实际终端可用区；两种选择同一内建宿主应均得到`B P  `。非根host保留节点内容区裁剪。

证据：`round1/raw/fixed-final.run.stdout`（build/run=0）；`baseline.run.stdout`对照恢复FIRST（build=0，run=1仅因之后触及原显式host拒绝）；`round1/probe`为最小公开consumer，直接链接现有同SHA产品/依赖archive，无冷构建或正式套件重跑。早期链接/fixture设置失败保留，未当产品缺陷。
既有同源 `fix-r1-dev3` 的10 selector、X01/X02、完整C均0；`fix-r1-regressions` B、源码等价隔离runtime/theme均0，原registry失败1保留。复用raw与当前source哈希核对0差异，输入manifest SHA `71a28b0c04d49421587e2c5f686d153582214fe5fb1f98b0b30cd4d361feb66b`。
初审report/findings/raw manifest字节不变；详细定位、预期、源码原因和原始hash见本目录`findings.json`、`rawmanifest.json`。
旧B-M01仍deferred TASK024。mandatory lint/bundle/clean/真实设备由TASK111统一执行，尚不能宣称通过或关闭109/110最终完成metadata；后续只复核这两项修复delta。
