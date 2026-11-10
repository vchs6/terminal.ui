# Linux VT glyph adaptation：独立设计 preflight

结论：**design_reviewed**。固定候选的设计与 planned 阶段分解可接受；未发现需要回交修订的 Critical / Important（Battle blocker / major）缺口。`findings.json` 为独立核验后的空数组，不能解释为产品测试通过。主代理可冻结该合同并启动 TASK-093；TASK-094 仍须等待 080/084 最终固定集成及 093 测试输入，095–097 顺序依赖保持。不得把五项一起标为 ready，更不能关闭完整 TASK-041。

## 范围与证据边界

- 轮次：glyph-design-preflight-d504ca6；2026-11-10 UTC；预算 60 分钟、最多三次修复复核。本轮一次独立设计核验，无产品修复。
- 固定合同：`d504ca6faa2a136179275ec2ed32ab7c7fc496f0` 的 proposal/design/decisions/tasks/specs，以及 AGENTS、ENGINEERING_TASK_DECOMPOSITION、BATTLE_PROTOCOL。
- 已实现源：`0912436b647f701e1de607fe03ce1bfba6a9bbf4`。`git diff --exit-code 0912436 d504ca6 -- src native cjpm.toml build.cj` 返回 0，差异为空。
- 未来合同：RichText `7a33ddc7fb93da3f30007e49538cb00821a2d81b`、Theme `5c150ec36bdbb275c722c970b7cc66ed6a4c8f36`。它们只用于兼容性核对，未视为已实现 API。
- 仅写 `/workspace/work/glyph-preflight`。未改主仓、产品、正式测试；未派代理；未读取产品作者报告或自评。读取的独立草稿仅为正式纳入候选的设计合同，语言原件仅为 api-probe 源码及原始编译日志。
- 本任务为执行型设计审查：既定用户自动降级目标及可逆工程路线的核验，不重新引入用户选择菜单。
- 技能：读取 using-superpowers，依其 SUBAGENT-STOP 不展开根会话流程；应用 verification-before-completion 做本轮证据核对，并按 AGENTS §11.1 复用内容未变化的源码事实，不机械重跑旧 suite。
- 本地不可变输入副本在 `input/`；逐文件 SHA-256、完整 commit 和微验证原件索引见 `reviewed-hashes.json`。复现命令在 `raw/commands.txt`。

## 设计事实与职责审查

| 核验点 | 独立结论及责任段 |
|---|---|
| 普通用户入口 | G002 的默认 Auto 不要求用户选择字体能力；两个既有 init 只追加命名参数，保留旧调用，强制 Unicode/Ascii 为可选 override。诊断与配置选择分离。 |
| 正常 SDK 可行性 | 已独立补充正常 CJPM 静态包与独立路径消费者：GlyphMode 放 style 叶包、根 public reexport、两个构造器、同名 getter/setter、snapshot/render 命名参数、只读 capabilities 返回类型，以及未来 theme 参数并存。SDK 1.2.0 构建 exit 0、直接 binary exit 0，输出 API_SHAPE_ONLY_OK。只证明语言签名/跨包引用；stub 不证明产品行为、实际主题类型或制品可用。 |
| 当前调用链 | 实际源 Application.run 调用公开 snapshot；RuntimeSession.produce 缓存仅 width/height/changed；Frame.changesSinceForTerminal 先比较 raw grapheme/width/continuation。G007/G008、094.S3/S4 准确定位这些需要替换的路径，没有把候选当已交付。 |
| Unicode 与 UTF-8 | G001 以用户既有 UTF-8 宿主前置为界；KDGETMODE 只证明文本模式，不证明 UTF-8 解码。禁止 KDGKBMODE 冒充输出证明、禁止 console 模式写入。G005 整簇处理多码点/VS/ZWJ、非BMP、宽BMP，既不删重音也不加 NFC 内核。源 cjtui.text 唯一分簇/宽度适配仍权威。 |
| ambiguousWide | G006 显式传当前布局宽度策略；只有 displayWidth(…)==1 才选单列省略号。true 时按现依赖使用点串，不能硬塞单列；低层字面 … 保持 Cell.width，不扩成三列。runtime 当前仅 false 可明确传 false，无必要扩大公共宽度模式。 |
| 原生身份与资源 | G004 使用实际 stdout 的 fstat/isatty、major4/minor1..63、VT_GETMODE、KDGETMODE。别名/身份不足保持 unknown，不开其他控制台。一次最多65535 unipair，临时上界262140字节，BMP bitmap8192字节，失败走诊断；系统 linux/kd.h 的 unsigned-short unicode/fontpos 和 entry_ct 与该边界相容。未执行设备 ioctl，也未据此宣称真实VT成功。 |
| map 空、失败与占位不可见 | G003/G004/G005 明确成功0条为 known empty；确认VT后 map失败保守Ascii；身份未确认仍 unknown/Unicode。成功map中 ? 缺失保留 mapKnown，reason=ascii-fallback-unavailable，替换用等列空格；边框备用字符缺失先 ? 再空格。仅证明内核槽位，不承诺像素非空、精准外观或语义恢复。map不可读时ASCII是基础字符终端约定，不能记为逐字已证。 |
| 投影与差分 | G005 消费起始 Cell.grapheme/width，不重分段，不输出续格；G008 用新旧各自 profile 比较同 canonical encodedRow。中→文及中→?? 在相同有效样式下投影相同，应该零更新；现 raw 分支必须退役。宽→窄/缩短仍整行输出以清残留，成功后才提交完整 baseline。 |
| 布局缓存与输出 | G002 setter 同值无动作，变更标 profile 重评估和布局缓存失效；G007 缓存按影响标记的 policy 内容比较，不仅比对象identity。设备 produce 显式 policy，避免默认 Unicode 的公开 snapshot 吞掉设备策略。保持单 Runtime 缓存、单 Frame 与单布局路径，不重建节点/焦点/绑定。 |
| 离线输出 | G003/G009：默认及 Auto 离线 policy 确定为 Unicode，不探测或读取 last capabilities；显式 Ascii 仅影响生成标记，业务 Unicode 保留。Frame 导出接口不带设备策略；设备 Ascii 不污染默认文件。现 snapshotProfile 必须保持离线 Unicode 默认。 |
| 模块依赖 | 公共 GlyphMode 位于 style 叶包、根导出；内部 policy/纯函数可以完整留根包，由根 LayoutNode/Frame 使用。future cjtui.text 只依赖 style/Unicode/SDK/ansies，故不必回导根包。无双 Unicode、Frame、ANSI 或主题内核。 |
| 富文本兼容 | future rich §3 按整篇分簇，Cell 保存原簇与最终 Style。glyph 在 Cell 后投影，不依 span 边界拆簇；094/093 明确保留跨span簇、样式和离线结果。等待084源固定后再落地，消除共享文件并写。 |
| Theme085 与 marker 子接口 | future theme §4.1/T005 已承诺 Unicode宽度/ASCII回退及先预留标记。G006 提供真实纯选择函数和传输上下文；013 承担前缀预算/重排/绘制，085追加场景、088验收。既有两个init的 theme! 原样合并，不新增或改名 TextOverflow/Component API，不改冻结Unicodegolden。 |
| 有限验收 | G009、097明确真实VT版本/视口/权限/map/raw/PNG/hash，未知模拟器不能由换TERM替代。marker函数成功不代表完整ellipsis；093–097不能关闭完整041的输入/尺寸/恢复/全组件/M2/所有宿主和最终制品汇合。 |

## DQ-01–14

以下 pass 是 **planned 设计分解** 的判断，非下游依赖全部已满足的声明。任务进入 ready 前仍按规范核对其固定输入、安装可用证据与实际角色配置。

| DQ | 结果 | 理由 |
|---|---|---|
| 01 层级合法 | pass | 093–097 都是可单独交付的 L3；WP004 为 L2，041仅为追踪父项，本轮不把未完成完整041包装成可关闭结果。 |
| 02 单一目标 | pass | 093固定测试与RED、094一条设备字形/共享policy交付、095审查、096执行、097有限验收，结果可分别判定。094各层修改均服务同一输出策略链。 |
| 03 定义完整 | pass | Shared admission fields 与各任务 Inputs/Scope/Deliverables/AC/L4/状态组成等价任务卡；planned阶段未伪造完成证据。未来技能实际使用与固定输入在角色入场时补齐。 |
| 04 边界影响 | pass | file responsibility map 定位 Application/Runtime/Layout/Frame/native/exports，排除完整ellipsis、字体控制、Unicode内核和其他平台；主题共享文件串行。 |
| 05 验收可判定 | pass | 各L3有可观察输出/独立证据；093覆盖 map空/失败/65535、UTF簇、marker列数/ambiguousWide、投影等价及离线原文；095–097各自证据与不足结论明确。 |
| 06 依赖可执行 | pass | 093可先设计并在旧源做缺API RED；094等080/084/093，随后095→096→097→theme产品，无反向等待theme实现。下游当前不可提前ready。 |
| 07 父目标覆盖 | pass | 本子接口覆盖glyph/有限输出兼容，完整041其他承诺明确保留到最终汇合；没有以本轮范围删除父验收。 |
| 08 无重复冲突 | pass | 复用 Frame/profile/Unicode/装饰ASCII组；未来唯一文字布局归013。测试、产品、审查分离，shared authority files 不并发改。 |
| 09 集成闭合 | pass | 094承担policy从Application到produce/layout/profile及offline接线；097交接013；完整ellipsis由013/085追加/088闭合。 |
| 10 不确定性显式 | pass | map不是视觉/UTF8证明、无NFC、外部字体不监听、真实宿主证据待取得均显式限制；正式API正常消费者仍归093/094，未用shape probe冒充产品。 |
| 11 L4可检查 | pass | 各步骤具固定输入/命令或可观察检查，包含失败与旧路径退役；没有以抽象“测试通过”替代具体投影/缓存检查。 |
| 12 追踪证据 | pass | 本tasks为增量唯一状态，093–097/041及013/085/088接口关系可定位；本轮审查另固定源码与未来合同哈希，不复制任务状态。主代理冻结时再维护全局编号映射。 |
| 13 流程分类 | pass | 已确定方向下execution，决策表记录取舍；OpenSpec目录及各角色所需技能列明。planned没有假称已安装/实际使用；正式ready需补定位后的skill evidence及本报告链接。 |
| 14 质量治理 | pass | 必要性、canonical owner、raw输出/比较迁移、ASCII表抽取、离线保留、状态上界及复杂度增量均明确；无持久数据迁移或隐藏临时平行内核。 |

## 交接与限制

主代理可接受设计并将固定合同哈希和本报告交给093。入场前把角色实际技能可用证据和全局 tasks 编号引用落到唯一记录即可；这是原有准入记录义务，不需要用户再批准技术菜单。094必须用080/084最终源重新核对受影响路径，不能把本次0912436静态观察扩写为最终实现检验。

`findings.json=[]` 仅表示本次合同没有确定阻断缺口。真实 fd/ioctl 的产品实现、不可变bitmap所有权、失败errno、normal bundle消费者、动态 setter/cache/diff、真实VT与未知模拟器视觉结果仍由093–097取得；当前未执行任何这些产品验收，也未重复旧suite。完整ellipsis及全部Linux通过均未作结论。
