# TASK093 存储回调捕获修复的有限独立审核

**spec PASS；quality PASS；必修 finding=0。** 固定范围 `bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5 → dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9`，只审核同一 session fixture 的三行 serial holder 更正。此前 get/set 审核结论保持；本结论不是 TASK094 产品审核、完整 Glyph session/PTY/native GREEN。

完整技术包与独立 `git diff -U10` 一致；包头 FETCH_HEAD 简称已由明确 commit ID 消歧。提交仅修改 `tests/glyphs/session/src/main.cj`，3 行增加/3 行删除，固定父提交和 `git diff --check` 通过。新文件 SHA256 `6ee5aab2d2dab6d6a45eed4ff690fd251f6d31ab2a7374f3fb0f790c7912bafa`。

本次修复与 SDK1.2.0 及既有仓颉工程约定一致：存储的逃逸 lambda 不能捕获局部 var，允许捕获 let 持有的数组并修改元素。原始 session 失败副本及独立正常公共控制均报唯一错误 `lambda capturing mutable variables needs to be called directly`，指向 serial。该 var、递增与保存语句在 df21 和 bfd 中原样存在；这是原设施既有问题，不是 bfd get/set 修改引入的回归。

`let serial = Array<Int64>(1, repeat: 0)` 分配固定一元素 holder；onKey 保存同一个 let 引用。p 分支先 `serial[0]++`，再将其 Int64 值传入 save；其他事件没有写 serial。run 返回、headless 快照与 dispose 之后的最终 save 读取同一 `serial[0]`。因此初值 0、每 p 加 1、其他键不增加、stop 后保留最后值的原测试意图不变。没有增加 Observable、绑定、订阅、节点或 invalidate 调用；serial 仅用于报告 fence，不是 UI 数据，固定 Array 的元素更新不会自身改变 frames/measures/mounted 等 UI stats。这里没有声称已动态测量完整 Glyph session stats。

独立精确变换检查证明整个新文件仅有这三处变化。所有字符串/Unicode 字面量与事件名称逐字相同，原 get/set 行不变；产品 src/native/manifest/build、正式合同、PTY oracle、native syscall wrapper、G012 conservative case 的 Git 对象均不变。没有添加产品 API、测试 hook、第二实现或新实体。TASK093 的正常公共消费者和“不得为测试公开产品内部”的约束得到保持。

允许的原始控制证据已按 hash 与命令 JSON 核验：

- 原 session 捕获失败副本 SHA256 `acf5c7e81fad95ad781c1a34622e2121c1854ef8f3abe1275301b4346246fb4c`；独立 mutable capture consumer 的实际正常 CJPM build exit 1，错误与上述 SDK 约束一致。
- Array holder consumer 正常 CJPM build exit 0，直接 `./target/release/bin/main` exit 0。它通过真实公共 `Application.onKey` 注册回调、`startHeadless` 和 `Application.dispatch` 执行，不直接调用假 handler。六项检查观察到初值0，p/x/p/p 后为1/1/2/3，q 驱动 stop 后仍为3。
- 实际控制 binary SHA256 `0d99920b428651fa2314db02c2aa19a1163b7211a3242a3c507c8dfaacd1170c` 与 manifest 相符。这证明语言捕获合法性与现有回调计数语义；没有执行完整 Glyph session、VT 探测或 glyph 投影，不能推导这些范围通过。

按 AGENTS11.1 复用内容不变的真实 SDK/public control 证据，未重复冷构建、已知 RED 或大型 suite。此次独立执行 `node verify.mjs`，cwd `/workspace/work/glyph-observable-fixture-review/capture`，UTC `2026-11-11T00:29:25.650Z`，exit 0，37 项/0 失败。包括固定对象边界、三处精确替换、字面量/既有错误确认和原件 hash/exit/binary 核验；详见 [verification.json](raw/verification.json)。

使用既有 requesting-code-review 固定输入原则与 verification-before-completion 证据要求。没有读取测试作者 report/推理、094 源码/报告/progress/自评，没有作者通信或子代理，没有产品/tests/main/status 编辑。报告、findings、脚本与有限 raw/hash 作为交付；原始编译日志、控制源与 ELF 保留外部并记录 hash，不复制 SDK、缓存、整源码目录或作者报告。

无未关闭必修缺陷，可交固定 TASK094 候选进行正常正式 session 构建运行；完整会话结果仍待实际执行，不因本设施审核更新为 GREEN。
