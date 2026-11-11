# TASK093 Session Observable fixture 公共调用修正

固定test-only SHA：`bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5`；仅1文件8增8删。公共consumer：private-field正常编译RED exit1；get/set正常build exit0、直接binary exit0，9项检查通过。正式Session未执行。

本交付只修测试 fixture 对现有 Observable 公共 API 的调用，保留原 FAIL。普通公共 Observable consumer 的验证与完整 Glyph Session 验证严格分开；不声称 Session/PTY/native 或094 GREEN。

## 固定输入和根因

继续原独立 `/workspace/work/glyph-tests-refresh/source`，父提交 `df21f3def32de39a415d1d8d9845b83514dc2902`；产品仍是该提交继承的固定 `04a5289361d990e5a340ace22bbd50c9b805a9d9` 源。未改main、产品、公开API、规格、状态或其他测试，未派子代理。

仅从094作者目录读取主代理明确指定的 `/workspace/work/glyph-implementation/session-direct.log`，未读取094源码、报告、progress或实现推理，未构建094产物。原始日志逐字保留为 `original-session-direct-fail.log`，SHA256 `c46fd4e37db6a60ea35c5bf9b1cfb79eb78a94770e3191047a5259eb45487a20`；编译器报告11 errors、最多打印8项，所打印错误为 `can not access field 'value'`。不虚构未打印诊断。

独立核对原正式fixture的10处Observable.value引用，生产 `src/observable.cj` 的字段是 `private var value: T`，公开方法为 `get(): T`、`set(value: T): Unit`；get收集绑定依赖，set发出变更。该产品文件在原df21与主代理指定root4a1dac52936da971bf42d4052c5dad4220ae6667完全一致，SHA256均为 `9dfb578e88a75548fc76785dad65bd70d8a4ff0eaf2309d58a7ba68651a9758b`。这是测试作者误用已有公共接口，不要求产品公开private字段。

额外普通跨包consumer先用原 `.value` 读写，真实正常 `cjpm build` exit1，两项 `can not access field 'value'`。其源保留为 `observable-private-value-red.cj`，raw为 `observable-private-value-red.log`，与094原FAIL分别保留。

## 最小正式修改

唯一正式文件 `tests/glyphs/session/src/main.cj`，8行替换、8行新增：2处getter改为 `text.get()/foreground.get()`，8处赋值改为现有 `text.set(...)/foreground.set(...)`。事件键p/v/t/z/h/n/c/b/a/u/o/q、所有中文/问号/ZWJ/VS16/ASCII字面值、Red/Blue颜色、初始状态与复合b事件顺序均不变。

G012全部case、expected字符串、PTY脚本、native fixture、其他正式suite与产品源无diff；实际检查见 `unchanged-contract-check.log/json`。其余现存公共调用按本固定源声明核对，未发现有确切证据需要一并修改的调用；未来Glyph接口缺失继续保持原blocked，不以此扩展产品或改测试预期。

## 普通公共 Observable 控制

外部开发控制目录 `/workspace/work/glyph-tests-refresh/observable-consumer`，SDK `cjpm init` 生成正常executable清单，普通path依赖指向上述独立真实源；使用现有自有cache `/workspace/work/glyph-tests-refresh/cache` 与relay18973。未使用skip-build/skip-script、替代产品类型、mock backend、private访问或他人target。

绿色控制源原件为 `observable-getset-green.cj`，正常构建后直接执行 `target/release/bin/main`。只使用现有公共 Observable<String>/Observable<Color>、Text getter/foreground getter、Application.startHeadless/batch/snapshot/dispose：检查初始get、现有文本/样式绑定，再以原fixture的文/??/ZWJ/VS16/A值调用set并通过既有snapshot观察响应式变化；另检查只变颜色与b事件的文本/颜色合并写入。所有frame原文/空格/颜色expected为手写字面量，不从产品输出生成。没有GlyphMode或任何094符号。

真实命令、UTC start/end、cwd、argv、exit/signal与raw以 `commands.json`、逐项同名json/log为准；最终运行结果与固定SHA见 `manifest.json`。SDK实际cjc/CJPM1.2.0，验证版本记录在environment.log。

## 范围和下一步

公共headless响应式控制只证明现有get/set可读写且能使既有文本与颜色绑定更新，不证明完整Glyph设备Session、PTY/native故障分支、setter唤醒/profile/diff或真实终端表现。此次没有运行正式Session，也没有构建作者094产物；本独立源尚缺完整Glyph公共API，先前实际missing-API RED与此控制分开，不能把控制GREEN替代SessionGREEN。

root独审该独立test-only提交后，将它交094应用到固定产品源，再正常执行 `source /workspace/work/validation/sdk/cangjie/envsetup.sh` 与 `tests/glyphs/run.sh session` 复跑受影响正式消费者和PTY/native/G012全部原case。原private-field FAIL与本次控制RED均保留。

技能沿用已实际加载的systematic-debugging、TDD、verification-before-completion和固定CangjieSkills277f2e1：先核日志/公开源职责与同类现有get/set消费者、复现正常跨包RED，再做最小测试调用修正，正常构建并实际运行公共响应式控制，最后核diff/hash。新符号的语言事实来自本SDK真实正常编译，不添加新的技能或依赖。按AGENTS11.1不重复已确认相同原因的完整Glyph missing-API编译，也不冷跑无关suite。
