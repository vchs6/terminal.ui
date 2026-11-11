# Glyph Observable 正式测试设施独立审核

**spec PASS；quality PASS；Critical/Important/Minor 均为 0。** 结论仅覆盖 `df21f3def32de39a415d1d8d9845b83514dc2902 → bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5` 的公共 Observable 调用更正，不是 TASK094 产品审核或完整 Glyph session GREEN。

固定技术包与独立 `git diff -U10` 逐字一致。包头的 `FETCH_HEAD` 是命令展示简称，实际审查终点由完整 commit ID 固定。提交只改 `tests/glyphs/session/src/main.cj`，8 行增加、8 行删除；父提交、文件 hash、`git diff --check` 均独立核验。受检文件 SHA256 为 `f29b638db73ae77d6796c430f33f07ddd71f0c175afd151bc3355eb18552c4b3`。

正式 TASK093 要求使用正常公共消费者，禁止为测试扩展产品导出，保留既有独立预期。权威 Observable 在测试固定提交与 root 固定参考 `4a1dac52936da971bf42d4052c5dad4220ae6667` 中内容完全相同，blob 为 `dc86156542564bd9d690484ee4f8fb478178ab46`，SHA256 `9dfb578e88a75548fc76785dad65bd70d8a4ff0eaf2309d58a7ba68651a9758b`：字段 `value` 为 private，`get()`/`set(T)` 为 public。`get()` 在绑定 evaluation 中登记依赖，`set()` 更新版本并 emit；它们是这类响应式文字/颜色消费者的正确入口。

更正保留绑定闭包，仅将 `text.value`、`foreground.value` 读取改为 `.get()`；事件 v/t/z/h/n/c/b 的对应赋值改为 `.set(...)`。组合事件仍按文字后颜色的顺序写入，未插入刷新或改变批次。整个新文件与旧文件仅应用这组精确替换所得结果完全相等；全部字符串字面量、事件名称、Unicode 转义和值逐字保留。因此更正没有修改 expected/golden、事件内容、报告 fence、native fault seam 或 G012 场景。产品 src/native/manifest/build、正式合同、PTY oracle、native wrapper、conservative 测试的 Git 对象均未变化，没有扩大产品 API。

已有真实证据的适用范围已独立核对：

- 允许的原始 Glyph session 编译失败副本确报 `can not access field 'value'`，复制 hash 为 `c46fd4e37db6a60ea35c5bf9b1cfb79eb78a94770e3191047a5259eb45487a20`。这证明原设施错误，不是产品 glyph 行为失败。
- 正常跨包 Observable 控制的 `.value` build 退出 1；改用 get/set 的 build 退出 0；实际 `./target/release/bin/main` 退出 0，保留九项响应式检查，覆盖初值、文字/颜色绑定、五种文字变化、单颜色变化和组合写入。控制未伪造 Observable/Application，使用普通路径依赖和真实 headless Application。
- 九项控制只证明现有公开 Observable 与绑定更新正常。它不实现/验证 GlyphMode、VT 检测、glyph projection、native syscall fixture 或完整 Glyph session。完整会话尚未执行，必须在固定 TASK094 产品上另行正常构建运行。

按 AGENTS11.1 复用上述 SDK1.2.0 原件，没有重跑已知 private-field 编译错误、冷 SDK 或全套测试。此次独立新执行为 `node verify.mjs`，cwd `/workspace/work/glyph-observable-fixture-review`，UTC `2026-11-11T00:17:40.951Z`，退出 0，39 项/0 失败。内容包括精确替换/字面量不变、固定对象范围、原始日志/命令 JSON 与 evidence manifest hash、真实控制 binary hash（`a4c61bd8848a180cd1ba4907c722937421f06b1114548adc81f5e51736f6ff4d`）。详细记录见 [verification.json](raw/verification.json)。

审查辅助脚本最初在测试仓查询仅 root 仓拥有的参考 commit，随后错误尝试将其当 blob，均因对象不存在中止，尚未执行控制消费者。已改为在 root 仓读取明确允许的固定 `src/observable.cj`，并与测试固定对象核对；保留了最后一次失败的 log/exit 原件。它们是审查脚本对象位置错误，不是产品或正式测试失败；最终 39 项记录来自修正后的完整检查。

使用此前已读取的 requesting-code-review 固定范围原则与 verification-before-completion 证据要求；没有新代理、产品/测试/main/status 编辑、094 作者源码/报告/progress/自评读取或作者通信。仅读取固定测试、正式约束、明确允许的 Observable 权威与证据。没有以设施修复通过替代 094/095/096 产品执行与验收。

交付保留本报告、findings、核验脚本、有限 raw 和输入 hashes；原件仍位于 `/workspace/work/glyph-tests-refresh/observable-report/`。不复制 ELF、SDK、缓存、整 checkout 或作者报告。`reviewed-hashes.json` 明确原件路径、hash 和省略原因。可接受此测试设施修正并交后续固定产品会话执行；未发现需要返回作者修复的问题。
