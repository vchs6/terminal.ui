# TASK097 前读待证据矩阵

仅待证据；未实际验收，不代表 ready/PASS。按合同义务划分33项，与既有单测数量无关。

| ID | 合同 | 义务 | 待核证据 | 状态 |
|---|---|---|---|---|
| G97-01 | AC093–097 | 固定来源与独立性 | 产品/base/root/测试lineage、096实际源/二进制/依赖/配置完整hash；不使用作者自评。 | pending_evidence |
| G97-02 | AC093 | 正式RED与fixture修正 | 旧正常build与真实缺API/internal RED；原11 Observable/capture1设施RED保留；bfd/dc6仅getter/counter修正，原oracle不降级。 | pending_evidence |
| G97-03 | AC095 | 独立代码审查复用 | 095固定18文件、spec/quality结果及hash；095仅代码范围，不能替代096真实宿主。 | pending_evidence |
| G97-04 | AC096/G002 | 正常SDK及公开兼容 | SDK1.2.0根/普通consumer build及binary直接exit；两构造/legacy参数、enum/reexport、set/get签名。 | pending_evidence |
| G97-05 | G002 | 能力只读正负控制 | 完整API正向先成功；六字段各var-local写入拒绝；构造包内、无公共bitmap。 | pending_evidence |
| G97-06 | G002/G004 | 探测生命周期与事实 | 每成功run open后cleanup围栏内一次；Unicode/Ascii仍探测；离线不探测、关闭后last保留。 | pending_evidence |
| G97-07 | G004/G011 | 具体stdout VT身份 | isatty/fstat/S_ISCHR/major4 minor1..63/VT_GETMODE/KD_TEXT；实际fd1，alias/PTY/非文本不读map。 | pending_evidence |
| G97-08 | G004/G011 | 有界unimap与释放 | 65535 pairs/262140临时bytes一次alloc/read，8192 bitmap副本，所有退出free；重复原pair计数与空map有效。 | pending_evidence |
| G97-09 | G003/G011 | 失败诊断分类 | 闭集source/reason、errno、entryCount0；真实kernel失败与controlled syscall/PTY注入分别标注。 | pending_evidence |
| G97-10 | G005/G010 | policy所有权与预算 | 唯一生产policy/factories；mapped长度8192、防御复制；width0/负值/合法正预算，无固定width<=2。 | pending_evidence |
| G97-11 | G003/G005 | Ascii及mapped投影 | 单可打印ASCII或mapped单BMP单列gate；宽/CJK/组合/VS/ZWJ/非BMP整簇等宽，无NFC或业务改写。 | pending_evidence |
| G97-12 | G005 | 装饰与缺备用字符 | 共享border数据；专用ASCII→?→空格有限回退，empty/no-question/no-border真实bytes和diagnostic。 | pending_evidence |
| G97-13 | G012/A003–005 | 未知PTY保守Unicode | 唯一displayWidth逐scalar与Cell.width相等放行，否则整簇?；保留类/替代类、true宽策略与零面积边界。 | pending_evidence |
| G97-14 | G006 | 生成marker纯接口 | 真实generatedEllipsis、ambiguous false/true、mapped/missing、可用<=0/1/2/3/5；字面…仅原width投影。 | pending_evidence |
| G97-15 | G007 | 单一布局policy接线 | 设备private produce与离线入口解析；同一renderLayout，无第二snapshot/Frame/布局内核。 | pending_evidence |
| G97-16 | G007 | 缓存与mounted交替 | Unicode/Ascii/Auto交替snapshot及mounted render，marker内容cache key与measure失效，节点身份保留。 | pending_evidence |
| G97-17 | G002/G007/G008 | 模式唤醒与pump时序 | actual-change唤醒/布局失效、同值静默；pump中修改使用实际旧policy基线，下一refresh不丢更新。 | pending_evidence |
| G97-18 | G008/A004 | 投影列等价diff | 中→文、宽簇↔两个?及空间替代，old/new各profile；style投影共同等价零bytes。 | pending_evidence |
| G97-19 | G008/A004 | 输出与基线边界 | 宽→窄/缩短清残留、尺寸变化重绘；仅全写成功提交logical/profile，零面积不遍历巨轴。 | pending_evidence |
| G97-20 | G009 | 离线文件独立 | 默认/显式Auto=Unicode、Ascii仅生成marker；实际plain/ANSI文件完整Unicode且不受设备/最近map污染。 | pending_evidence |
| G97-21 | G001/G009 | 原回归与唯一权威 | 固定Frame/颜色/富文本/runtime回归与源码关联复用；业务跨span、clip/continuation、颜色事实不污染。 | pending_evidence |
| G97-22 | S008/G008 | 失败安全与资源恢复 | 唯一writer/unsafe/reopen/zero-byte-safe-title/silentclose/首错聚合；失败后无后续设备输出；nativeclose、termios、signal原件。 | pending_evidence |
| G97-23 | AC096/G001/G004 | NEW真实kernel VT来源 | 新产品真实kernel/tty1，kernel版本/UID/major-minor/KD_TEXT/source/binary/config/viewport/UTC；非旧6a7b、TERM换名或合成VT。 | pending_evidence |
| G97-24 | G001/G004 | UTF8输出前置 | 实际boot默认+未改codec链+已知UTF8 native cells与原PNG经验对应；IUTF8/键盘/fontmap均不能单独证明。 | pending_evidence |
| G97-25 | AC094/096/G003 | 真实VT普通Auto与override | 同普通Application业务源无终端if，Auto fallback及Unicode/Ascii；原始map/字体来源、权限、诊断facts不被override改写。 | pending_evidence |
| G97-26 | AC096/G009/G012 | 真实GUI物理输出 | 真正XTerm/VTE版本/config/font，同实际源/二进制；native物理数据和原PNG，保留/替代类与delta不越行。 | pending_evidence |
| G97-27 | AC096/097 | 原图和原生数据独立核查 | 两类实际render profile代表原PNG亲看并hash，全部PNG来源/退出后封存；host观察器与产品分离，不用逻辑宽度模型作物理oracle。 | pending_evidence |
| G97-28 | Session152 P30/REQ010/011 | 有限真实VT Session组合 | 当前产品普通Session例/正式consumer实际copy/title/restore/icon，NoAdapter或Unknown发送未确认诚实，永不因OSC wire推Applied；仅已证subset可闭合。 | pending_evidence |
| G97-29 | AC096/G009 | 正常bundle lint | 正常cjpm bundle实际命令/exit和warning计数，无skip、压级或suppression；保留advisory。 | pending_evidence |
| G97-30 | AC096/097 | 全CJP及cleanconsumer | 143实际regular members逐bytes对fixed git、全inventory；clean普通consumer仅manifest路径改，实际源和binary/exit。 | pending_evidence |
| G97-31 | AC097 | strictJSON与制品封存 | 全部原件/curated/hash及命令cwd/UTC/exit；host退出后final hash；omit ELF/CJP/CJO/SDK/cache/整checkout/私钥/Markdown源快照并记录外部hash理由。 | pending_evidence |
| G97-32 | G006/AC097/Theme013 | 后续Theme输入边界 | policy/marker/context可交013，085实际端到端追加后准入；完整ellipsis前缀与布局仍待013/085/088。 | pending_evidence |
| G97-33 | AC041/P30/M2/AC023–024 | 父范围与发行边界 | 本097有限glyph不关041全部输入/resize/恢复/全组件、020/008/027/010/M2/Linux/跨OS/发布；whole checker缺composition/benchmark exit1保留。 | pending_evidence |
