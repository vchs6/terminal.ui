# SDD ledger — plan: openspec/changes/implement-frame-composition/tasks.md

全阶段目标与连续调度由 docs/linux-completion-plan.md / openspec/linux-completion-progress.md 协调；本日志只记录当前具体增量。

BASE31a7017。主代理拟定具体帧契约，/root/frame_contract_review（Sol/high）首轮提出S1预算/零面积兼容、S2文件语义、P1准入记录、P2 AC映射四项，均属可自主修正，无用户问题。测试作者独立prepare指出旧decoration的Frame(0,Int64.Max)用例；主代理核源码84–88确认，绝不改弱旧断言。初始设计/计划副本保存在该计划scratch contract-before。

Ruling F001：maxCells只限制正面积总单元数，保留零面积极值构造/空操作，零宽纯文本以height-1的实际输出长度事前预算；不同宽度策略先校验再零面积短路。默认1Mi单元为1024²容量政策，有可配置取舍，不声称已测内存/FPS。Ruling F002：文件create/truncate、无自动parent、标准异常传播、失败可留部分，不承诺原子替换。

主代理补齐shared admission、preflight逐角色/接口、AC067–070、005/007唯一状态转移。当前待独立复核ready；/root/frame_test_author已在独立clone/cache完成旧产品正常build0，尚未写最终tests或产品，等冻结SHA。框架自身代码未改。

独立契约定向复核 spec READY / plan READY，S1/S2/P1/P2全部关闭，原报告与recheck归档docs/reviews/R11/frame-contract。DQ14项/skills实际source receipt已定位。067可开始独立冻结tests；005/007仍等待067固定RED产物后编码。
