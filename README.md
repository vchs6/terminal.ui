# cjtui

采用仓颉语言及约定范围的 ArkUI 声明式语法，面向终端应用提供组件组合、状态绑定、布局、主题与多层界面能力。

**当前提供 Linux ANSI TTY 文本界面、横纵/弹性布局与字符装饰；完整框架仍在开发。**

- 产品范围与当前状态：[产品说明](docs/product/README.md)。
- 仓颉包名：`cjtui`；当前开发版本 `0.0.0`，未发布。
- 实施顺序：先完成支持 ANSI 转义序列的 Linux 终端全部功能和验收，再考虑 Windows、macOS、HarmonyOS；四平台产品支持目前均待验。
- 许可证：[MulanPSL-2.0](LICENSE)。
- ANSI 与 Unicode 采用仓颉中心仓 `ansies`、`unicode`、`unicodewidth`；首片通过这三个依赖提供 ANSI 与 Unicode 处理。

发布制品包含主库源码、示例项目、基准项目、产品文档与许可证。开发流程资料仅在源码仓库维护。

## 运行示例

加载仓颉SDK1.2.0后，在真实Linux ANSI TTY中运行：

```sh
cd examples/layout
cjpm run
```

`d`切换边框/阴影，`q`退出；窗口改变尺寸自动重排。最小入口见`examples/minimal`。

## 项目文档

以下为源码仓库的在线开发文档，不随产品制品打包：

- [项目整体提案](https://github.com/vchs6/terminal.ui/blob/main/docs/development/proposal.md)：产品定位、目标、范围、交付阶段和成功标准。
- [需求说明书](https://github.com/vchs6/terminal.ui/blob/main/docs/requirements.md)：使用场景、功能/非功能约束、异常边界和验收映射。
- [总体架构设计](https://github.com/vchs6/terminal.ui/blob/main/docs/architecture.md)：模块、数据模型、状态/事件、布局/多层、渲染和恢复设计。
- [用户构造设计](https://github.com/vchs6/terminal.ui/blob/main/docs/ui-construction.md)：声明式构造、状态/事件关联、U1–U5 和接口冻结边界。
- [工程任务与验收入口](https://github.com/vchs6/terminal.ui/blob/main/docs/README.md)：任务、证据、流程规格和开发环境。

有限单/多行编辑：[产品用法](docs/product/text-editing.md)、[独立验收与真实终端原件](docs/reviews/E/README.md)。完整Linux/父AC仍待后续汇合。
