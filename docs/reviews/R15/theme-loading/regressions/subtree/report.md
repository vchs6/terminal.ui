# TASK089 mounted-subtree candidate validation regression

Test-only `71f9312e528c456bbcd929470dae41b69dc6f9dd` (BASE `0d94a6500c0f916ac76d59e5c23443888690e837`)；单atomic_caches.cj追加42行，原49行root-only/有限大min合法控制及全部旧断言保留。独立replay固定 `4971528013f89f5ec00fac7d5f0c41a693fb2ee8`，仅测试overlay。

实际命令，cwd `/workspace/work/theme-load-actual/replay`：
`./tests/theme-loading/run.sh all --case atomic-caches --logs /workspace/work/theme-load-actual/subtree-regression-raw/atomic-caches`

gate-build、foundation普通build/directrun、async-api-build、consumer-build全部exit0；atomic-caches直接binary exit1。完整argv/cwd/UTC/productSHA/exit及纯stdout/stderr在subtree-regression-raw/atomic-caches/commands.jsonl及同名文件。

旧有限viewport大min合法候选Applied/可见/活动控制通过。原root-only Max×0路径现实际Failed(InvalidCandidate)、MinimumBase/0/0、post=true、ref=true，旧帧/状态/getter/mount保留断言全部PASS。

新最小Row顺序严格为：有效root snapshot(Max,0) → loadTheme(Prepared相同Max min/weight1候选) → render(mounted Text,1,1)触发提交 → root snapshot(Max,0)。实际subtree导出1×1成功后result=applied:1/info=SubtreeCandidate，再root snapshot抛minimum sum overflow，post=false/ref=false，违反T008的先Failed保旧/会话继续要求。正确预期来自合同，不从观测坏结果生成；没有巨型正面积分配、第二renderer/private hook或另测render→load次序。

本次实际失败为运行期T008断言，非compile/SDK/fixture错误。其余21case未执行；原atomic其余用例因新回归失败未到达，旧预期源字节原样保留。不重跑旧全suite/大矩阵，不扩Column正式case（同共享入口已有独立审核纯probe事实）。根源修复及最终090 scoped review由root统一批次处理，无新资产审核/归档。

复用原SDK1.2/stdx/自有cache/registry18973；纯source/raw只读来自获准review probe，没有产品作者报告/自评或通信、无子代理。原report/raw均保留。TASK098安全暂停进度在 `/workspace/work/interaction-a-tests/final/progress.json`，此紧急回归收尾后恢复098。
