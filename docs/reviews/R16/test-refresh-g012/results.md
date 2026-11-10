# 真实命令结果

完整时间和argv见commands.json；raw为每项同名.log。预期编译RED、语言控制和真实产品运行分别解释。

| 命令记录 | exit | run / blocked解释 |
|---|---:|---|
| environment | 0 | SDK cjc/CJPM 1.2.0；固定BASE |
| baseline-build | 0 | PASS 正常根build；产品无改动 |
| api-red | 1 | 初次真实完整Glyph API missing RED；最终见api-final-red |
| internal-conservative | 0 | PASS 5/5；仅既有有限内核；无Ascii/map/marker/API |
| shell-syntax | 0 | 早期shell语法；最终见shell-final-syntax |
| node-syntax | 0 | PASS Node parse；未执行PTY |
| native-compile | 0 | PASS gcc -Wall -Wextra -Werror；未执行native分支 |
| internal-full-red | 1 | 真实RED：现有GlyphRenderPolicy缺ascii/mapped；完整13项未运行 |
| staged-check | 0 | 早期diff检查；最终见final-diff-check |
| public-red | 1 | 真实RED：缺GlyphMode/TerminalGlyphCapabilities/render+Application参数；离线/File/cache行为未运行 |
| source-and-diff-check | 0 | PASS 产品相对BASE无diff，原public/rich/native/negative fixture/Frame tests未变 |
| rich-red | 1 | 真实RED：缺GlyphMode及render参数；4个已打印诊断无缺RichText前置 |
| session-red | 1 | 真实RED：缺GlyphMode/terminalGlyphCapabilities/glyphMode；PTY/native动态未启动；非finalSession扩展证据 |
| readonly-blocked | 2 | 初次正向API gate失败，readonly未尝试 |
| readonly-control-mutable-parameter | 1 | 纯编译预期拒绝：parameter value is immutable；复现旧fixture假阳性 |
| readonly-control-mutable-local | 0 | 纯编译允许：var local可写public var字段；从未执行 |
| readonly-control-readonly-local | 1 | 纯编译预期拒绝：variable flag is immutable；从未执行 |
| api-final-red | 1 | 最终正常跨包missing API RED；缺TerminalGlyphCapabilities/GlyphMode，binary未运行 |
| shell-final-syntax | 0 | PASS 最终shell语法 |
| final-diff-check | 0 | PASS 最终staged whitespace与产品无diff |
| readonly-final-blocked | 2 | BLOCKED：最终正向API gate失败；旧combined+六独立readonly检查均未运行 |
| final-verification | 0 | PASS 全受检sourcehash、工作树clean、product无diff与全部改动仅tests/glyphs |

编译器默认最多打印8项诊断；报告只分类实际打印的错误，不虚构被截断错误。真实readonly、完整marker、PTY/syscall行为均未运行。三个结构体语法控制不计为产品readonly通过。
