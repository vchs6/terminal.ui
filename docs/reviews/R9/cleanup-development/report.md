# TASK059 Application cleanup repair

当前阶段：TASK059产品修复已固定提交，作者必要TASK060自测完成；等待独立审核、执行和验收。

初始输入：`233f6542a039f86415213ec9f68069089ccb9d36`；TASK060冻结输入：`3bbfe7269274a0d4c0029e87ed2cd5bbdd1135e8`。独立clone `/workspace/work/application-cleanup-fix/repo`。绑定设计：`implement-layout-decoration/design.md` D-027，任务准入：同变更tasks.md Pack-blocker repair admission。分类为既定契约内execution；无公共API、依赖、输入、布局或native改动授权。

## Investigation / skills

已读取仓库AGENTS、产品提案/需求/架构/构造文档、D027、任务准入，并实际调用 systematic-debugging / test-driven-development / verification-before-completion 与用户cangjie-coding技能。OpenSpec apply使用现有implement-layout-decoration，原始状态与指令在 `logs/openspec-{list,status,apply}.json`，schema spec-driven，4/9已完成，TASK059/060仍pending。任务状态由协调者集成，作者不代替审核/执行/验收。

根因事实：`Application.run`成功open后finally直接throw恢复错误；SDK1.2.0正常bundle mandatory G.ERR.04拒绝该语句。finally中新异常也会覆盖原业务Exception。已有独立raw：`/workspace/work/layout-execution/logs/bundle.log`，可复用；本地提前发起的一次baseline bundle记录在logs，后续不重复。

语言查证：通过cangjie-coding `search_docs.py`批量查询Exception构造与message，然后按需读取精确活动叶子。Exception只有init()/init(message: String)，无cause构造；message为只读String。最小SDK1.2.0 probe `/workspace/work/application-cleanup-fix/probe/main.cj` 验证catch存入?Exception、finally记录close结果、之后throw原实例保留IllegalArgumentException类型，以及双失败消息构造。raw：`logs/probe-build.log`、`logs/probe-run.log`。这只是语言探针，不是产品回归或独立验收。

## Environment / commands

SDK：`source /workspace/work/validation/sdk/cangjie/envsetup.sh`；实际cjc/cjpm均1.2.0。

只读输入cache复制至 `/workspace/work/application-cleanup-fix/cache`；每项目ignored `cangjie-repo.toml`指向复制cache与relay `http://127.0.0.1:18972`；原cache未改。UCD输入 `/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`。

Probe命令：

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cjc /workspace/work/application-cleanup-fix/probe/main.cj -o /workspace/work/application-cleanup-fix/probe/main
/workspace/work/application-cleanup-fix/probe/main
```

结果：编译exit0；四组合输出中每项cleanup-once，正常成功返回，正常恢复失败报告恢复错误，业务失败/close成功保留原类型，双失败报告原消息及terminal restore failed。

## Frozen test RED / implementation / verification

固定产品提交：`d8334844e462fe8377116f6b3f5d3cf82ac6abd6`，父提交为冻结TASK060 `3bbfe7269274a0d4c0029e87ed2cd5bbdd1135e8`。仅修改 `src/application.cj`（16新增/3删除），测试、native、输入、布局与公共API无改动。保留预存未跟踪 `cjpm.lock`，未纳入提交。

实际操作顺序：冻结测试RED → 修改产品 → cjfmt → 冻结测试GREEN → diff检查 → 固定源码提交。

`Application.run` 保存业务Exception，finally仅置running=false并调用close/记录返回值；finally后分四组合处理。单业务失败重新抛保存的原异常实例；双失败构造同时含原message与 `terminal restore failed` 的异常。打开失败仍在try前退出；不可恢复Error不增加可恢复承诺。

原始命令（从独立repo目录运行，RED/GREEN仅更换artifact目录和log文件名）：

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
export CJTUI_LIFECYCLE_ARTIFACTS=/workspace/work/application-cleanup-fix/artifacts/task060-red
./tests/run-slice.sh application-lifecycle > /workspace/work/application-cleanup-fix/logs/task060-red.log 2>&1
# 实际exit 1：5 PASS；callback-close-failure FAIL，原callback消息不可观察。

cjfmt -f src/application.cj > /workspace/work/application-cleanup-fix/logs/task059-format.log 2>&1
# 实际exit 0。

export CJTUI_LIFECYCLE_ARTIFACTS=/workspace/work/application-cleanup-fix/artifacts/task060-green
./tests/run-slice.sh application-lifecycle > /workspace/work/application-cleanup-fix/logs/task060-green.log 2>&1
# 实际exit 0：6 PASS，failures=0。

git diff --check
# 实际exit 0。
git add src/application.cj
git commit -m "fix: preserve application failures after terminal cleanup"
# 实际exit 0，提交d8334844e462fe8377116f6b3f5d3cf82ac6abd6。
```

RED raw：`logs/task060-red.log`；GREEN raw：`logs/task060-green.log`；格式化raw：`logs/task059-format.log`。全部位于本report相同角色目录。每轮实际PTY输出、stderr、termios快照与close记录分别保留于 `artifacts/task060-red/` 和 `artifacts/task060-green/`。GREEN六项为q-success、q-close-failure、callback-success、callback-close-failure、ctrl-c-success、resize-success，全部验证一次真实close且返回0与精确termios恢复。注入close失败项仍正确以非零退出。

测试树沿用冻结值：`tests/application-lifecycle` tree `0f9a304c7833e12ac6b3c44bf0239c117508d54e`，`tests/run-slice.sh` blob `da00cb668364411056eba63b148b321c9f748532`。格式化后产品文件sha256为 `c6f4853ca2131c45bd53008d57c9f5500fe121b12e7a0949ee3efc11b230d502`。

作者只运行上述必要060自测。完整正常bundle及受影响旧session/integration/layout PTY交由独立executor执行；本文不声称bundle、完整套件或独立验收通过。
