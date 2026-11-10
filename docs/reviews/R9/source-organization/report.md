# TASK058 源码组织实现交接

状态：实现已提交，可供独立审核和最终执行；此报告仅记录作者开发验证，不代替 TASK055/056/057。

- 独立 clone：`/workspace/work/source-organization/repo`，未读前作者报告/实现思路，未派子代理。
- 固定输入：`1dcf9693a57e1f77d02f5b9279462495c160dcf2`。
- 实现提交：`f79516f9865bdf71ea4c0ac578279f0b8d3877bc`。
- 契约：task-4-brief、AGENTS §14、`openspec/changes/implement-layout-decoration/design.md` D026。
- 修改边界：19 个 src 路径；未改 tests、native、examples、cjpm.toml、build.cj、依赖及算法/状态。Component 原已为单实体文件，保持字节不变。

## 实体与文件

| 包 | 类型 | 文件 |
| --- | --- | --- |
| cjtui.style | Color | src/style/color.cj |
| cjtui.style | Style | src/style/style.cj |
| cjtui.style | BorderStyle | src/style/border_style.cj |
| cjtui.geometry | Rect | src/geometry/rect.cj |
| cjtui | Frame | src/frame.cj |
| cjtui | Cell | src/cell.cj |
| cjtui | Component | src/component.cj（原文件保留） |
| cjtui | Alignment | src/alignment.cj |
| cjtui | LayoutNode | src/layout_node.cj |
| cjtui | KeyEvent | src/key_event.cj |
| cjtui | InputDecoder | src/input_decoder.cj |
| cjtui | Application | src/application.cj |

`src/text/unicode.cj` 属 `cjtui.text`，只保留既有 Unicode 薄适配函数。Frame 的全部成员仍在 frame.cj；布局纯函数在 layout.cj；ANSI 编码在 ansi_encoding.cj；终端 FFI 与 I/O 在 terminal_bridge.cj；有符号裁剪几何函数在 drawing_geometry.cj；文本校验在 text_validation.cj。Cell 的 blankCell 与实体同文件。

原根包 unicode.cj/border_style.cj 退出；原混合文件不再包含搬走的定义。没有平行内核、重复类型、额外依赖，也没有将 internal/private 状态改成 public。

`src/exports.cj` 用明确的 public import 再导出 Rect、BorderStyle、Color、Style、displayWidth、graphemeClusters，其余既有 public 符号仍直接定义在 cjtui。子包均不依赖根包，包依赖无环。原消费者和示例 `import cjtui.*` 未修改。

## 技能与参考

实际读取并使用 cangjie-coding：`/workspace/work/CangjieSkills/.agents/skills/cangjie-coding/SKILL.md`，仓库 SHA `277f2e1234ca5217496966887243c679653887a8`。首次知识查询为同一脚本进程批量 `--query 'public import 重导出' --query 'internal package 跨文件 private' --max-results 2`；再按返回 ID 用 `--node language.package.4-包导入.4-6-重新导出 --view leaves` 精读重新导出契约。SDK 实验优先于知识库默认旧版本。

已调用 using-superpowers（按 subagent stop 不展开其主代理流程）、executing-plans、test-driven-development、verification-before-completion。TASK058 明确冻结行为测试且禁止新增，因此先以结构脚本验证基线 RED，再整理到 GREEN，行为回归使用冻结项目。最终完整 all/PTY/cjp 干净消费由独立执行者负责，未因技能默认要求重复执行。

参考只读 `/workspace/work/cangjie-rules` 固定 `40bacab1dafc7c5710a9b14c5c5c86898feed63c` 的 STR/NAM/FMT：目录等于包、职责内聚、无环、lower_snake 文件、PascalCase 类型、显式 imports、cjfmt。未引入其治理工具或改造公开构造 API。

## SDK 最小 probe

SDK 来源：`source /workspace/work/validation/sdk/cangjie/envsetup.sh`；实际 `cjc -v` 为 `1.2.0 (cjnative)`、x86_64-unknown-linux-gnu，`cjpm -v` 为 1.2.0。

用 `cjpm init` 生成独立 `probe_api` 静态库和 `probe` 可执行项目，源码与清单保存在交接目录，不加入产品。库根 exports.cj `public import probe_api.style.Tint`；Entity 文件通过另一文件 crossFile 函数访问其默认 internal state，private secret 保持实体内私有。外部项目保持 `import probe_api.*`。

- 正向命令：`cd /workspace/work/source-organization/probe && cjpm build && ./target/release/bin/main`；退出 0，日志 `probe.log`。根明确再导出对外可用、同包跨文件协作可用。
- 负向：临时将外部程序 read() 调用替换为 `.state + .secret` 后 `cjpm build`，退出 1，恰有两个访问诊断，分别拒绝 internal state 和 private secret；日志 `probe_negative.log`。已恢复正向源文件。
- probe 搭建初次把 cjpm init 已有 `[dependencies]` 重复追加，出现 TOML 重复节错误；删除重复节后执行上述真正的正向语言实验。此错误未涉及产品源码或包能力。

没有遇到迫使 D026 降级的 SDK 限制。

## 实际验证

每个 CJPM 项目都使用 ignored cangjie-repo.toml，cache 为 `/workspace/work/source-organization/cache`（从只读 replay cache 复制），registry 为 `http://127.0.0.1:18972`。原 cache 未写。设置 `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`；原生构建 hook 原样运行。

| 检查 | 真实命令/结果 | 日志 |
| --- | --- | --- |
| 基线结构 RED | 基线运行 `python ../check_structure.py .`，退出 1，列出混合类型和缺少子包 | structure_red.log |
| 最终结构 GREEN | `python ../check_structure.py .`，退出 0，12 类型精确包/文件映射与 text 薄适配存在 | structure_green.log |
| 机械搬移验证 | `python ../check_relocation.py .`，退出 0，全部 39 个顶层声明 token 序列一致；仅忽略 package/import、空白、注释、可选分号 | relocation.log |
| 生产源码格式 | 实际改动的 18 个现存 `.cj` 逐文件 `cjfmt -f`，退出 0；格式前后 SHA 清单完全相同（幂等） | format-final.log、format-before.sha256、format-after.sha256 |
| 库构建 | repo 中 `cjpm build`，退出 0，生成 cjtui/style/geometry/text 的 cjo 与静态库 | build.log |
| 冻结布局消费者 | `cd tests/layout && cjpm build && timeout 30s ./target/release/bin/main`，退出 0；114 条 PASS 输出、无 FAIL | layout.log |
| 冻结装饰消费者 | `cd tests/decoration && cjpm build && timeout 30s ./target/release/bin/main`，退出 0；59 条 PASS 输出、无 FAIL | decoration.log |
| 原最小示例消费者 | `cd examples/minimal && cjpm build`，退出 0 | example-minimal.log |
| 原布局示例消费者 | `cd examples/layout && cjpm build`，退出 0 | example-layout.log |
| 变更边界 | `git diff --exit-code 1dcf969 -- tests native examples cjpm.toml build.cj`，退出 0 | 此次终端命令记录 |
| 补丁卫生 | `git diff --check` 与 `git diff --cached --check`，退出 0；提交后工作树 clean | 此次终端命令记录 |

PASS 输出数量是日志中的断言条目，不等同于独立测试数。结构与搬移脚本只保存在交接目录，不作为产品依赖或新增行为测试。编译/运行验证完成后只有提交动作，没有改变受检代码；Component 回退无关格式化后最终原示例已成功编译。

## 限制与后续交接

此作者未运行全 all、真实 PTY 或 cjpm bundle/clean-cjp 消费；依任务把这些最终整体验证留给独立执行者。现有构建确认三个新子包参与真实编译，未据此声称源码制品与完整产品验收通过。复现全量时必须使用此固定提交的源码包与 frozen tests；不能复用整理前版本的全量结果代替。

所有日志及 probe 源位于 `/workspace/work/source-organization/`；日志 SHA 清单为 `logs.sha256`。可从本 clone 获取 f79516f9865bdf71ea4c0ac578279f0b8d3877bc 集成。无未决实现阻塞。
