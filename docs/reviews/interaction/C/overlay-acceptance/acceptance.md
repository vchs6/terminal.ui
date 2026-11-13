# TASK112 — PASS_FINITE_UNIT_C

独立有限验收：固定产品 `7f43176505aa3c392afc5fc897181a9eeba89e6e` 满足 C-01–05；可交下一单元。依据正式合同、108固定测试、110独立审核及111原件，不以作者自评或测试数量替代义务。
来源/完整性：111 `stablemanifest.json` SHA256 `cda293604be2e912103e0358c3fcd28f7c24af4511337b591d1036ee0a592ad2`，本角色核4639原件/433699788 bytes及report hash均0差异；156产品入口/源码当前字节等于7f。引用、具体raw与限制见 `evidence-index.json`。
源码层：110初审10 Important由R1关闭，R1新增2由R2关闭；R3逐11项lint RHS等价改写审查PASS，无未决C严重缺陷。旧版本源码按各git head验hash，不拿当前文件冒充旧字节。
工具/制品层：SDK1.2.0，111正常 `bash tests/interaction_c/run.sh`、mandatory `cjpm bundle`实际0；strace确认 `cjlint -f src`，warnings保留，bundle内TOTAL0不替代正式C执行。CJP `49dabd23f71bb7c8ede00949fbc836afef6875130d732dc6e9a0177deecc247f` 的220成员逐字节等于7f。
干净消费层：完整C与examples/overlay fresh build/direct0，仅三个manifest依赖path改变；完整C297断言的raw与正式C去build行后完全相同，产品/例子无开发目录运行依赖证据缺口。本结论不关闭最终023制品总验收。
设备层：独立PTY五模式及XTerm398/VTE0.80.1/QEMU10.0.13内Linux6.12.107 VT各五模式，真实进程exit0、termios相等、关闭cleanup/异常身份顺序与域trace成立；51张成功原PNG有固定hash。
身份边界：formal/H01/clean用测试 `3fcba825`（7469别名），H01 ELF `087db920…27d68`；新增native-caret测试 `eea178fe` 在7f组合 `abd0ef62` 的另一个ELF `a4663f3a…1ce3c0` 跑三宿主。clean未执行新增caret，旧H01未改签为新ELF。

| 有限义务 | 原始证据映射／判断 |
|---|---|
| C-01 PASS | D01–10、H01：三级modal/popup/confirm，app/legacy零调用、域外FocusOutsideDomain、Escape屏障、prevent与interrupt；111正式及真实PTY/三宿主。 |
| C-02 PASS | F01–13/L01–08、C-I01/02/03、R1-I01：I014空层保留、owner hidden/unmount/disabled区别、完整闭包先撤销、兄弟保留、一次恢复；普通删除NEXT与modal删除FIRST实证。 |
| C-03 PASS（I015能力边界） | G01–16、X01、C-I04/05/06/07/10、R1-I02：透明/opaque/主题/host/anchor/宽簇/阴影及最新底层；T008失败保Old/活动session及预检不调用用户求值由110源码复核。三宿主新caret原生8×3网格、逻辑visible→hidden→restore；XTerm/VTE真实reply1及hide/show/CUP，VT Unknown零25h/l/s/r。 |
| C-04 PASS | P01–05/E01–18、X02/C-I08/09、L05/08/H01：pending/重复挂载/上下文/错误/预算/cleanup及native异常恢复；弱保留依据110源码，GC观察不算确定性证明。 |
| C-05 PASS | S01–03/N01–06及干净完整消费者/例子：同SettingsPanel类型两实例共享model，children排除层根、绑定/身份/滚动状态按合同保持，无私有hook。 |
| 父TASK018完整AC | “父层关闭清子层、模态隔离，原焦点失效时回退且下层显示最新状态”。依次映射C-02/L01–06、C-01/D/H01、C-02/F08–13/R1-I01、C-03/G04，四项均PASS，可建议主代理关闭018原AC范围；本角色不改权威任务。 |

不足/残余：VT物理caret隐藏为 **insufficient_evidence**；I015明确Unknown不得发显隐命令，故实际零命令且逻辑遮挡正确满足有限C降级义务，不能声称物理隐藏成功。VT是VM，非物理硬件；官方共享viewer未验证。
历史保真：f331 bundle1的11 mandatory错误、错误baseline编译1及采集器失败保留原件；最终7f对应证据已成立，未把历史失败改成PASS。108类型/depth/主题fixture纠正有独立合同说明与旧oracle原件，正式7f完整断言均到达。
历史限制：R1/R2引用的作者可变manifest旧SHA `71a28…`/`7d8b…` 无旧快照，不能直接复核该旧索引；当轮独立110清单直接绑定pure raw，源码可由git复核。外部124编译中间件：121清理时同原hash、3此前被后续build覆盖（libcjtui.a、interaction_c.cjo、cjtui.cjo）；不声称旧.a/.cjo自包含，不影响保留的probe/raw和最终111独立证据。
边界：B-M01 getter axes/onMount Off继续deferred024；019菜单/标准Modal、027完整主题展示、020完整恢复、028/029/030、023/024、M2、Linux整体与其他OS不随本结论关闭；H02跨层paste待Keyboard117。当前有限C无阻塞残项。
本角色只读核原件/合同与最小hash索引，复用有效suite，未运行产品、重建、改测试/产品/规格/main、归档或派子代理；prepare历史保留。实际serving模型不认证。技能使用沿prepare记录的verification-before-completion及AGENTS §11.1。
