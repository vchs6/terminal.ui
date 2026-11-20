# A001–A008 不确定推进的设备投影契约（已冻结、有限范围已验收）

## A001 事实、授权与选择

实测输入固定91c22f82adcd2412d9509b9872ff63450ba81af9。TASK083 /workspace/work/rich-text-execution/report.md FAIL R14T083001；/workspace/work/terminal-width-recon/report.md为独立因果证据，116完整DSR/34原PNG/实际恢复，未改产品。两host：单👩/💻/界=2、e+0301=1、🇨🇳=2；👩‍💻实际4而产品2；❤️/☀️/1️⃣实际1而产品2。原delta逻辑前缀11+89空格实际13+89=102，第4行col3，原PNG证实AN被清；完整帧随后CUP4重画仅掩盖问题。单独减2padding或用界替该簇能阻止覆盖，不构成完整产品修复。

用户明确普通程序面对丰富终端由框架自动降级，AGENTS15亦授权；本工程决策不新增用户业务选择或等待既有授权。root比较：改变全局宽度为4被单emoji/VS16反证；会话逐字形物理测量需新查询路由、超时/缓存/临时绘制与布局政策，没有全面证据；持续全重绘/改示例/减固定padding只掩盖；改宿主自动换行模式不能解决逻辑列/原态恢复。选择canonical格网内有界保守呈现：不变Unicode数据，只有实际终端输出可等宽替代。一个探针不泛化所有Unicode，宽度模型一致也不是字体覆盖证明。

## A002 唯一owner与最小接口

提前实现已规划G005/G007/G010的同一包内owner，不建立平行字体/Unicode/renderer内核。文件与接口：

- src/glyph_render_policy.cj：一个不可变包内class GlyphRenderPolicy；包内static factories `unicode(): GlyphRenderPolicy` / `conservativeUnicode(): GlyphRenderPolicy`。构造不公开，不需公共测试setter，内部字段由实现选最小表达。此批仅两个policy，后续094沿同类加入ascii/mapped，不能并存另一policy。
- src/terminal_glyph_projection.cj：内聚纯函数 `projectTerminalGlyph(grapheme:String,width:Int64,policy:GlyphRenderPolicy):String`；生产实际调用。width0返回空，负值IllegalArgumentException；正值来自已验证Frame起始Cell受其maxCells预算，不能加固定<=2上限或用不可达Int64.Max制造OOM测试。
- 现src/terminal_render_profile.cj的init旧参数之后追加named `glyphPolicy!:GlyphRenderPolicy=GlyphRenderPolicy.unicode()`，保存readonly同名字段。snapshotProfile保持默认Unicode；现src/terminal_capabilities.cj terminalRenderProfile设备工厂显式选择conservativeUnicode，颜色override/颜色source/reason不改。
- src/frame.cj原full/diff终端编码/比较只接同一投影。必要纯row helper可放src/terminal_projected_row.cj，使用现Cell/Style，不创建另一个Cell/Frame或持久缓存。一个新实体一个文件，纯函数内聚。

无公共GlyphMode提前实现、无Bitmap/nativeVT/FD读取/生产DSR/时钟/25或7模式修改；094仍单独完整实现其已冻公共API和实际VT。此批借用纯内核子接口不等于094通过。公开文本/Frame API、依赖/SDK/宏签名和预算不变，产品0.0.0。

## A003 精确保守规则与边界

Unicode policy原样返回正宽簇。conservativeUnicode按已经存在的grapheme逐scalar枚举，用现唯一 `displayWidth(scalar.toString())`（unicodewidth同版本默认ambiguousWide=false）求非负和；只有sum恰等于已存Cell.width才原样输出，否则返回width个可打印ASCII?。width0仍跳过。当前device/runtime采用false；公开Frame已有ambiguousWide!:Bool，包含true的构造/格网/离线Unicode行为原样保留。本conservative设备admission固定用默认false逐scalar和与所存Cell.width比较，不强改Frame参数、不重新计算Cell.width；直接同包profile用于Frame(true)时，若二者不等仍按其已存列数fallback。不新增公共宽度模式/Unicode表/分簇算法，不重新分段grapheme。checked/saturating相加，超过width可提前判不等，不能回绕后误放行；正常调用正宽预算与Frame一致。Frame已有完整文本安全验证继续是控制安全边界，不造unsafe String。

例：e+0301 sum1=logical1保留；界/单👩/单💻 sum2=2保留；🇨🇳按唯一库逐scalar和与logical2相同则保留（以真实库实测为准，不硬编码旗帜规则）；👩‍💻 sum4!=2→??；❤️/☀️/1️⃣ sum1!=2→??。最终golden先由独立测试作者验证实际依赖scalar值，若不同回root精确化，不能硬编码emoji清单适配示例。测试必须区分模型一致/不一致与实际host已测事实：sum相等只表示两种库计算在当前cell预算上一致，不证明未知host每个单scalar或字体的推进，不声称所有Font/Unicode版本宽度皆可靠。受支持实际配置以真实host/version/config证据冻结。

样式/逻辑列数不变；不删除VS/ZWJ/重音，不NFC/NFD、不音译、不禁用全部emoji。替代是整簇原子可见呈现，不改Component/RichText/Frame.cellAt/toPlainText原业务Unicode。普通应用不写终端分支。显式离线Unicode和未来GlyphMode.Unicode仍直出canonical宽度数据；这不是对不相容host物理形状的证明。默认Auto不要求调用者覆盖。

## A004 full/diff必须比较同一投影

每个逻辑head按同一helper投影，continuation不重复输出。保留原Unicode簇时仍为原width head+continuation；fallback转换为width个width1的?列（同Style）。比较的是实际投影的canonical列及既有projectTerminalStyle结果，不是raw业务grapheme或原head/continuation结构。ZWJ A→ZWJ B（同width同Style）两侧都是??则零屏幕bytes；ZWJ→字面??、反向亦同。style变化仍输出，颜色映射后Style相同沿R10零输出。policy切换也对old/new各按对应policy投影再比较，不能仅identity强制整屏，不能复用旧raw未投影baseline；尺寸/成功基线/partial-error原规则保留。

full生成与changesSinceForTerminal共享该语义。允许每行临时有界投影，不存整份第二Frame/第二Unicode缓存。零面积/历史极大空轴必须沿现早返回，不按height分配/遍历；不为Row投影增加超Frame预算的持久state。后续M2 policy key纳入此variant并比较真实列，仍同一内核。

## A005 离线、应用与后续Glyph衔接

公开displayWidth/graphemeClusters和Frame格网不变。Frame.toAnsi/writeAnsi/changesSince原snapshotProfile默认Unicode不改原字节；原严格String、typed spans/style precedence/bindings不变。Application.run实际device profile默认conservativeUnicode，包含显式colorMode入口，颜色选择不能绕过字形安全。示例业务源码原样，不能只换emoji、增加terminal if或禁用局部刷新。

修订Glyph G003/G005/G010：未来GlyphMode.Auto+未知PTY→conservativeUnicode（取代无条件Unicode直出）；Unicode显式→unicode，Ascii→ascii，Auto已证VT按原mapped/Ascii。检测facts TerminalGlyphCapabilities原字段/errno/reason仍原样，不因override或保守选择伪装map/Font已证；策略说明从mode+facts和产品文档可定位，不新增公共诊断字段。G010私有conservative factory加入同一类；G006生成ellipsis在保守policy下仍仅当实际ambiguous policy使…为1列才用…，否则ASCII，不能因新privatekind丢失既有marker规则。

此补丁164是纯projection先行，不等全部094公共API或nativeVT，094必须消费167接受source并补齐其原scope/093实际测试。R14 083/084等待本真实GUI修复/复验，167不能由仅逻辑模型PASS关闭；不存在084→094→084环。Session149继续等084。Theme/M2后续消费同一policy；不提前关闭041/010/Linux。

## A006 验证边界与正式RED

163独立测试：正常old91 build0；old实际083原PNG+DSR物理RED已固定，不能因同一逻辑width模型通过叫PASS。新增同package纯profile/投影/full/diff测试（正常临时source副本+CJPM test，不扩大可见性），手写??/原字符串/style/列/结构等价/zero output/policy switch/零面积/宽簇边缘。新privateAPI在old源码missing编译RED与真实host行为RED区分。原Frame/Unicode/颜色旧断言不擅改；需要期望改变仅限明确deviceAuto规则并标合同来源，不能改逻辑Unicodegolden迎合实现。

物理回归用固定原examples/rich-text（或独立公共consumer同内容）的初始/t/t/resize/t/q，实际XTerm/VTE原PNG和DSR完整回复/原bytes、4行内容与未修改第4行、真实termios/exit/config/version/source/binary/time/hash。native/replay fixtures可测宽度但不是产品修复；正式新源必须真实验证。至少覆盖ZWJ及VS16两种相反误差、单emoji/CJK/组合/flag保留；不能只验证库宽度和ANSI解析模型。原始FAIL保留。

166独立执行对164固定source跑163+受影响Frame/color/runtime路径，正常bundle含lint和清包consumer；原包缺composition/benchmark仍保留为未来release，不冒充本补丁新gate。原083成功且来源/语义未变的范围按AGENTS11.1复用；变化profile/编码涉及的actualGUI/颜色/差分必须补准确覆盖。不因角色改变全量冷跑。

## A007 角色、文件与任务范围

独立163测试Sol/high，164产品Sol/high（仓颉语言适用），165审核Astra/high，166确定执行Sol/medium，167复杂验收Astra/high，各自上下文/目录。root只契约/集成/分歧，不交作者自评。审核fixed技术diff和合同/正式test/raw；失败先formal反例后原作者修，保留全部历史，no subagents。需要新公共API或生产探测协议则回root，不由实现者扩展。

产品说明增加未知终端保守呈现、逻辑原文与设备bytes边界和已证实际host，不称所有Unicode宽度已检测。SDK1.2.0、现deps、不新许可阻塞、不publish。测试/脚本是dev工具，不进产品runtime。

## A008 尚待独立preflight

独立glyph_advance_preflight已对固定1113ba18完成上述接口/DQ检查，design_reviewed无Critical/Important，真实publicconsumer证scalar事实。163已准独立正式测试；164仍严格等固定163测试与真实RED，其他实际source/执行SHA未交付前planned。该设计结论不等于R14物理GUI失败已解决。
