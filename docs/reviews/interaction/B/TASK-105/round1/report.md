# TASK105 round1 独立复核

固定 `252c5ad..5b08e34ded8d58b344706e8ffcf594225626f4b3`。**Spec / quality 均为 CHANGES_REQUIRED**：0 Critical、2 Important 阻断。原批次及M01延期原件未改。

| 原项 | 处置 |
|---|---|
| T105-I01 | ADDRESSED |
| T105-I02 | ADDRESSED |
| T105-I03 | ADDRESSED |
| T105-I04 | ADDRESSED |
| T105-I05 | NOT_ADDRESSED |
| T105-I06 | ADDRESSED |
| T105-I07 | ADDRESSED |

I05 的原同批增长回归已通过，但队列清空不代表几何有效：`snapshot(4,1) → batch(extent=13) → batch(ensure rect12)` 仍错误报 `InvalidProperty`；随后真实布局content13、offset0。定位 `node_ref.cj:93` / `runtime_session.cj:573`。

新增直接 delta **I08 Important**：`layout_node.cj:178` 的最终有限高测量再次调用 `trackConstrained`，丢失仍用于父分配的宽约束测量依赖。公开 Canvas 分支读取rows，rows2→3后snapshot仍 `C/C/T/空/空`，完整M1为 `C/C/C/T/空`。违反A.2及R004。精确输入、原因和最小处置要求见 `findings.json`；两项共用实际 `raw/run.stdout`，普通SDK1.2 build/direct均0（2026-11-11T11:53:40Z运行）。没有内部hook或手写布局替身。

NR前提修复本轮 **ADDRESSED**：数值非拥有句柄、活动代际index、发布/退役/卸载/异常close撤销及session/index锁序已检查；原guard、UI线程nonce、owner-token有效性链保留。固定controls及观察GC后lookup、fresh进程500getter循环均实际0，baseline758的iteration96 RED保留。M01继续deferred024。

输入与复用：四个固定测试目录dc0b102/7589521/69232b9/f57d72a均与产品和root198cc24逐字节一致。原七项聚焦回归均GREEN；NR/B聚焦各199个tracked输入、A196、普通bundle179均对固定Git hash零差异，postcheck均0。B全入口及device记录exit0、共同binary hash一致；设备raw wire未在本轮重新作fresh准入。全部证据按原路径和SHA引用于 `raw/external-evidence.json`，没有复制旧raw。原输入目录不提供独立完整argv日志，未补造历史命令；固定入口脚本已源审。

仅为两个具体风险执行最小consumer。首次probe在batch外捕获业务错误，随后snapshot遇SessionInactive退出1；第二次修改出现consumer自身mutable capture编译错误；均保留原始源/输出，最终用Box及batch内捕获后build/direct0。产品153个tracked源码/构建输入对固定Git一致、前后无修改；隔离worktree不纳入交付。详见 `raw/probe-source-identity.json` / `probe-post-identity.json`。当前源码双verdict不等同最终package/clean/fresh执行通过。
