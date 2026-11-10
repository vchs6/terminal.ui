# TASK063 独立最终 Auto 执行证据

执行模型：GPT-6.1 Sol / medium。未派子代理；未编辑产品或冻结 tests；未读取产品作者分析/自评报告。工作分类为已冻结契约的执行型验证。本轮使用 verification-before-completion 核对实际命令与退出码；按 AGENTS 11.1 复用内容不变的有效证据。

结论：所执行的有限 Linux 产品切片、正常 bundle、归档解包/公开消费、两种真实终端实现的 fixture 与普通 demo 均有成功命令证据。**完整 release archive checker 实际失败，不能宣称完整发布通过**。Linux console、tmux/screen 无真实宿主，保持 pending / insufficient_evidence；此处不替控制器/独立接受者裁定上层任务完成。

## 固定版本与复用边界

- 阶段 A：`ead6a8d732c96fc108a52df3775dea8f84a84c59`；cold slice 与 bundle 在此独立 clone 上实际执行。归档 `stage-a-cjtui-0.0.0.cjp` SHA256：`fe5c09e082012e83cfcfa38c194027b558b02c80596f1aad9e7d032c71c63f95`。
- 阶段 B：`bf308bfccb43d0e88305c6d0ec64b4a92adbc892`；真实 GUI 两组矩阵在此执行。执行前直接比较阶段 A/B 的 `src/native/build.cj/cjpm.toml`、slice runners/tests、所有产品归档 include 路径，`git diff --exit-code` 实际 0。见 `raw/stage-a-b-reuse.{meta,log}` 和 `raw/stage-a-b-changed-paths.txt`。变动限于终端测试入口/退出 oracle 与开发记录；产品、slice 检查和制品源码未变。
- SDK、私有可写 dependency cache、ignored registry config、UCD、环境及对应检查范围未变。故阶段 A 结果可复用于阶段 B 的这些不变路径，不重跑 cold suite。阶段 B GUI harness 独立实际执行，不将 A 当作其证据。
- clean consumer 在独立 `unpacked/cjtui-0.0.0` 消费 **阶段 A 真实归档**，即使执行时间晚于 GUI，也未冒称为阶段 B 新制品。

## 命令、原始日志与退出码

每项完整命令/cwd/source/env scope/start/end/actual exit 见 `raw/<名称>.meta`，原始 stdout/stderr 见同名 `.log`。表中 UTC 时间为外层实际采集时间。

| 证据名称 | actual exit | UTC start → end |
|---|---:|---|
| `stage-a-cold-slice` | 0 | 2026-11-10T11:33:03Z → 2026-11-10T11:50:16Z |
| `stage-a-bundle` | 0 | 2026-11-10T11:50:21Z → 2026-11-10T11:51:11Z |
| `stage-a-full-bundle-check` | 1 | 2026-11-10T11:51:20Z → 2026-11-10T11:51:20Z |
| `stage-a-archive-audit` | 0 | 2026-11-10T11:51:20Z → 2026-11-10T11:51:20Z |
| `stage-a-finite-archive` | 0 | 2026-11-10T11:52:11Z → 2026-11-10T11:52:11Z |
| `stage-a-unpacked-build` | 0 | 2026-11-10T11:54:10Z → 2026-11-10T11:55:21Z |
| `stage-a-unpacked-check` | 0 | 2026-11-10T11:55:21Z → 2026-11-10T11:55:22Z |
| `stage-a-consumer-build` | 0 | 2026-11-10T11:55:33Z → 2026-11-10T11:56:22Z |
| `stage-a-consumer-check` | 0 | 2026-11-10T11:56:22Z → 2026-11-10T11:56:22Z |
| `stage-a-consumer-snapshots` | 0 | 2026-11-10T11:56:29Z → 2026-11-10T11:56:29Z |
| `stage-a-consumer-pty` | 0 | 2026-11-10T11:56:29Z → 2026-11-10T11:56:29Z |
| `stage-a-consumer-output-check` | 0 | 2026-11-10T11:56:41Z → 2026-11-10T11:56:41Z |
| `stage-a-b-reuse` | 0 | 2026-11-10T11:40:19Z → 2026-11-10T11:40:19Z |
| `stage-b-real-fixture` | 1 | 2026-11-10T11:51:33Z → 2026-11-10T11:51:33Z |
| `stage-b-real-fixture-bash` | 0 | 2026-11-10T11:51:52Z → 2026-11-10T11:52:52Z |
| `stage-b-real-example` | 0 | 2026-11-10T11:53:02Z → 2026-11-10T11:53:54Z |
| `stage-b-host-versions` | 0 | 2026-11-10T11:53:30Z → 2026-11-10T11:53:30Z |

`stage-a-cold-slice` 包含首次普通 build → check → CJPM test，全部既有 slice runner、colors/capabilities 与已引入 examples 的 build/check/test；子 executable 由 runner 直接执行并传播真实 exit。CJPM 自身报告的 TOTAL 0 保留原样；未将其当作独立 runner 的测试计数。布局编译及 bundle lint warning 均保留，不关闭或跳过 lint。

稳定 PTY 产物：`artifacts/colors`、`artifacts/capabilities`、`artifacts/layout`、`artifacts/lifecycle`。较早 integration runner 自己清理的临时成功会话仅有其原始命令日志；没有伪造已被清理的 raw 产物。

## 包与公开消费

正常 `cjpm bundle` 返回 0，包含其 mandatory lint；实际 `scripts/check-bundle.mjs` 对同一真实 archive 返回 1，错误为缺少 `examples/composition/cjpm.toml`。`benchmarks/rendering` 也未实现。未改弱该 checker，未声称全量 release 通过。

独立有限 inventory 记录归档 **62 个文件**、每项 size/SHA256/原源码 SHA；全部逐文件相同。正常 root 依赖表为 ansies 1.3.113、unicode 0.1.0、unicodewidth 0.1.113；三项原生 FFI 为 unicodedata/cjtui_terminal/cjtui_capabilities，均指向 `./native`。examples/minimal、layout、colors 使用内部正常 path 依赖。第三方许可附带 manifest 分开列出。未以整个 manifest 的 node 子串搜索代替 dependency table 审计。见 `raw/stage-a-archive-audit.log`、`check-finite-archive.py` 与 `raw/stage-a-finite-archive.log`。

解包后普通 build/check 均 0；外部 `consumer/cjpm.toml` 只有正常 cjtui path dependency，**没有私有 linker flags、消费者 FFI 声明或私有 API**。consumer build/check 均 0；直接 executable 生成 `artifacts/consumer-snapshots/snapshot.txt` 与 `snapshot.ansi`。验证 plain 无 ESC、包含中英文/emoji，ANSI 包含 RGB 与 bold/italic。真实 PTY 另存 `artifacts/consumer-pty/session.raw` 与 `pty-metadata.json`，实际 40×6 → 54×9 resize、q 退出 0、精确 termios 恢复均已断言。

## 真实终端矩阵

`artifacts/real-fixture-bash`：三 profile × q/exception/interrupt，9 行完整通过，外层实际 0。相同常规构建 fixture binary SHA256：`283224c0295a91e8d8fc0bb536919a1066d45ccd8af7dfc1c259e3f0110e407f`。

`artifacts/real-example`：未修改的普通 `examples/colors`，三 profile 各 q，3 行完整通过，外层实际 0。同一常规 binary SHA256：`fabfe6974113ef05c6e827c552978e89216f1e49b78d44e5541ead6b0f820a73`。逐 profile 原图保存 initial/red/gray/restored/attributes-off/attributes-on/resized；有真实 XTEST 键入及 resize、输出 drain 证据。不把普通 example 说成有 fixture ACK、能力诊断或 no-op oracle。

| profile | 实现/版本 | 实际 cell 初→终 | 实际窗口 pixel 初→终 | fixture Auto 检测 |
|---|---|---|---|---|
| xterm-default | XTerm(398) | 100×28 → 120×34 | 1004×536 → 1204×650 | Basic8, terminfo |
| xterm-256color | 同一 XTerm(398) 引擎的另一配置 | 100×28 → 120×34 | 1004×536 → 1204×650 | Indexed256, terminfo |
| xfce-vte | xfce4-terminal 1.1.4-1 / VTE 0.80.1-1 | 100×28 → 120×34 | 1017×561 → 1217×675 | TrueColor, terminfo+COLORTERM |

每行目录含原始 PNG（没有生成、重绘或编辑）、UTC capture time、scene/source/fixture/binary/harness SHA、原 ANSI、XTEST/resize 记录、精确 fence、inner/outer termios、host wait status 与 exit verification。`matrix-summary.json` 汇总 12 行但不替代原件。两个 xterm profile 只计为一个引擎；XFCE/VTE 为第二引擎。所有正常 q/interrupt 的 application/recorder status 为 0；exception 的二者为 1，host status 可为 0，验证未以 host 退出码替代应用退出码。

普通 demo 截图示例：
- `artifacts/real-example/xterm-default/q/example-initial.png`
- `artifacts/real-example/xfce-vte/q/example-initial.png`
- 同目录 `example-resized.png` 及其他阶段原图。

## 原始证据局限与补证

第一次直接执行 `tests/terminals/run.sh` 按其 `/bin/sh` shebang 进入 SDK envsetup，报 Unsupported shell: unknown，实际 exit 1，保留 `raw/stage-b-real-fixture.{meta,log}` 与空 capture 目录。之后显式 `bash tests/terminals/run.sh` 使用相同固定源码成功，未修改冻结 tests，也未覆盖原失败日志。

原 GUI metadata 内的 XFCE host_version 调用未带 DISPLAY，因此保存的是 Gtk cannot open display。原 metadata 保持不动。独立 `raw/stage-b-host-versions.{meta,log}` 查询实际安装包版本并 hash 测试 executable/VTE library；`host-version-supplement.json` 把该旁证、tested host 路径和 12 条原 metadata 对应起来。此补证不是重造原 capture 元数据。

无 Linux console、tmux/screen 实际宿主，相关范围未运行，不能记 skip/pass。测试 GUI/XTEST/捕获工具只用于验证，未进入产品依赖。

## Hash 与环境入口

- `stage-a-source-inventory.json`：阶段 A 产品、slice 与相关源码内容。
- `stage-b-harness-inventory.json`：阶段 B 终端 harness 与普通 example 固定源码。
- `dependency-source-inventory.json`：私有 dependency cache 内容。
- `execution-environment-inventory.json`：SDK/UCD、registry configs、测试 binaries、archive provenance/model。
- `host-version-supplement.json`：真实 host 版本/路径/binary/library SHA 及行映射。
- `SHA256SUMS`：报告、原日志、GUI/consumer 原始产物、执行辅助脚本和 inventory 的最终 hash 清单。

执行主目录 `/workspace/work/auto-final-execution`；环境入口 `env.sh`；命令记录器 `run-logged.sh`。工作 clone 独立、cache 私有可写，registry configs 均为 ignored 本地配置。无发布/上传动作。
