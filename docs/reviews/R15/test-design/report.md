# TASK-085 独立基础主题测试冻结

测试提交：`74b1a5ac09804f2da4eda2aeafe1f45ad691f4b6`，直接父提交/正式合同：`5c150ec36bdbb275c722c970b7cc66ed6a4c8f36`。独立 clone `/workspace/work/theme-tests/source`，分支 `test/task085-foundation`。原合同 `d4a92238db8abe703f23d74bbbee18b4fbfbc7c4` 的 T001–T015 及四 fixture 字节保留，按新合同 T016 使用 `withValue` 并采用非EOF token/声明精确定义。

**已交付 test-only 固定产物和真实 missing-API RED；没有主题产品 GREEN、正式独立执行或原 AC 通过结论。** 47 个新增文件全部在 `tests/themes/`，没有修改产品、spec、任务状态或共享 run-slice。工作树干净。主代理后续顺序接线。

## 产物

- `values`：只导入公开 style/theme 的正常 CJPM 消费者；36 字段 literal/false（Bool）/Disabled/Reset/错型，逐键只读 name/value 原槽查询，typed equality/不可变/程序化数值校验；十变量类型/前向引用/17角色/所有命名色；schema 和首错误顺序、引用、重复 normal、未使用坏变量/样式、Int64 范围、Unicode Rune 诊断、只读桥、路径字面量和 UTF8。
- `integration`：公开 Application/Component/Frame/RichText 消费者；四来源逐属性、状态/后 named normal 优先、继承 root seed vs 子 role、三种背景来源和独立 fill Style、全部八个 span mask 字段及数值相等时 dirty、四边 padding、实际分配宽与自然高、零宽每硬行一行/oversize 独占裁剪行/CRLF/组合簇、ellipsis 整簇与垂直隐藏不提示、装饰与布局配置实际像素、数组防别名及实际 primitive 适用性。
- 四 preset 的文字/装饰/间距/命名/Modal/交互状态规则及两行 Frame golden 独立手算；输入 TOML 直接复制冻结设计字节，四 SHA-256 完全一致。没有用 SUT 输出生成预期。
- 16 个负向编译 fixture；runner 必须先真实构建并执行两组正向消费者。缺包/环境失败不会算负向通过，负向程序不执行。
- 源码生成器只构造恶意输入字节，不模拟 TOML；runner 记录 UTC、argv/cwd、受检 SHA、stdout、stderr、真 exit、源码和生成输入 hash。

完整矩阵、命令和明确限制见 `source/tests/themes/README.md`。SDK 1.2.0 正常 manifests 由 `cjpm init` 生成，只有普通相对 cjtui path 依赖；忽略的 registry18973/private cache 配置仅位于本作者目录。

## 原始验证

所有正式原始命令见 `commands.jsonl`。stdout/stderr 分开保存，无 `cjpm run` 隐藏退出码。

| 证据 | SHA / 实际结果 |
|---|---|
| `raw/fixed-contract-root-normal-build.*` | 最终测试提交 `74b1a5a`，普通根 `cjpm build` **exit 0** |
| `raw/fixed-foundation-missing-api-red.*` | 同提交，`python3 ../run.py negative --logs …/raw/fixed-foundation-runner` **exit 1**；唯一编译诊断为找不到 `cjtui.theme` |
| `raw/fixed-foundation-runner/` | 正向 gate 的真实 exit1，后续 integration 与 16 个负向编译 **未运行、未算通过**；含最终源码/生成输入 hashes |
| `raw/fixed-artifact-check.*` | **exit 0**：47 条路径仅 tests/themes、diff check、四 fixture 原字节/hash、Python/shell 语法、20 个 Cj 消费者与已静态编译源一致性 |
| `raw/value-name-query-declaration-static.*` | 外部声明-only scratch 的完整 values 源 **静态编译 exit 0**，包括 withValue/value/name 泛型形状；从未执行 |
| `raw/final-declaration-only-integration-static.*` | 外部声明-only scratch 的完整 integration 源 **静态编译 exit 0**；从未执行 |
| `raw/upstream-lexer-boundary-counts.*` | 真正固定上游 public Lexer：token 65536/65537；decl 16384/16385（各仅 49152/49155 token），var4096=53259 token/12291decl，style4096=20491 token/4099decl |
| `raw/upstream-lexer-comment-boundaries.*` | comment-at=65536 token，over=65538；70000 个括号的普通字符串仅 8 token；inline/array 小输入真实扫描 |
| `raw/generated-input-upstream-syntax.*` | 真正上游 Parser 对所选 at/combined/quoted 输入正常接受，**exit 0**；没有将万层深文件送入 Parser |

`static-source-equivalence.json` 明确最终消费者相对实际静态编译源只清理了缩进/未使用 import；没有语义变化。`artifact-hashes.json` 固定提交全部 47 文件，`declaration-only-hashes.json` 和 `lexer-meter-hashes.json` 固定外部开发材料。两类 scratch 均未进入测试提交；声明 scratch 无一次运行记录，不能当作实际公共 API 正常编译或产品运行证据。

保留初次 registry 配置错误及修正日志（原 default 节改为工作环境要求的 home 节）；它们不算 missing-API RED。也保留 SDK 对普通 `with` 声明/调用的真实关键字报错：`raw/declaration-only-values-static*.stderr`。正式名称已经主代理 T016 裁决修为 `withValue`，没有用 escaped alias 冒充原 API 可用。

## 边界

目前完整 Theme/preset/public API 尚未通过真实正常消费者编译；真实行为执行须等 runtime080、RichText084 和主题产品固定输入，独立执行/制品/原回归由087推进。本报告不是087/088验收。

当前无高层 ASCII/glyph override，按主代理裁决只冻结现有085公共范围：Unicode ellipsis 反例已准备；ASCII 自动降级分支等后续合法渲染策略子接口与真实 host 验证，不发明私钩或未来 API。

异步 load/reload、最新请求获胜、worker/UI事务属于089/026；完整控件四主题展示/真实宿主 PNG 属于027，均未算完成。

角色指定 Sol/high，实际 serving 配置不可核验。使用 TDD/verification 与固定 CangjieSkills 的 search_docs（查询追踪 `search-docs.jsonl`）；systematic-debugging 用于区分语法、环境和缺API失败。未读取产品作者分析，没有派生代理。
