# Linux 收尾候选独立 preflight

结论：**failed（仅规划 self/interface）**。固定受审提交 `df9612e66418750c6cb712b3ff035c1789ef8292`。两项 major/Important 文档问题和一项 minor 追踪问题待修正；未授予任何产品任务 ready。没有将尚未实施功能、未来测试/产品 SHA 缺失或实际宿主原件尚未产生认定为新产品缺陷。

本轮只读核对 AGENTS、工程 DQ、Battle、原 requirements/acceptance/tasks、候选四份文件、上游正式设计相关接口及现有脚本/source。无子代理，无产品/tests/主仓修改，无构建、功能套件、发布、提交或推送。未采用产品作者自评作为依据。`reviewed-hashes.json` 记录31份输入的固定 Git blob/SHA-256及工作文件一致性；完整文件阅读与上游相关章节检查的范围已区分。预算为单轮不超过60分钟，未实施修复循环。

## 待修正项

1. **LC-PF-001 / major：C003 过期精确签名。** 候选 `design.md:23` 把 `Application.snapshot(width,height):Frame` 称为唯一入口，`tasks.md:39` 又要求“公开签名严格C003”；正式 Glyph `design.md:45–46` 已冻结 `glyphMode!: GlyphMode = GlyphMode.Unicode`。现源码双参只是尚未集成Glyph的事实，不能覆盖未来正式接口。最小修正：同步完整签名或明确这里只是兼容调用示例、精确签名归Glyph G002；010固定输入纳入097，加入默认Unicode、Auto=Unicode、显式Ascii只改变框架生成标记而不转码业务文本的检查。Frame文件API保持原样。反例是正式合法 `snapshot(w,h,glyphMode:GlyphMode.Ascii)` 在“严格双参”的测试合同下被错误排除。
2. **LC-PF-002 / major：2.1 将五个独立原任务合成一个L3状态。** `tasks.md:26` 为每卡设 `level=L3`，`:56` 唯一复选框涵盖001/002/003/004/041。虽然承诺逐AC判定，但没有五项独立的任务状态、输入、交付落点及步骤归属。“不是全能编码L3”不能豁免文档/验证L3的单一结果要求。最小修正：2.1改无状态协调标题，下设五个原稳定编号记录，引用共享字段和共同host证据即可，不新增编号、不复制五角色。每项给具体文档/证据入口和原AC判据；未来命令/SHA未定显式列planning_gaps。反例：002完整语法结果已足而041缺SSH尺寸证据，合并卡无法准确表达002的独立推进。
3. **LC-PF-003 / minor：021父项写成WP004。** 原 `docs/tasks.md:207` 为WP-005。修正父项；迁移时明确保留原010/020的M1依赖（候选输入列表未列，旧权威仍含），不添加027或最终041反向边。

详细反例、权威引用和最小修正在 `findings.json`。DQ-02/03/08/11/12存在文档失败，其他检查仅在planned规划范围通过，见 `dq.json`；不能以总分消除失败。

## 逐项核对与边界

| 原任务 | 结果与独立交付边界 | 输入、文件与检查入口 |
|---|---|---|
| 008 | C002保留成功baseline与安全停输；不重做M2 | 消费R10/070、152/117/112/122/162；Application/Frame/native唯一writer；计划 `tests/output_recovery/run.sh`，实际编码逐截断表由测试作者冻结 |
| 010 | 可见层完整Frame/文件，旧副本不反改；LC-PF-001修签名 | 084/112/107/088及应明确097；Application.snapshot与Frame既有文件方法；计划 `tests/visible_snapshot/run.sh`，空网格独立ANSI消费、NUL/目录/不可写/短写异常 |
| 020 | M1全模式恢复输入、M2后仅受影响复验；不是提前完整PASS | 008+152/117/122/112/162+I015；Application/native同owner；计划 `tests/session_lifecycle/run.sh`，原光标Known/Unknown、2004/title、termios/signal/资源与双错 |
| 021 | U1–U5公开应用，可独立源码便利性及交互验收 | 原010/020 M1交付与完整功能输入；examples/minimal、composition、tests/composition；build、直接smoke和真实按键分开，LC-PF-003修父项 |
| 027 | 仍在theme唯一任务，C006细化可回链，不建第二状态 | 正式输出 `examples/theme_showcase`；依021及026/019/028/029/037；当前具体控件L4待上游固定是合法planned缺口，ready前补齐 |
| 001 | 平台/TTY/权限/尺寸/模式支持矩阵；应独立原任务 | C007/C008与已验证平台部分输入；具体输出落点需按LC-PF-002明确 |
| 002 | 原始CJPM语法正负例、错误定位、编辑器限制 | C007；不是stub/转写后源码；可复用未变化语法证据，不要求为最终汇合重复执行全部例子 |
| 003 | 直接/传递依赖版本、ABI/native闭包、普通干净消费与许可来源 | C007/C009；保留实际许可证，不恢复用户已否定的许可冲突阻塞；正常stdx/TOML前置须进入产品说明 |
| 004 | U1–U5逐签名/模块/错误/生命周期契约 | C007与各正式design；已裁决范围的最终核对可execution；改变产品契约仍需重开决策 |
| 041 | 可冻结M1设备子接口、M2后汇合最终全部宿主AC | C001/C008及L005；不能把147作为M1子输入的前置，完整041仍pending至最终实证 |
| 023 | 完整正常源码cjp与新cache消费 | cjpm.toml、check-product.sh、check-bundle.mjs；正式 `scripts/check-product.sh release`、直接binary实际exit、缺包/退出负控 |
| 024 | 逐原AC/细条/NFR整体验收，非产品实现 | 固定source/cjp/examples/benchmark/tests/docs/raw；Linux-final证据、whole-branch review及机械投影，保持无publish |

上述计划run.sh属于未来交付物，不声称当前已存在/执行。缺最终来源固定SHA可以保持planned；各L3真正ready前才补固定合同/test/product输入、可运行命令与技能可用性，不以完整产品成为编写计划前提。

## 重点依赖与现有123–162接口

- **L005无环：** 008/020的实际M1恢复 → 完整功能M1库及041已冻结设备子接口 → 124起M2 → 147 → 完整041/020变化复验 → 023/024。M012明确124前不要求尚未交付的benchmark源码；143/144交compat/workloads及新库诊断入口，146计量前再冻结相同业务源。
- **L006无环：** 084 → 有限148–152 → Glyph/Theme → A098–102 → B/C →117/122。152消费现runtime/R10/固定子合同，不依赖A；未来A的I015查询使用同writer。152不关闭完整030/020/041。
- **021→027单向：** 021明确不等完整027；027复用021，M1冻结前汇合二者。原021的010/020依赖在旧权威仍有效，转移不能遗失；020只要求M1子输入，不要求最终041。
- **无重复功能：** 008检查最终M1的writer/baseline，139–142负责M2局部合成的对应边界；最终复验仅针对影响。027展示只消费153–162基础/菜单控件，不能再实现控件。023消费143–147产物，不能另建benchmark。030仍由152+117+122及真实host/paste/cut汇合。
- **S008未被弱化：** C002明确任何partial+fatal即进程期unsafe，停止frame/mode/title/clipboard，非输出native清理、保留首错、同进程reopen拒绝；zero+fatal结束本run但不无故置partialunsafe；短写续写完整成功仍成功。不能用内存后端再present冒充TTY安全恢复。与S008、I015、K004一致。

## 产品范围与细条覆盖

候选未删除任何34项Linux原AC（001–032、037、041）。C007/024要求未来逐项矩阵，不把现在矩阵尚无产品证据视为设计失败。已验和现有正式功能任务继续提供基础证据，收尾消费及组合归属如下：

| required族 | 既有功能证据归属 | 本候选最终汇合 |
|---|---|---|
| REQ001.1–.10 | 002/004、runtime、rich、theme、interaction、editing、widgets | 002/004、021 U1–U5、027、024；源码公开性/同组件复用/不手动flush |
| REQ002.1–.9 | runtime 015/016/032、theme026、interaction、editing | 020重启清理、021后台/业务/局部态、027不重建状态、024 |
| REQ003.1–.11 | 011/012、017/018/019/037、editing/widgets | 010可见层/滚动/遮挡、021组合与窄屏、027、C008/041、024 |
| REQ004.1–.8 | 005/007/008/020、022/031、123–147 | 008完整输出事务、020恢复、C008、023/024；不把行差分当M2 |
| REQ005.1–.6 | ansies/R10、rich009、Glyph、010 | 010逻辑完整文件及失败、C008自动降级、023产品说明/024；LC-PF-001修精确接口 |
| REQ006.1–.5 | 原交付契约、theme/benchmark项目 | C009/023实际包和正常消费、024；版本0.0.0，无publish |
| REQ007 / NFR06 | AGENTS/DQ/Battle、各正式任务角色 | 单权威、原件hash/版本、限定复用、024whole-branch；本轮发现需修 |
| REQ008全部 | theme013/025/026/027 | C006全四主题/状态与reload、021/023/024 |
| REQ009全部 | 117/122、157/162、017/037 | 021真实编辑/快捷键、020模式、C008真实宿主、024 |
| REQ010 extension | 148–152、117/122 | C001/C004/C008/024真实结果和剪切粘贴；NoImageAdapter/Unsupported不冒充核心失败或成功 |
| REQ011全部 | 001/003/004/041、Linux本机依赖 | C007/C008/023/024；其他OS后续required，非本轮前置 |

NFR-01→021/027便利性；NFR-02→010/008/层/字符确定性；NFR-03→既有Frame预算、Runtime订阅/资源、富文本/键盘有界解析、Theme T009与020释放，024逐条核其固定证据；NFR-04→runtime唯一UI调度、021真实后台及020生命周期；NFR-05→143–147公平的M1/M2 CPU/Cell槽/heap/GC/RSS/output和负面负载；NFR-06→DQ/错误/唯一职责与复用；NFR-07→C007/C008及后续OS边界；NFR-08→C001/C009源码包/正常消费、无产品开发工具依赖。没有新设FPS、权限采样器或全进程精确分配字节门槛。

U1最小styled Text；U2菜单/主体/状态条/主题；U3真实后台动态状态、短长文本与颜色；U4同组件普通容器和弹层复用、圆角阴影、菜单及嵌套modal；U5不同业务、公共primitive、无内核特判。C005逐项存在，两个明确入口/场景可覆盖，不要求虚构五个项目。C003包含实际稳定主树+层+viewport、装饰、透明/样式空白、旧Frame副本及文件失败；不是终端差分文件。

C008指定真实XTerm、VTE、tmux、screen、Linux VT、SSH通路，同一最终公开源/脚本、原bytes/事件/尺寸/配置/能力来源/termios/exit/原PNG及hash。mux/SSH可用外层真实host原图但记录内层进程；不换TERM或从ANSI重绘。SSH resize未证诚实保留；必需证据缺失不能宣称完整041。C006另要求至少一真实GUI四主题同内容/尺寸原PNG；自动降级不要求跨capability像素相等。

## C009与现有脚本

静态查看当前check-product.sh确认：release使用正常cjpm bundle，但干净解包只新目录、不显式新cache；示例以 `cjpm run -- --smoke` 包装，benchmark以 `cjpm bench`，未取各binary真exit。check-bundle.mjs已有实际tar路径/文件边界、manifest相对依赖检查，但required列表尚未覆盖四主题/showcase/compat/workloads，allowed也尚未放行themes。候选023.a–d明确安排这批必要修正和缺项目/包装退出负控；这属于未来任务的准确现状输入，**本轮不另报产品缺陷、不执行release**。最终正常source包不含开发脚本/tests，checker在开发端检查/解包，产品用户只需公开SDK/stdx/TOML/native前置，职责一致。完整release不等于repositorycheck、单bundle或manifest include字符串。

## 单一权威切换的足够条件

不需等未来产品完成。修正并定点复核以上Important文档项后，可在一个可恢复提交中执行：

1. 将本change从“候选未接管”改为明确已接管规划/执行状态；保留所有原编号。001/002/003/004/041按LC-PF-002独立记录，008/010/020/021/023/024按本change卡片。
2. docs/tasks对应旧复选框/活动status改为编号、父项/需求及指向唯一tasks的引用；历史设计/证据可保留但标历史或只读映射，不能再维护第二进度。保留原021的010/020 M1依赖，原003许可裁决继承AGENTS13.3。
3. 027保持theme/tasks唯一状态，在该原卡追加或引用C006的正式L4/输入，并明确021单向依赖；本change只链接027，不加复选框。022/031、030及123–162权威不动。
4. docs/acceptance仍唯一验收事实，计划切换不改变pending/pass；各功能有限既有结果原貌保留。总计划/progress只索引事实，不复刻状态。
5. 切换文档自身可以完成；各产品卡仍planned。之后逐卡按实际依赖、固定SHA/test、具体命令、技能可用/角色记录和DQ全通过进入ready。不得把“通过规划preflight”自动投影成产品ready。

技能来源复用R11记录及AGENTS14可定位；该记录不证明本轮新环境全部工具已验证。计划作者/代码/审查/验收按实际阶段使用相应技能；纯文档冻结/原件投影不制造假RED。本审查使用只读接口核对及verification-before-completion核工件，不运行无关功能套件。

待办仅为上述文档最小修正与定点复核；不要求新产品实施、重开已验单元或全量套件作为本轮规划关闭前置。

最终只读核对：主仓在其他工作推进后HEAD为 `b6f3e2afd1d8fbc183f6af51f4858e50d7ac363c`，工作区clean；本轮固定受审仍为上述df9612e完整SHA。受审31份文件最终均与固定SHA一致。 JSON解析、3条finding及14项DQ数目核对通过。
