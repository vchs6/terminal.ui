# TASK-055 cleanup scoped independent review

结论：**spec passed；quality passed**。本次固定增量没有未解决的必修发现；`findings.json` 为 `[]`。这仅是 TASK-055 本增量代码/测试审核结论，不代表 TASK-056 标准 bundle、clean 消费或 TASK-057 最终验收通过。

## 范围与独立性

- 固定版本：`40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940`；fresh clone：`/workspace/work/cleanup-scoped-review/repo`，detached HEAD，工作树干净。
- 基线：`dabd`。完整阅读指定技术 diff `/workspace/work/cleanup-technical-review.diff`，其内容与本地 `git diff --unified=10 dabd HEAD -- src tests openspec/changes/implement-layout-decoration/design.md` **逐字节相同**；SHA-256：`919094a488182162faac9b9fe1dfcb6d00aa5fecf73d70e50f0dc9e964a2face`。
- 已读 AGENTS、D027、Pack-blocker task card、REQ-004.7、架构会话恢复与 Battle 证据要求。执行型只读审核；没有代码/测试编辑，没有子代理，没有读取实现作者报告或推理。复用原始日志/制品，不以作者自评作判断。
- 使用 requesting-code-review 的独立 reviewer 检查表与 verification-before-completion，并读取本仓 OpenSpec explore 技能，使用已安装 OpenSpec 1.14.3 入口检查既有变更。验证按 AGENTS §11.1 和本次任务指令复用有效记录；未重跑同套 TASK060。
- 预算：最多 3 次定点修复复核/60 分钟；本次 1 次审核，无新修复回合。

## Spec 核验

| 绑定契约 | 源码/证据 | 判断 |
|---|---|---|
| finally 不 throw；取得所有权后 cleanup 恰一次 | `src/application.cj:18–24,73–78`：open 失败在 try 前抛出；成功后唯一 finally 设置 running=false 并唯一调用 close，无 throw。12 份 RED/GREEN close-record 均严格一行、real_result=0 | passed |
| 正常+closeOK 返回，正常+closeFail 报恢复失败 | `src/application.cj:79–88`；q-success/q-close-failure 的退出码分别 0/1，失败场景含恢复文本 | passed |
| 业务 Exception+closeOK 传播原对象/类型 | catch 将原引用保存为 `Some(error)`，成功恢复分支 `throw error`，没有新建/转换异常；callback-success 原始输出保留业务 sentinel。对象/动态类型由该直接重抛路径证明，PTY 本身只证明信息/退出码 | passed |
| 双失败同时保留业务 message 与恢复失败 | `src/application.cj:81–82` 拼接原 `error.message` 与 `terminal restore failed`；GREEN callback-close-failure 原始输出两个文本均存在，RED 对应原始输出仅恢复文本 | passed |
| openfail 不关闭别人会话 | open 的失败分支在 try/finally 外直接抛出，不能到达本次 close；native 所有权机制未改 | passed |
| 不改输入、渲染、native、公开 API/可见性 | 产品仅 `src/application.cj` 19 行增量；循环体及全部其他产品/FFI/构建/清单内容不变；没有新增公共符号 | passed |

SDK 不可恢复 Error 不新增可恢复承诺；没有新增 catch Error，原 finally 清理语义保留。双失败组合异常只承诺两个错误的信息，不额外承诺原动态类型或堆栈。

## TASK060 与质量核验

新增 fixture 只 `import cjtui.*` 使用 Application/Column/Text/onKey/stop/run；无 private import，无产品测试 hook。`cjpm.toml` 只在外部测试消费者设置 `--wrap=cjt_close`，`run.sh` 只构建本测试目录的 C object/archive，未替换产品 FFI、native 或缓存。

`close_wrap.c:7` 首先调用 `__real_cjt_close()`，之后才读取注入开关、记录 real_result，并在 real 成功时注入 -1；wrapper 没有自行恢复 termios。记录断言要求整份文件恰好一行，因此重复调用也会失败。真实恢复由应用退出后的 `stty -g` 与进入前的完整快照精确比较证明。

`pty.mjs:26–29,50–65,82–88` 直接执行编译出的真实应用，经 wait 保存状态并由 `script --return` 传递；正常/失败退出码和无强制信号分别断言。callback sentinel 不属于初始画面或普通输入，只由实际业务异常产生；业务与恢复文本分别断言，双失败不会因只保留其中一个而通过。每个模式的 assertion 失败后仍继续其余模式，最后以非零状态汇总。超时失败，SIGKILL 仅用于失败后的清理。

原 contract、coordinate、native smoke/session、integration、layout、decoration 测试路径与基线逐字节相同；run-slice 仅新增生命周期 mode 并追加到原 all 的末尾，没有删除/削弱旧断言或原调用顺序。无渲染/输入逻辑复制，无第二内核，无新增产品依赖。旧 finally throw 已直接移除，无兼容残留路径。新增两项局部状态分别保存业务失败与恢复结果，是四组合契约所需，未引入公共异常层或无用抽象。

## 证据与检查

本审核重新读取并独立断言原始证据，结果记录在 [reuse-audit.json](evidence/reuse-audit.json)：

- RED：固定 checkout 内 `docs/reviews/R9/lifecycle-test/lifecycle-red.log` 与 `lifecycle-red-artifacts/`。六场景中 5 passed；callback-close-failure 明确失败在业务 sentinel 丢失，真实关闭一次和 termios 恢复仍成立。
- GREEN：`/workspace/work/application-cleanup-fix/logs/task060-green.log` 与 `/workspace/work/application-cleanup-fix/artifacts/task060-green/`。六场景均 passed；所有 result/termios/close-record/raw/stderr 文件逐一核验并记录 SHA-256。
- GREEN 执行 checkout commit `d8334844e462fe8377116f6b3f5d3cf82ac6abd6` 与受审 HEAD 的 `src native build.cj cjpm.toml tests` git diff 为空。GREEN 日志确认 Cangjie/cjpm 1.2.0；本审核也实际确认 SDK 1.2.0 x86_64-unknown-linux-gnu。上述结果只按同内容/同范围复用，不替代后续独立执行职责。
- 当前重新执行 Node 语法检查、bash -n、gcc C11 `-Wall -Wextra -Werror -fsyntax-only`、git diff --check、checkout clean 检查，全部 exit 0，记录 [static-checks.json](evidence/static-checks.json)。这是审核辅助检查，没有再次执行生命周期套件。
- 已读原正常 bundle 实际失败日志 `/workspace/work/application-cleanup-fix/logs/baseline-bundle.log`，确认 G.ERR.04 mandatory error 确实位于旧 finally throw。新代码不再有该结构，也未新增 suppress/skip lint 配置；本审核没有执行新版本标准 bundle，不能代签其通过。

## 明确留给后续职责的事项

- 标准 `cjpm bundle`（mandatory lint 不跳过）、源包边界和 clean 消费：TASK056 实际执行范围，本审核没有证明其最终结果。
- 新固定版本原 session/integration、实际 layout PTY 的独立执行与最终元数据：TASK056/TASK057，不能由本报告代签。
- 既有完整 425 布局/装饰/组织路径：此前独立整片审查已经覆盖，且本增量无相关变更；按本次明确范围不重新审核全项目。

没有将 D027 所列任何行为排除在本次代码/测试审查之外，也没有因预算或测试绿色而忽略具体反例。本次未发现需要额外临时 probe 的新反例；没有扩大验证范围。
