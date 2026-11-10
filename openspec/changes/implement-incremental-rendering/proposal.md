# Incremental rendering and reproducible benchmark

## Why

当前Runtime保存分类dirty却在目标变化时重建全部LayoutNode、全树measure/paint；snapshot逐Cell复制与全帧diff继续消耗面积级工作。REQ-004.8与TASK-031要求真实局部布局/绘制并与完整M1相等，TASK-022要求正常公开制品中的可重复基准。仅减ANSI输出行不能满足该目标。

## What Changes

- 单一RuntimeNode持有约束/测量/分配/绘制缓存；现LayoutNode算法分measure/arrange/paint，M1完整临时结果与M2持久缓存共用同核。
- 分类dirty经依赖扩展，旧新bounds投影为整行damage；完整合成目标仅重绘相交节点与层，仍清残留、维护宽簇/透明/StyledSpace。
- 同一Frame私有冻结行COW，snapshot独立可变；后端以可靠行身份/lineage优化比较，未知来源正确fallback，008失败恢复与成功baseline提交不变。
- RuntimeStats原八字段义不变，仅增只读arranges、cellWrites、frameAllocatedCells生产诊断；最后一项为真实Cell存储槽容量累计，绝非字节或完整heap分配。
- benchmarks/rendering独立CJPM公开消费者，正确性配对与性能分进程，报告局部/全局退化的工作量、CPU、Cell存储分配、heap/GC/RSS和真实输出。

## Capabilities

- Modified: ui-runtime（局部计算与只读统计），terminal-output（完整目标的局部更新、行共享、后端安全比较）。
- Added: rendering-benchmark（公开制品基准、相等配对、可重复成本证据）。

## Impact

范围为Component/RuntimeNode/RuntimeSession的现有失效接缝、唯一LayoutNode/layout/Frame/后端和公开基准/产品说明；普通构造API保持，新增诊断属公开可观察而非测试hook。旧paint内布局、短命平行几何树、全量copy热路径及无条件全frame比较分别迁移/退役，保留正确通用慢路径。无第二组件树、Frame类型、Unicode/ANSI算法，无产品M1/M2开关、GUI、JS或终端模拟器依赖。

用户已授权完成全部Linux与可逆技术细化，本候选只固化已采用路线，不publish。最终前置产品SHA及M1完整功能基线待全部功能通过后、M2产品实施前冻结；缺这些输入时任务仍planned，不能把设计或微探针当产品PASS。完整责任仍回TASK-031/022及最终023/024，不另建状态权威。
