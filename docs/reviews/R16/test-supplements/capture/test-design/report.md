# TASK093 Session serial 闭包捕获修正

固定test-only SHA：`dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9`，仅1文件3增3删。真实onKey mutable-capture正常编译RED exit1；合法holder正常build exit0、直接binary exit0，6项真实回调计数检查通过。正式Glyph Session未执行。

仅修既存测试语言问题，不修改产品或期望，不判完整Glyph Session GREEN。独立角色继续原 `/workspace/work/glyph-tests-refresh/source`，父提交bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5；前次get/set修正、原get/set控制与全部旧FAIL均保留，未改main/任务状态、未派子代理。

## 原始错误和独立复现

只读取主代理明确允许的094 raw `/workspace/work/glyph-implementation/session-fixed.log`，未读取094源码、报告、progress或推理，未构建094候选。该日志唯一错误为 `lambda capturing mutable variables needs to be called directly`，指向存储到Application.onKey的lambda，notes为serial++与save(app, serial)捕获局部var。原件逐字复制为 `original-session-capture-fail.log`，SHA256 `acf5c7e81fad95ad781c1a34622e2121c1854ef8f3abe1275301b4346246fb4c`；编译器1 error，PTY未运行。

独立普通跨包consumer使用真实既有 `Application(Text(...)).onKey`，同样捕获局部 `var serial: Int64 = 0`。正常 `cjpm build` 实际exit1，同一条mutable-capture错误。源码 `capture-mutable-red.cj` 与raw `capture-mutable-red.log/json` 留存，未伪造Glyph类型、后端或生产声明。

已读固定CangjieSkills277f2e1并按脚本批量查闭包捕获与Array，再读取捕获规则精确叶子；raw在cangjie-capture-docs.log与cangjie-capture-leaf.log。结论为存储/传递捕获局部var的闭包不合法；本项目SDK1.2真实正常编译与实际运行是最终依据，不套用其他语言的捕获规则。

## 三行最小正式修复

唯一正式文件 `tests/glyphs/session/src/main.cj`：

- `var serial: Int64 = 0` 改为 `let serial = Array<Int64>(1, repeat: 0)`。
- p事件仍先递增1再save，改为 `serial[0]++; save(app, serial[0])`。
- run/headless/cleanup后仍save同一序号，读 `serial[0]`。

捕获不可变Array绑定并修改唯一元素，不再捕获可变局部scalar。复用标准类型，无新实体/文件/import/产品API；没有用Observable或stats保存序号，因此不添加绑定或订阅。helper `save(app, serial: Int64)` 与其report格式原样保留，传入元素仍是Int64。初始0、每次p恰+1、其它事件不改计数、结束后保留值的语义不变。

所有事件键、String/Color字面值、native fixture、G012 cases/expected、此前get/set修正及其它suite无改动；实际diff见unchanged-contract-check.log/json。不是回退G012或通过调整expected绕过编译。

## 同一文件的闭包与上游API检查

逐一核对所有lambda：两个Text/foreground getter只捕获let Observable引用，已由前次正常公共响应式控制验证；onKey所用app/text/foreground均是let绑定，本轮serial也为let，无剩余被逃逸lambda捕获的局部var。save/helper与String插值无逃逸lambda，callback输入event为其参数。扫描该文件未发现其它局部var或旧private.value访问。

现有公共Application.onKey存储handler，Application.dispatch真实调用该handler，Component.reference/KeyEvent/startHeadless/stop/dispose均在独立控制正常编译并运行。其它原公共调用按固定src声明核对，无确切证据要求额外修改。GlyphMode/terminalGlyphCapabilities/glyphMode/snapshot新参数仍属于完整094，在本独立旧产品基线不存在；没有伪造其类型来宣称全fixture编译，保留该范围给root独审后的094实际复跑。

## 正常编译与真实回调控制

外部 `/workspace/work/glyph-tests-refresh/capture-consumer` 用SDK cjpm init生成普通executable，路径依赖真实独立源，使用自有cache `/workspace/work/glyph-tests-refresh/cache`、现有relay18973与SDK1.2.0。控制源 `capture-holder-green.cj` 与实际编译的consumer源码按hash对应，非正式产品依赖。

合法holder控制将lambda真实存入Application.onKey；startHeadless后通过真实公共Application.dispatch向已挂载root的NodeRef分发KeyEvent，经过产品事件路径调用所存handler，绝不直接调用本地假callback。手写断言为初始0、p→1、x仍1、p→2、p→3、q停止后仍3，共6项。它验证闭包跨存储调用保留同一holder与实际callback计数；并非PTY/native或Glyph设备会话验证。

正常build、直接binary、实际exit/UTC/cwd/argv/raw见commands.json及同名log/json。最终固定提交、sourcehash、patch、控制source/manifest/binary和原FAIL hash见manifest.json；具体结果见results.md。没有skip-script/skip-build、他人target、declaration stub或094构建。

## 范围与复跑

正式Glyph Session/PTY/native/G012设备行为本轮未运行，不提前GREEN。root限定独审该独立test-only提交后交094应用到固定候选，正常 `source /workspace/work/validation/sdk/cangjie/envsetup.sh` 后执行 `tests/glyphs/run.sh session`，保留原1ERROR与复跑raw。独立控制只证明本次语言/计数修复，不能替代该正式复跑。

沿用systematic-debugging/TDD/verification-before-completion：先核原始错误与捕获调用链，真实onKey RED，再最小holder改动，正常编译与真实公共dispatch callback运行，最后diff/source/hash核验。AGENTS11.1下复用未改变的get/set控制与原测试，不重跑不相关suite或已知missing-Glyph-API旧基线。
