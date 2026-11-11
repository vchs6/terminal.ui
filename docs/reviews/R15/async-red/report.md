# TASK089 actual async-only RED

**Strong async-only missing-API RED 已取得；测试资产未改，无新commit。**

受检实际产品source：`8d75233c664fd61be08d441f74d464cbcdff2d9c`，独立clone `/workspace/work/theme-load-actual/source`。冻结测试资产引用 `179c851cd38cdb5f08dbd643b7f549da9707ee65`，`tests/theme-loading` Git tree为 `441cfd4da54c26fdad394df94bb633476d2a61e1`，与受检source中tree相同；不制造新的test-only提交。Git工作树干净。

## 两条实际命令

cwd均为独立source，先source `/workspace/work/theme-load-actual/env.sh`：

```sh
./tests/theme-loading/run.sh foundation --logs /workspace/work/theme-load-actual/raw/foundation
./tests/theme-loading/run.sh async-probe --logs /workspace/work/theme-load-actual/raw/async-probe
```

| 实际步骤 | exit |
|---|---:|
| foundation命令：gate C build / ordinary foundation CJPM build / direct binary | 0 / 0 / 0 |
| foundation命令整体 | 0 |
| async-probe命令：gate C build / ordinary foundation CJPM build / direct binary | 0 / 0 / 0 |
| async-probe命令：独立api-probe普通CJPM build | 1 |
| async-probe命令整体 | 1 |

两次真实foundation binary均输出 `PASS real foundation gate; async-specific probe is now meaningful`，实际验证Theme.parse、typed textDefaults/value只读桥、Application(theme:)及红色文本像素。不是旧foundation缺包、SDK或配置错误。

api-probe产生7条明确语义诊断：两处未声明ThemeRequest、一处ThemeInfo、一处ThemeResult；Application没有loadTheme、reloadTheme、themeInfo。没有词法/语法错误或legacy API缺失。这是相对于已真实通过foundation gate的**异步公共API缺失RED**，不是22项异步行为的运行失败。冻结probe也引用ThemeSource；该符号没有独立打印诊断，本报告不把它单独冒称已负向核验。

原始精确argv/cwd/UTC/受检SHA/exit及分开stdout/stderr在 `raw/required-commands.jsonl`、`raw/foundation/commands.jsonl`、`raw/async-probe/commands.jsonl`。关键诊断为 `raw/async-probe/async-api-build.stderr`。未运行consumer或infrastructure模式，未编译/执行22个行为case；不标任何async GREEN，也不声称全局worker/mailbox容量、锁序、overflow、设备失败等不变量已验证。

## 环境、输入与保留

SDK/cjpm实际1.2.0；官方stdx1.2.0-beta.02.1，实际解析路径为 `/workspace/work/linux-build-recon/stdx/cangjie-stdx-linux-x64-1.2.0-beta.02.1/static/stdx`。产品依赖cangjie_toml0.2.3、ansies1.3.113、unicode0.1.0、unicodewidth0.1.113。自有cache从既有独立测试角色cache复制到本目录cache，忽略registry配置复用18973，无新relay，无作者target/cjo或产品作者目录输入。环境/配置/源码pre-run hashes和SDK输出均在raw。

已读冻结README、runner、foundation/api-probe、consumer22场景、generator及native普通File I/O gate；未读取原作者报告/自评或产品作者工作树，也未通信/派生代理。35个实际source/input文件预先hash，fixture字节仅生成取hash而未运行行为；final-source-correspondence逐项确认执行前后相同。原22case、场景表、普通文件gate基础设施和全部旧预期保留。

canonical root合同SHA为 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`。accepted checkout内合同文件整体hash不同，但相关§2.2、§7、T006–T008逐字相同，已独立比对记录在environment-facts.json；未改合同或将文档差异当执行阻塞。

runner按原实现编译本地LD_PRELOAD gate库，但foundation/async-probe模式没有运行受控I/O行为或替换生产库。没有fake Theme/worker/future、声明stub执行、新public计数器或生产hook。未跑旧全suite/host矩阵，未重做准备资产或复制archive；没有product/contract/status改动。剩余22case实际执行及090源码不变量审查、091正常制品/行为/设备验证仍待026固定产品，本文不替代后续090–092。
