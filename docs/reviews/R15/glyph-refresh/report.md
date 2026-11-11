# TASK085 独立 Glyph/ellipsis 测试追加交付

固定 BASE：`b3b24f896672336797cec009cfe0cd830a955aa7`。
独立 test-only SHA：`2b16ce9d5975410265283cfce9ef127b3ad1f74d`。
目录：`/workspace/work/theme-glyph-tests/source`，分支 `task085-glyph-refresh`。

结论：已交付追加的独立测试源和真实 missing-target RED；现有公开 Glyph、SDK 语言事实及三项受控原生输入控制实际通过。**没有实际 Theme ellipsis GREEN，没有最终085/097验收，没有013/025 ready结论。** 097接受及最终085所需真实产品证据仍是准入条件。

## 范围与独立性

本次为执行型测试任务，依据完整 brief、AGENTS、T001–T016、G001–G012、A001–A008、原085 README/filemap及原测试角色R15记录。保留原全部47文件字节不变：字段/typed/schema/级联/预算/wrap/RichText/16负例/四套preset原件均保留。新提交16文件、556行，全部为 `tests/themes/` 下新增文件；`src/native/docs/openspec/cjpm.toml`无差异，未更改main/产品/正式状态，未派子代理、未与产品作者沟通、未读产品作者工作树/报告/进度/自评。

新目录四个普通CJPM项目：`glyph-language`为当前API/语言控制，`glyph-target`隔离真实Theme准入，`glyph-refresh`为未来离线ellipsis，`glyph-session`为未来正常Application.run受控PTY。骨架由实际SDK1.2 `cjpm init`生成，依赖均为普通相对 `cjtui={path="../../.."}`。脚本只选择本追加范围；原 `run.py`及其两个真实正向消费者先于16负例的gate原样保留。

新测试全部手写golden；没有假Theme/声明替身/期望生成器/私有policy调用/平行renderer或fontmap引擎，没有执行声明-only scratch。未来项目因缺真实API尚不能完整编译；这里不声称其完整类型检查已通过。

## 实际环境与命令

SDK实测 `Cangjie Compiler: 1.2.0 (cjnative)`、`Cangjie Project Manager: 1.2.0`。
环境为本目录 `env.sh`：现有SDK `/workspace/work/validation/sdk/cangjie/envsetup.sh`，官方stdx `/workspace/work/linux-build-recon/stdx-env`，同父UCD归档 `/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`。
私有cache从只读validation/replay-dependencies/cache复制到本目录 `/workspace/work/theme-glyph-tests/cache`，忽略的registry配置复用已运行 `http://127.0.0.1:18973`，没有新relay、没有作者target/cjo/native产物输入。native产物在自身普通build生成。SDK/ELF/CJP/CJO/cache/密钥未进入提交。

正式序列（cwd为独立source，命令前source本目录env.sh）：

```sh
node tests/themes/run-glyph-refresh.mjs offline /workspace/work/theme-glyph-tests/raw/refresh-offline
```

该次真实执行精确argv/cwd/UTC/受检BASE/exit在 `raw/refresh-offline/commands.jsonl`，分别保存stdout/stderr。后续两个项目只按已通过、内容未变的真实Glyph控制继续构建，避免重跑同一根/依赖：`raw/remaining/commands.jsonl`记录各自cwd内 `cjpm build`。实际命令执行时HEAD为BASE，追加源码hash与最终提交hash另行固定。

| 实际执行项 | 退出/含义 | 原件 |
|---|---|---|
| 普通root `cjpm build` | 0，正常产品root | raw/refresh-offline/root-build.* |
| 原真实 `tests/glyphs/api` build / direct binary | 0 / 0；公开GlyphMode、两构造、getter/setter、render/snapshot存在 | raw/refresh-offline/glyph-api-* |
| 自有adapter gcc -Wall -Wextra -Werror / ar | 0 / 0 | raw/refresh-offline/adapter-* |
| 当前API/Observable/escaping-holder build / direct binary | 0 / 0；get()/set()与let Array引用holder合法，未用私有Observable.value | raw/refresh-offline/language-* |
| 当前实际Application PTY输入控制三项 | 0；control-unknown / control-mapped / control-missing均PASS | raw/refresh-offline/native-input-control.*，control-pty/ |
| 隔离真实Theme准入消费者 build | 1，唯一缺依赖 `cjtui.theme`；不是Glyph缺失 | raw/remaining/theme-target-build.* |
| 追加离线ellipsis消费者 build | 1，缺Component.overflow/四边padding等冻结Theme API；20错误默认打印8条 | raw/refresh-offline/theme-offline-build.* |
| 追加设备ellipsis消费者 build | 1，缺7个overflow及theme构造命名参数，共8错误 | raw/remaining/theme-session-build.* |
| 两个新增Node脚本syntax、git差异/空白/路径检查 | 0 | 本次工具执行记录；最终固定路径见raw/commit.txt |

**未执行、不计PASS**：新Theme target二进制；所有新离线ellipsis断言；7个未来设备profile场景；原Theme values/integration运行及16负向编译。原085已冻结静态/词法证据按AGENTS11.1仅复用其原范围，未宣称旧Theme曾有行为GREEN或重跑全部冷suite。

## 原生输入控制充分性

`glyph-session/native/theme_glyph_wrap.c`直接include现有固定 `tests/glyphs/session/native/glyph_syscall_wrap.c`，不改093原文件。仅在已有wrapper实际返回的GIO_UNIMAP数组将U+2026条目换为已有ASCII A，保留104 pair、正文ASCII、点号、问号与é；不复制map引擎。当前实际公开Application的字面源固定 `é …`，5列下手golden：unknown=`é …  `、原mapped=`é …  `、仅缺ellipsis=`é ?  `。

真实三项控制均成功直接退出0、PTY bytes等于实际stdout成功write捕获、termios前后相同；已知两项只查一次map，未知零map读取。缺ellipsis场景原件记录 `nativeVt=true/mapKnown=true/entryCount=104/source=linux-vt-unimap/reason空/nativeError=0`，trace有唯一 `theme-filter ellipsis-removed=1 pairs=104`。因此未来 `ABCDE` width4=`A...` 能区别错误的一列预算后编码=`ABC?`。空map不用于证明预算。

这是真PTY+受控syscall分支，**不是实际kernel VT或字体证据**。不替代096/097、物理推进GUI回归、完整AC041。

## 已准备、待真实Theme的golden与覆盖

* width0/1/2/3/4：Unicode/default/offlineAuto分别 `""/…/A…/AB…/ABC…`；Ascii分别 `""/./../.../A...`，先预算标记宽再取完整源前缀。
* 实际Row flex分配4列、右侧q，期望 `ABC…q` / `A...q`；四边padding、硬行高度/兄弟、zero width及隐藏无绘制；Clip/exact-fit/wrap隐藏垂直行不伪造marker。
* 离线Ascii `éBCDE`宽4=`é...`，combining完整簇、CJK不拆半、跨span首scalar样式、组件显式mask；逻辑Observable/RichText源保持。
* 相同mounted root交替snapshot Unicode/Auto/Ascii/default，等价策略复用cache、Ascii改变frame、设备glyphMode不能污染离线默认；render交替和plain/ANSI完整逻辑导出。
* 7个未来正常公开Application设备profile：unknownAutoConservative/Unicode/Ascii、mapped-present/missing、mapped Unicode/Ascii override。unknownAuto的ZWJ为`??`而离线原文保留；width0–4、实际Row分配均手写golden；setter独立wake、measure/cache变化、同值零输出、身份不重建、仅探测一次与事后offlineDefault/Auto独立。

运行及详细filemap见提交内 `tests/themes/GLYPH-REFRESH.md`；原README保持原件。当前runtime无新增公开ambiguousWide模式，不为测试发明；G006包内既有helper测试仍负责该维度，未来Theme必须复用真实生产helper，不能从其输出生成oracle。

## 固定与复用依据

`raw/original085-preservation.json`逐文件与BASE逐字节比较47项全部相等，16负例保留；四preset hash/bytes见 `raw/preset-fixtures.json`，同原冻结hash（classic2534/dark2535/high-contrast2552/light2536 bytes）。`raw/final-source-hashes.json`固定最终16新增文件及实际复用wrapper；`raw/executed-final-equivalence.json`比较真实运行输入与最终源。

当前成功运行的 `.cj/.c/manifest/glyph-pty.mjs`及产品内容未变。之后只给runner补独立target选择、source-hash外部fixture与忽略build-script-cache目录，及相应README说明；Node语法/实际diff重新检查0。先前runner的hash文件曾含一个自身忽略build-script-cache日志，最终source manifest仅采用git固定测试源及复用wrapper，不将该生成日志当测试输入。未因此再冷跑全部根/依赖；没有对新增target执行结果复用其它项目的PASS。

适用TDD与verification-before-completion实际已读/采用；OpenSpec apply技能/CLI `status/instructions apply`读取现有implement-theme-styles，未改其状态（brief明确禁止）。CangjieSkills277f2e1实际脚本批量查询closure/Array/cjpm init，工程参考cangjie-rules40bacab的STR/NAM/FMT与项目差异已读，未将其外部检查器升级为额外门禁。SDK实际编译事实优先。角色指定Sol/high，实际serving配置不可核验。

交接：只消费本test-only SHA与BASE合同。097接受、真实Theme代码固定后，独立执行角色运行原085完整gate和新增target/offline/session组，再核普通制品/真正host等其职责证据。本文不把测试源交付或当前Glyph控制PASS当作最终085/013/025准入。
