# TASK089 atomic candidate layout L4

Test-only SHA：`3040111ce5a9bf5f1c3108c0374c4fe697f8d0dd`，父提交指定BASE `85ac9c3e4bb547a0bb62ad59b06d4819d871514d`。
独立replay worktree固定产品 `797039d6da9df8d849d382aff52eeb2180ba31b8`，仅同一正式测试文件overlay，复用既有cache/env，无重复clone。

**实际行为RED已复现，没有compile错误。** 同一合法候选components.text.spacing.weight=1/min_width=Int64.Max：

1. 有限视口正向控制真实Applied(1)，snapshot(4,1)成功、可见a/Blue、post接受。没有将标量Max或raw最小值之和过大一概判为非法。
2. 独立Row app的baseline snapshot(Max,0)真实成功，不分配Max×positive。候选随后snapshot(Max,0)抛minimum sum overflow，但结果已为applied:1、info=CandidateMin/1/1、post=false、旧ref=false。
3. 正式T008断言要求先Failed(InvalidCandidate或对应OutOfRange)、旧MinimumBase/0/0及帧/ref/state保留、session继续，无getter/mount重放；实际在“候选不能先导致layout throw”断言退出1。后续保留性断言已编码，未冒称失败后也继续通过。

仅consumer/src/atomic_caches.cj追加49行及一处调用，放在原atomic子组开头；原函数字节、全部其他资产和22case索引保持。原atomic其余断言因新增回归先失败而未到达，其余21场景未执行。没有新矩阵、private hook、fake worker/renderer、产品/合同/状态改动或额外资产审核/归档。

实际命令（source原env.sh，cwd replay）：
`./tests/theme-loading/run.sh all --case atomic-caches --logs /workspace/work/theme-load-actual/layout-regression-raw/atomic-caches`

Normal gate C build、foundation build/directrun、async API build、consumer build全部exit0；仅atomic-caches direct binary与runner为exit1。controller记录binary exit1，stderr明确为T008合同断言，非SDK/shape/编译失败或超时。新用例入口前的有限大min合法控制全部实际PASS。

精确argv/cwd/UTC/productSHA/exit/stdout/stderr及handshake见layout-regression-raw/atomic-caches/commands.jsonl等；最关键事实为atomic-caches.stdout中的OBSERVED行，栈见同名stderr。pre-run source/env hash、旧源保留、实际执行/最终提交一致性及manifest均在layout-regression-raw。普通未改代码/SDK/基础设施事实沿AGENTS11.1复用，不跑旧22全suite或host矩阵。

依formal T008/design§7独立给正确期望，读取的review材料限获准纯public probe source/raw，不读实现者报告/自评、不通信、不派代理。先前TASK089 report/raw原件保持；产品修复等待root统一090批次，最终090 scoped fix review一起核本补充和实现，不新增独立审核轮次。
