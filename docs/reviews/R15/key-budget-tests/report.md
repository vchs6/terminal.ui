# TASK085 T009 raw encoded key budget — 独立测试追加

Test-only SHA：`51986bb00457e400c5ad90d3284db6aa873d5530`。
BASE：`51a22fee9732a6d53affd05dd1eaa63e3d58ce2e`。
独立source：`/workspace/work/theme-key-budget-tests/source`，分支 `task085-key-budget`。
合同：canonical root design实测SHA256 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`，已完整读139、T009、T016及末尾key段预算澄清；没有将产品作者工作并入本分支。

结论：5个test-only文件、262新增行；完成固定输入/手写public Theme.parse用例及真实missing-Theme边界。**没有实际 escaped-budget行为RED/GREEN；151个新增输入对应的产品断言尚未执行。** 无需合同裁决的新冲突，没有产品/状态改动或准入结论。

## 追加范围

`generate_key_budget_inputs.py`仅构造源输入和校验字节算术。原 `generate_inputs.py`增加import及一个调用；原 `capacity_boundaries.cj`末尾只追加 `encodedKeyBudgetBoundaries()`，新实体 `key_budget_boundaries.cj`读取固定输入后调用真实公开 `Theme.parse`。原 `run.sh all`/正向gate/16负例以及所有既有断言不变，Glyph追加及四preset字节不变。新 `KEY-BUDGET.md`记录逐项手算与下游语义。

151新增输入：6种key位置 × 11种源拼写 × 1024/1025 =132；另8个合法style/variable名称资源对照、6个预算内语义等价、5个字符串值/注释对照。手写期望不由parser、guard或产品输出生成，没有fake Theme、声明stub、第二Lexer/Parser/decoder/normalizer或期望快照生成器。

| 拼写 | 1024原始payload字节 | 1025原始payload字节 |
|---|---|---|
| bare/basic/literal ASCII | 1024×1 | 1025×1 |
| basic/literal raw Unicode | 341×3+1 | 341×3+2 |
| mixed Unicode/ASCII | 170×3+514 | 170×3+515 |
| literal backslash-u0061 | 170×6+4 | 170×6+5 |
| literal backslash-U00000061 | 102×10+4 | 102×10+5 |
| escaped quote/backslash | 512×2 | 512×2+1 |
| quoted a.[{}] punctuation | 170×6+4 | 170×6+5 |

每种拼写覆盖ordinary/dotted/table/array-table/inline/array-contained-inline。1025全部要求CapacityExceeded先于Parser/schema；1024 generic键为UnknownKey，array-contained-inline的text数组为InvalidType(text)。这是资源预算放行，不误称schema PASS；不要求array-table这种schema不支持的形状成功。

styles/variables使用 otherwise-valid schema：直接103个a为合法103字节标识符；103次literal `\U00000061`拼写为1030字节而decoded103，先CapacityExceeded。102次长转义+4个a为原文1024/decoded106，要求实际成功Theme和typed rule查询；+5个a为原文1025/decoded107，先CapacityExceeded。都不依赖触碰128字符name上限来区分资源门。

其余语义控制分别核对bare/literal/short-escape/long-escape/inline/table得到同一bold=true rule，1030字节转义值/1025字节literal值/1026字节Unicode值与两注释仍合法。源文件均<4096bytes，最大路径/容器只是少数层、声明极少，远低于1MiB/65536tokens/16384declarations/16path/16depth/4096variables/styles，避免其它资源上限遮蔽key预算。Quoted标点是单segment，不能误数为path或容器；旧注释token预算保留。

错误期望从合同转录：下游错误核decoded semantic keyPath；CapacityExceeded不要求guard解码keyPath，只核source、真实非空有界Rune范围与超长key源拼写重叠，并检查line/column与Rune offset一致。未自行冻结合同未规定的引号定界符range长度。

## 实际执行与未执行

环境：SDK/cjpm实际均1.2.0；source本父目录 `env.sh`，官方stdx沿 `/workspace/work/linux-build-recon/stdx-env`，UCD沿validation/replay-dependencies同父归档。自有cache从只读seed复制至 `/workspace/work/theme-key-budget-tests/cache`，忽略配置只复用已运行registry18973，未新开relay或借作者产物。SDK/二进制/CJP/CJO/cache/密钥不入提交。

| 实际命令/检查 | 结果与原件 |
|---|---|
| SDK cjc -v / cjpm --version | 1.2.0；raw/sdk.stdout、raw/cjpm.stdout |
| `./tests/themes/run.sh all --logs /workspace/work/theme-key-budget-tests/raw/theme-run` | **exit1**；raw/theme-run.*及theme-run/commands.jsonl |
| gate内普通 values cwd `cjpm build` | **exit1**；唯一错误缺 `cjtui.theme`，raw/theme-run/values-build.stderr |
| `python tests/themes/generate_inputs.py`、Python py_compile | exit0；所有输入生成/算术自检成功 |
| 独立 `verify_artifacts.py` | exit0；raw/artifact-verification.stdout，41旧生成文件不变+151新增 |
| git diff --check、bash -n run.sh、最终source/diff/hash核验 | exit0；raw/final-checks/ |

**未执行、不计PASS**：values二进制及所有新增Theme.parse断言、integration、16负向编译；它们被真实正向gate阻断。缺package仅证明API缺失，不证明任何escaped-budget产品行为失败；没有声明scratch运行。

普通root build按AGENTS11.1复用上次真实成功证据 `/workspace/work/theme-glyph-tests/raw/refresh-offline/commands.jsonl`。本次核实b3b24f8→本BASE的src/native/build.cj/cjpm.toml完全相同、SDK1.2/stdx/UCD/原依赖不变，见raw/root-build-reuse.json；不因测试角色目录变化冷跑整个根依赖。当前values missing-Theme使用本次自己的普通命令真实复核。上游40个公开Lexer固定探针事实由已接受合同输入提供，没有仅因角色而重跑；本角色独立手算22个payload边界，未声称亲自执行该40探针。

## 保留与固定

raw/source-preservation.json覆盖原63个Theme/Glyph文件：61个原字节相同；两个文件仅按明确追加片段恢复后逐字节等于BASE，因此全部旧assertion保留。raw/generated-preservation.json固定41旧生成输入及151新增hash；raw/key-byte-arithmetic.json固定每种payload1024/1025的字节/Rune算术；四preset及16负例在63文件inventory内原hash不变。raw/final-source-hashes.json固定5提交文件；raw/actual-source-equivalence.json核真实runner输入与最终提交源码相同。最终git工作树干净，产品/docs/openspec/status无差异。

本次属既有冻结合同内执行型TDD测试追加。复用已读verification/TDD流程、SDK事实优先与原仓颉工程约定；OpenSpec status/instructions apply只读现有change并关联TASK085，brief明确禁止修改正式状态。未派子代理、未读产品作者目录/报告/进度/自评，未与产品作者沟通。角色指定原Sol/high，实际serving配置不可核验。

交接只需要本test-onlySHA。产品预算实现应消费这些固定测试及已审合同；实际产品具备Theme后，独立执行角色运行原all gate验证行为。本文不提前关闭085/013/025或097后续准入。
