# TASK097 只读前读

状态：prepared，仅完成合同/固定输入前读与待证据矩阵；不是 TASK097 ready 或 PASS。TASK096 最终原件尚未交接，不能下实际验收结论。

已读完整 task-097-brief、G001–G012 design/specs/tasks/decisions、A001–A008 design/spec/tasks、Session152报告及P30、原AC093–097/041与AGENTS11.1/13/14。已应用 verification-before-completion 的证据优先原则；using-superpowers 明确对子代理停止其通用流程。角色要求 Astra/high，实际 serving model 不可核验。

095封存六文件通过 sha256sum -c；其 PASS_CODE_SCOPE/quality PASS 0C/I/M仅作已收到的独立代码审查输入。没有解引用095报告中作者工作目录的链接，没有读取094作者目录、报告、progress、自评或与其交流。

Root随后说明095旧ENOENT来自root转述manifest路径错误：所指原件是25项GlyphSession子树的 session-artifacts-sha256.txt，而非全作者树artifacts.sha256。此说明只作为待095 addendum确认的交接metadata，未访问作者路径；不得归为产品作者造假或功能缺陷，095独立重算hash及代码结论不受影响，原报告bytes保留。

产品源码来自 git archive 1f67e27358254e9daef637b5c2f5a93707ee7cef 的 src/native/build/manifest/README/product docs/examples，正式 tests/glyphs 单独从固定集成根 b3b24f896672336797cec009cfe0cd830a955aa7 导入。逐字节核对产品与集成根相同、测试与 ca56572 及095已记录hash相同。不是使用产品提交中的旧测试。源码副本仅本地分析输入，不归档整checkout。

[33项待证据矩阵](pending-matrix.md)按当前合同义务建立；逐项判定均留pending_evidence。待root交096最终report/raw/curated/manifest/source+binary/test/hash后，只补必要独立核验，不机械重复有效suite。真实kernel VT和真正GUI、原PNG/物理native数据、输出UTF8经验前置、实际字体map/UID、有限Session P30、文件导出及全CJP成员bytes分别判定。

未发现未被冻结裁决解决的行为冲突。发现旧spec的Unknown emulator coverage和decisions表仍沿原Unicode措辞；G012/A005与本brief明确覆盖为device Auto conservativeUnicode，canonical/offline Unicode保留，按此解释。该旧文不能被用于恢复无条件设备直出或认定新决策阻塞。

产品禁止读vcs；独立观察器可只读自有VM native vcs/vcsu/vcsa，须分离来源与调用链。fontmap、IUTF8和键盘模式均不是输出UTF8证明；不得改codec/字体取得通过。完整Theme ellipsis、041/全部Linux/M2/full release仍在外。P30仅按后续当前产品实际证据判已证subset，不提前关闭。

本轮没有构建/运行产品、启动host、改main/产品/tests/状态或派子代理。先前一次只读枚举因本目录当时不存在返回exit2；后续在自有目录正常创建，无产品失败含义。准备脚本只读取固定git和允许的095记录、写入本目录；hash结果见[preparation-hashes.json](preparation-hashes.json)。
