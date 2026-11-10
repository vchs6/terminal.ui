# TASK-069 独立执行报告

受检固定版本：`5c2a7e7d956b5d8c0284e96514276608616bf8a6`。独立 checkout：`/workspace/work/frame-execution/repo`。最终审核输入：`/workspace/work/frame-review/recheck-f003.md`。本角色未改产品或冻结 tests、未派子代理；tracked diff 为空。新增均为独立执行目录中的取证脚本、临时消费者与生成物。

**有限执行结果：新 composition、文件字节、正常 bundle、解包 build/check 和普通包消费者均通过。完整 release 未通过：原完整包检查器实际 exit 1，缺少后续 `examples/composition/cjpm.toml`。** 不将该增量外推为整个 Linux、应用可见覆盖层或 TASK-010 关闭。

## 实际执行

| 入口 / raw 前缀 | 实际 exit | 结果 |
| --- | --- | --- |
| `cjpm build` / `raw/root-build.*` | 0 | 正常根构建 |
| `cjpm check` / `raw/root-check-after-build.*` | 0 | 原生库生成后正常检查 |
| `bash -x tests/composition/run.sh` / `raw/composition.*` | 0 | 正常 public consumer，150 native PASS + 15 external verifier PASS，0 FAIL、0 SKIP |
| `cjpm bundle` / `raw/bundle.*` | 0 | 未传 skip 参数；实际执行构建、测试与 mandatory lint；测试汇总 TOTAL 0，lint 保留 145 条 warning |
| 原 `node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp` / `raw/full-bundle-check.*` | 1 | `Incomplete product bundle: examples/composition/cjpm.toml`，未修改或弱化检查器 |
| 实际制品源码/清单审计 / `raw/package-audit.*`、`raw/implemented-package-audit.*` | 0 / 0 | 62 个普通文件均等于固定源码；所有 manifest 及递归 dependency tables 核查；内部路径不逃逸、根依赖来自中心仓 |
| `tar -xzf` / `raw/package-extract.*` | 0 | 解包实际 `.cjp` |
| 解包后 `cjpm build`、`cjpm check` / `raw/unpacked-{build,check}.*` | 0 / 0 | 正常构建、检查，不复制根制品或 native archive |
| 冻结源码公共包消费者 / `raw/public-consumer.*` | 0 | 150 native PASS + 15 external verifier PASS，0 FAIL、0 SKIP |

两次直接 binary 均通过 runner 中的 `timeout 30s .../bin/main` 执行；未透过 `cjpm run` 掩盖状态。冻结 runner 的下一条 verifier 命令在 bash xtrace 中记录 `previous_exit=0`，verifier 为 set-e runner 的最终命令，实际 wrapper exit 0。分别详见 `raw/{composition,public-consumer}-direct-status.json`、原 stdout/stderr。该 JSON 明确标明状态来自实际 shell trace，不是作者自报或另一次未运行的命令。

两次文件原件目录：`artifacts/run.80htWDRC`、`artifacts/run.sFSi63rl`。runner 实际变量为 `CJTUI_COMPOSITION_ARTIFACTS`，随机创建全新目录，预先填入 1024-byte 文件与预算 sentinel；冻结 verifier 独立使用字面 UTF-8/SGR/CUP 字节检查创建、替换截断、空输出、换行、颜色、透明扁平化、预算前不打开文件。实际 `/dev/full` 存在，两次均通过 plain/ANSI 真实写入失败传播断言。

F003 通过默认完整入口执行，不只运行 focused 模式；覆盖 opaque 默认 Frame 的 clear 透明孔在 copy/resized 中保存、与底帧叠放结果、新区域默认空白及独立所有权。旧合成宽簇、裁剪、自身重叠、极值、预算/零轴等冻结案例也同时运行。

## 正常包消费者与制品边界

`public-consumer/tests/composition/src/` 是固定 tests/composition/src 的精确副本，`raw/public-consumer-source.diff` 为零字节。runner、verify-files.mjs 精确相同（`raw/public-consumer-harness-equality.sha256`）。唯一 manifest diff 在 `raw/public-consumer-manifest.diff`：`cjtui.path` 从 `../..` 改为 `/workspace/work/frame-execution/unpacked/cjtui-0.0.0`。未编写新 cases，未添加私有 FFI/link/compile 参数。

包原件为 `repo/target/cjtui-0.0.0.cjp`，摘要 `raw/package.sha256`。`raw/package-entries.txt` 保留 tar 实际文件类型列表；`raw/package-audit.json` 保留每文件 hash/source equality 和所有原 manifest。`raw/implemented-package-audit.json` 保留递归依赖表核对，明确只审本次已实现条目，不取代失败的全量 checker。根 central 依赖为 ansies 1.3.113、unicode 0.1.0、unicodewidth 0.1.113，传递 bitarray 0.1.0；三个已交付示例的 cjtui 路径仍指向包根，无新增产品依赖。未把 `.cjp`、ELF、缓存或 target 复制至 main。

## 五项旧回归按内容复用

| 原 raw | 原实际 exit | 原 PASS 数 |
| --- | --- | --- |
| contract | 0 | 109 |
| coordinates | 0 | 2 |
| colors | 0 | 1944 |
| layout | 0 | 114 |
| decoration | 0 | 59 |

原件为 `/workspace/work/frame-implementation/{name}.{stdout,stderr,exit}`，本次副本 `raw/reused/`，逐文件 hash、PASS 数和依赖内容对比在 `raw/reuse-input-audit.json`。这里只复用有效先前执行，**没有声称本角色重跑五 suite**。layout 原有两条 unused-expression 警告保留。

复用依据：已审核原受检产品 `883444195725224985f29060253017432abaa7f3` 至最终固定 SHA 的五类 tests、cjpm.toml、build.cj/native 路径完全无 diff，证据 `raw/regression-inputs.diff` 为空；旧 put/fill/border/shadow/export、颜色/布局路径不受 F003 影响。唯一产品源改变 `src/frame.cj` 的 copy/resized 改用共享 transfer 保留透明位；composite 仍固定跳过透明，不透明簇与原路径保持，具体 patch 为 `raw/f003-product.diff`。新受影响行为由本角色新完整 composition 独立覆盖。

相关环境/依赖亦核查：原 raw compiler/manager 为 SDK 1.2.0、x86_64 Linux，与本角色 `raw/versions.*` 一致；使用同一环境 SDK 路径。原作者私有缓存与本角色 seed 私有缓存的依赖 `.cj/.toml/.c/.h/.S` 输入逐文件 hash 完全一致（忽略 target/config），不是仅比较版本号。两边 `native/libunicodedata.a` hash 同为 `96f0552e197c0f02a7860f13cd0174617df639315252221828785103628e0c03`，UCD 摘要已保留。registry 配置仅私有缓存绝对路径不同，relay 同为 18973；该差异不改变受检依赖内容。未把作者报告或自评当作运行 verdict。

## 环境、可复现性与异常记录

SDK `/workspace/work/validation/sdk/cangjie/envsetup.sh`；cjc/cjpm 1.2.0；Node v24.22.1；GCC Debian 14.2.0；Linux x86_64。`raw/sdk.sha256`、`raw/environment-scope.txt`、`raw/versions.*` 留存路径、版本与必要变量。read-only seed 复制为本角色 `/workspace/work/frame-execution/cache`，每个正常 CJPM 项目使用 ignored config 与 relay18973。UCD 显式复用只读已验 zip；没有复制其他角色产品 target 或 native archive。`environment.sh`、`capture.sh`、`prepare-configs.sh`、`after-bundle.sh` 记录具体操作；每主入口 `.command/.cwd/.start/.end/.actualexit/.stdout/.stderr` 保留，全部 hash 见 inventory。

执行中有两项环境/调度失败，均保留且已正常补验：首次 `root-check` 在根 build 尚未完成时提前启动，native `unicodedata` 未生成导致 exit1；根 build0 后 `root-check-after-build` exit0。首次 `npm ci --ignore-scripts` 默认缓存 `/home/agent/.npm` 不可写，exit254；改用本角色私有 `--cache /workspace/work/frame-execution/npm-cache` 后正常 `npm ci` exit0，用于原 checker 的 smol-toml，不改 package-lock。失败记录未删除或替换。

## 有限边界

TASK-069 的本次 Frame/Cell 增量执行证据齐全，交 TASK-070 判定 AC 与元数据。不包含最终全 Linux matrix、真实 App-layer 可见覆盖层捕获、状态/焦点/应用 snapshot AC010、性能/物理内存极限、独立 close-failure 注入、其他平台或发布。原完整包 checker 仍失败，不声明 full release passed；本轮没有新增 GUI 截图，也没有用截图代替功能证据。使用了 `verification-before-completion` 的实际命令/证据门禁，依项目 AGENTS11 复用相同内容范围的有效旧回归。
