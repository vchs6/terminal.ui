# R5 语言与依赖可行性证据

日期：2026-11-09。范围：规格设计所需的隔离调查；不是产品框架、宏、终端驱动或完整 ArkUI 实现，也不完成 TASK-001–004 全部验收。本目录不进入产品制品。

## 环境与重跑

Linux x86_64，Cangjie Compiler / CJPM 1.2.0；SDK 原始归档摘要与 `docs/development/tools.lock.json` 一致，见 `download-sha256.txt`。构建工具版本见 `dependency-logs/tools.log`。SDK、依赖包、原生对象和生成的 Unicode 数据仅保存在隔离工作区，不纳入本仓库。

在已按仓库脚本安装 SDK 并 source 其 `envsetup.sh` 后，从仓库根运行：

```sh
bash docs/reviews/R5/evidence/run-language.sh /absolute/scratch/language-probe
# 在此受管环境，CJPM 网络客户端直接连接失败；以下 relay 保留官方字节和摘要校验。
USE_CURL_REGISTRY_RELAY=1 bash docs/reviews/R5/evidence/run-dependencies.sh /absolute/scratch/dependency-probe
```

依赖脚本需要 Bash、Node、curl、rg、sha256sum、unzip、gcc、ar。普通网络环境可省略 `USE_CURL_REGISTRY_RELAY=1`，使用官方 registry。relay 仅是本次调查的客户端兼容工具，不是 cjtui 的产品依赖或新仓库服务；通过 curl 继承环境代理和 CA，目标限定官方 registry 的公共 GET 路径，不转发凭据。CJPM 仍按 registry 索引验证下载包，本目录另提供四个归档的独立摘要验证。

## 语言实验与边界

| 实验 | 方法与实际结果 | 能证明 / 不能证明 |
|---|---|---|
| 组件块、链、嵌套、条件/循环 | `language/sources/trailing.cj` 编译执行成功；七个根子元素、嵌套子元素、块后及文本属性链均断言 | 原生尾随 Lambda 可承载所需写法；具体框架API、编译期优化和完整 ArkUI 支持未证明 |
| 子元素收集 | 同一源文件通过显式构造栈挂接节点；`plain_block.cj` 验证无收集器时仅返回末表达式 | 子元素归属是框架职责，不是尾随 Lambda 自动提供 |
| 自定义组合与回调 | `Panel` 函数组合复用；保存并调用回调，使 let 绑定业务对象字段加一 | 普通仓颉函数/闭包可支撑基本组合，不代表响应式依赖生成已完成 |
| 绑定初值与重算 | `binding.cj`：初值仍为1，修改对象后闭包读取9 | 需要保留计算规则；并未实现依赖跟踪、订阅或刷新 |
| 未知属性诊断 | `negative.cj` 必须编译失败且定位源码行 | 原生类型检查可诊断未知成员；宏展开后的源码映射仍待验证 |
| 可变局部量捕获 | `mutable_capture_negative.cj` 保存捕获局部 `var` 的回调时编译失败，日志给出明确诊断 | 不得承诺任意局部 var 可直接成为长期保存的事件/绑定闭包；正例捕获 let 绑定业务对象 |

`trailing.cj` 的全局构造栈只是同步语言探针，**不具有并发隔离、协调、稳定身份或卸载安全性**，不能复制为生产架构。

日志保存在 `language/logs/`；重跑脚本检查正例退出码和两个负例失败及源码位置，不把负例失败当调查失败。

## 依赖选型证据

锁定元数据与包摘要见 `dependency-metadata.json`、`download-sha256.txt`；所有包归档与官方索引一致。

| 包 | SDK 1.2.0 实测 | 职责建议 |
|---|---|---|
| ansies 1.3.113 | CJPM 解析、SGR红色与光标定位序列生成编译运行成功，未发送设备控制序列 | ANSI编码与实际支持的回复解析；不冒充通用富文本解析或真实终端兼容验证 |
| unicodewidth 0.1.113 | 直接依赖编译执行成功；九类宽度与模糊宽度配置断言通过 | 唯一宽度算法来源；不提供字素簇切分、规范化 |
| unicode 0.1.0 | 直接依赖消费链接失败；额外构建原生数据与归档、消费项目显式链接后，八类非空分段和NFD断言通过 | 仅用于分段/规范化；不使用其宽度算法；原生构建和分发尚需产品集成验收 |
| bitarray 0.1.0 | ansies 的传递依赖；随 ansies 编译使用 | 不作为 cjtui 新的公开接口 |

### 宽度与分段用例

| 文本 | unicodewidth.width() | unicode.width() | unicode GraphemeIterator 数量 |
|---|---:|---:|---:|
| ABC | 3 | 3 | 3 |
| 中文 | 4 | 4 | 2 |
| e + U+0301 | 1 | 1 | 1 |
| 👩‍💻 | 2 | 2 | 1 |
| 👍🏽 | 2 | 2 | 1 |
| U+2764 U+FE0F（❤️） | 2 | **1** | 1 |
| 🇨🇳 | 2 | **1** | 1 |
| · | 1，widthCjk()为2 | 1，无相同可配置接口 | 1 |
| 空串 | 0 | 0 | **1个空簇** |

`unicodewidth` 的真实 API 为 `widthCjk()`，包 README 中的 `width_cjk()` 与源码不一致。本次基于归档 `src/lib.cj` 编译确认。其 `src/gen/tables.cj` 声明 Unicode 17.0.0；`unicode` 的原生构建也指定 Unicode 17.0.0 UCD，并记录下载摘要。

选型建议：两个库按不同职责互补，框架只暴露统一薄适配接口，不能同时提供两套宽度决策。`unicode` 空串额外空簇需要适配/上游处理并有回归；不能把代表用例通过当完整 UAX #29 一致性通过。词边界、完整 Unicode 换行规则及终端实际字形宽度均未由本实验验证。

### unicode 原生消费限制

`dependency-logs/unicode-clean-link-failure.log` 保存纯 CJPM 消费项目的原始链接失败（缺少 `getCodepointProperty` 等符号）。该包清单有 `link-option = "-Llib -lunicodedata"`，发布包没有可直接消费的该原生归档；本次额外执行：

1. 使用包内 `generator` 源码及 SDK1.2.0 构建数据生成器。
2. 下载有摘要记录的官方 UCD17.0.0，生成包内指定的七份二进制数据。
3. 直接以 GCC/AS 编译包内 C、ASM，并用 ar 生成 `libunicodedata.a`（本环境无 CMake；未改写依赖源码）。
4. 在隔离消费项目显式添加原生归档路径和 `-lunicodedata`，再运行分段/规范化探针。

这些步骤证明本 Linux x86_64 环境下可有条件消费，不证明正常 CJPM 依赖就能开箱使用，不证明干净 cjp 打包或跨平台产品集成。生成器、数据许可证及静态归档的分发/构建方式须在 TASK-003/004 及制品任务中确定。

### 许可证记录的限制

中心仓声明：ansies/unicode 为 MulanPSL-2.0，unicodewidth/bitarray 为 `[MIT, Apache-2.0]`。unicodewidth README 明确提及双许可，但四个本次下载 cjp 未发现 LICENSE 文本；bitarray README 的“许可证”又写“无。”，与中心仓声明冲突。元数据数组不能单独解决许可文本与归属问题。本轮只记录事实，**传递许可/分发审查未通过**；后续应取得准确文本、归属和 Unicode 数据使用条款，不能把编译成功当合规结论。

## 适用范围

这些结果只覆盖列明版本、源码、Linux环境和用例，没有实现终端会话、布局、焦点、剪贴板、图标、主题、局部绘制或性能基准。编译器普通诊断不等于完整DSL诊断验证；探针中保存回调不等于生命周期契约已完成。产品验收继续保持 pending。
