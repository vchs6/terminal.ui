# TASK-093 独立测试交付

本报告只交付正式 test-only 资产及旧产品真实 RED，不声称 glyph 产品 GREEN、真实VT视觉通过或完整ellipsis布局通过。

正式固定 test-only full SHA：`daf2a2523c5aacb27e2ea3b564b9b057bd6430de`（17个文件、935行，仅tests/glyphs，工作树clean）。受检源码逐文件hash为 `final/test-sourcehash.sha256`（自身SHA256 `9ce4dca67fccfb751ee88a38bff0f158e0c1a8f03c20c513d58f93b6e9975bf2`）；patch SHA256 `278ff454a0e38cc83969cb7f4e4d5662bd4a9169733b0946bfbcf5d33c9e3ca6`。完整冻结元数据见 `manifest.json`。

## 固定输入与隔离

- 固定合同：`a0eae9998f8f72410148c1845840fde591e23d9b`，design G001–G011；design SHA256 `a0a528f8b1e00bcdf6d715fccb723203893b92f5a5eb723d3f10c1ca34bddef8`。初始派工合同 d504ca6，G010/G011为主代理补充冻结，不由测试作者自行改约。
- 独立旧产品源：`5fd65815c7332d4f6af4ebe7eb0307fad4934bf1`，从 `/workspace/work/terminal.ui` 自主clone到 `/workspace/work/glyph-tests`，分支 `test/task093-glyph-contract`。未读产品作者分析、未互通实现推理、未修改产品/规范/任务状态/其他suite。
- 主代理已准入093；080/084及正式glyph产品尚不在本受检旧源。后续094与096需用最终080/084+本test-only SHA+产品SHA重新核验。
- 正式修改仅 `tests/glyphs` 17个文件。共享run-slice入口由主代理后续机械接线，本提交未改现冻结suite。
- SDK：`source /workspace/work/validation/sdk/cangjie/envsetup.sh`，cjc/CJPM实际均1.2.0。独立cache `/workspace/work/glyph-tests-evidence/cache`，仅从共享只读seed复制；每consumer/根repository.home registry=`http://127.0.0.1:18973`。没有skip-build/skip-script，没有他人target作为依赖。
- 请求角色配置 Sol/high；当前工具未暴露 serving model/effort独立核验值，不冒称已核验。

## 正式资产和独立预期

入口与矩阵见 `/workspace/work/glyph-tests/tests/glyphs/README.md`。资产包括：glyph-only正常消费者、offline/File消费者、RichText前置独立消费者、8个合法同根package @Test、六只读字段负编译消费者、真实PTY会话与syscall link-wrap。

预期全部手写字面量/bitmap位，未从产品输出生成golden；不复制Unicode算法/数据。BMP覆盖手填精确8192byte；追加最高byte U+FFFD；错误长度0/8191/8193、冻结防御复制、empty、问号缺失、专用边框fallback缺失都有独立断言。native map为104 pair且一个重复é；max为65535重复pair，entryCount不能误作去重数。

模式覆盖Auto/Unicode/Ascii；实际stdout仅fd1、非VT不读map、fstat/VT/KD/map失败原errno、alloc失败0、alias/graphics/not-tty正常分类；空map仍known且ascii-fallback-unavailable。函数覆盖原簇é/e+acute/中文/emoji/VS/ZWJ、0/1/2/4列与负宽、整簇等宽占位、literal…一列、generated marker -1/0/1/2/3/5列与实际ambiguousWide true/false。Frame覆盖投影后中→文/中→??零字节、颜色与glyph同时等价、各用新旧profile、宽→窄完整行清残留、边框/逻辑Unicode导出和真实maxCells预算。缓存覆盖同值内容复用、offline模式交替、setter单独wake/即时measure增加/同值无动作。

真实PTY wrapper仅链接到测试binary，生产不读取测试环境变量/回调。malloc/读map/syscall失败是合法现符号link-wrap。write wrapper保存真实fd1成功write的同字节，UI报告fence前后按该文件长度比较；退出后要求与script真实PTY stream相同。没有构造第二Frame/Unicode宽度/ANSI内核。

## 实际验证证据

完整逐命令 argv/cwd/UTC start/end/exit/signal在 `final/commands.json`，最终public缓存断言复核在 `final/public-final-red.json`。日志不截断，`.log`保持原始编译器字节（含ANSI）。最终test源码逐文件hash在 `final/test-sourcehash.sha256`，固定patch在 `final/test-only.patch`。

本轮根 `cjpm build` 正常exit0，随后正式最小 `tests/glyphs/run.sh api` exit1。后者仅GlyphMode/Application新API及现有Text/ColorMode，真实诊断undeclared GlyphMode；初轮未扩展相等比较时同样真实unknown named argument glyphMode/undeclared GlyphMode/额外render参数（`api-red.log`，exit1）。Rich/Theme未实现不能成为此项唯一诊断。不是用普通产品build失败、假stub或不存在命令充当RED。

`public/internal/rich/session`各入口在无声明的同一真实旧产品上实际执行正常CJPM并exit1：public缺GlyphMode/TerminalGlyphCapabilities；internal缺GlyphRenderPolicy/glyphPolicy/projectTerminalGlyph/generatedEllipsis；rich同时缺前置RichText（单独列明，不代替glyph-only RED）；session缺GlyphMode及Application相关方法。readonly负编译目前被缺TerminalGlyphCapabilities阻断，脚本返回1，未误计为immutability通过。PTY执行在session编译失败后不启动；没有虚构raw宿主运行结果。

测试shell语法、Node parse、native wrapper的GCC `-std=c11 -Wall -Wextra -Werror` 编译、staged diff whitespace实际检查均记录对应exit。本轮不运行不相关旧全suite，也不声称旧suite通过；产品094/096仍需按受影响范围执行旧颜色/Frame/runtime/rich回归。

外部width-probe用真实旧产品的正常CJPM build+实际binary，均exit0（`width-probe-*.log/.exit`），只实算共享displayWidth/数组位操作/File UTF8往返：源文本narrow19/wide20，…narrow1/wide2，组合e+acute1，中文4，emoji/VS/ZWJ2。它不是glyph产品测试GREEN，也没生成expected。

外部declaration-only语法隔离：`/workspace/work/glyph-tests-evidence/declaration-only`；源码真实旧产品副本只增加冻结包内工厂/函数的throw声明和profile参数；`check-internal-declarations.sh`执行正常 `cjpm test --no-run --no-color` exit0，8个正式@Test编译通过。绝未运行其测试binary；所有函数体直接throw；未提交、未作为GREEN、不在正式runner中。仅确认正式同包测试的仓颉语法/解析与冻结签名自洽，不能代表实际生产实现。编译出现仅scratch声明未用参数警告，未压制为产品结果。

## 实际技能使用

已读AGENTS和项目提案/需求/架构/用户构造设计，执行独立角色/源码职责/最小可见性/正常CJPM/相关性验证规则。using-superpowers按SUBAGENT-STOP不展开根设计流程；应用test-driven-development先写真实消费者/expected并观察旧产品RED，不写产品；应用verification-before-completion核命令exit/实际diff后固定提交。

CangjieSkills固定 `277f2e1234ca5217496966887243c679653887a8`，实际读cangjie-coding SKILL并按脚本批量渐进search_docs查询cjpm init/test同包发现、Array repeat/位操作、File.readFrom、String.fromUtf8；精确读取test选项叶子（原始输出 `cangjie-samepackage-docs.log`），据此以SDK cjpm init生成4个consumer清单、把@Test复制到生产src同包、仅在外部scratch用no-run隔离语法；语言事实用SDK1.2真实编译/width-probe确认。cloud runtime技能已读并查当前environment_status ready/connected，未引入桌面/浏览器依赖。

## 未决和有限边界

本交付的正确最终描述是 **test-only冻结 + 真实缺API/内部缺实现RED**。真正glyph行为GREEN、公开API与RichText产品最终集成、native分支执行、真实PTY运行、真实VT/模拟器视觉与PNG/hash、制品consumer仍待094/095/096。无产品代码或声明stub冒充实现。

Actual ellipsis前缀预算/重排/绘制不在093；generatedEllipsis只是实际生产纯选择函数的固定断言。Theme013完成后085追加场景/088验收，不把函数单测算作端到端，不关闭完整041/Linux全阶段。

## 最终命令结果

| 命令/入口 | exit | 解释 |
|---|---|---|
| environment | 0 | SDK1.2/旧源核对 |
| baseline-build | 0 | 旧产品正常构建 |
| api-red | 1 | 真实缺GlyphMode API RED |
| public-red | 1 | 初轮公开consumer RED；最终缓存断言取public-final-red |
| internal-red | 1 | 真实同包缺policy/projection/profile RED |
| rich-red | 1 | 含未集成RichText前置，单独列明 |
| session-red | 1 | 真实缺glyph API，故未启动PTY |
| negative-blocked | 1 | 缺capability类型，未计immutability通过 |
| shell-syntax | 0 | 正式shell语法检查 |
| node-syntax | 0 | 初轮Node parse |
| native-compile | 0 | GCC -Werror编译正式syscall wrapper |
| diff-check | 0 | staged whitespace检查 |

最终public追加缓存断言后正常CJPM复核exit1（final/public-final-red.json/log）；最终PTY路径静态修正后Node parse、staged diff检查各exit0（final/final-static-checks.json）。这些静态修正未改变受检旧产品/消费者的仓颉源或内部测试；不需要重复仍适用的旧产品构建。全部正式测试源码hash在提交前核对成功，commit后树内容与该hash一致。
