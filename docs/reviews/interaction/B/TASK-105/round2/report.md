# TASK105 round2 独立复核

固定 `5b08e34..62039552a26da295dcd710d7cfc40cb9e43ca5fd`，仅3个产品文件。**Spec PASS / quality PASS**；无新增 Critical/Important。

| 项目 | 处置 | 依据 |
|---|---|---|
| I05 残留 | ADDRESSED | 已稳定但未layout时 `measuredLayout=None`，不再用旧extent即时拒绝；固定回归实际无错误、content13、offset9、`jklm`。既有最终域/负坐标验证仍保留。 |
| I08 | ADDRESSED | 最终测量继承仍参与分配的自然+宽约束依赖；rows2→3后snapshot与M1均 `C/C/C/T/空`。 |

新依赖集合的替换、去重、容量检查、版本复核和dispose清理已核；仍是同一measure binding，未合并paint依赖或创建逐帧订阅。其余六项与NR结论沿用封存审查；M01继续明确deferred024。合并原完整审查及两轮修复，固定620源码门禁无未闭合C/I。

固定测试39ccddf与产品/rootb89beca对应目录byte-diff0。聚焦原件（2026-11-11T12:01:54Z）普通build及九个独立selector均0；200个tracked输入对620零差异、postcheck全部OK/0。普通B全入口（12:03:05Z）exit0。mandatory bundle（12:02:26Z）exit0，179个tracked输入匹配、postcheck全部OK/0。警告原件保留，未把bundle的空测试计数当功能覆盖。基线RED manifest hash仍为3550a63a…；旧round1封存hash未变。

原件路径/UTC/exit/逐文件SHA见 `evidence.json`；源/test/contract/diff hash见 `reviewed-hashes.json`。没有重跑旧套件、复制旧raw或新增probe。本结论是限定源码审查；A回归仍按交接记pending，最终clean消费及fresh执行准入由后续角色完成，不能据此宣称全发布验收通过。
