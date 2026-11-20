# cjtui

cjtui 是用仓颉编写的声明式终端界面框架，支持组件组合、状态绑定、布局、主题和多层界面。当前面向 Linux ANSI 终端开发，版本 `0.0.0`，尚未发布。

## 开始开发

```sh
git clone --filter=blob:none --single-branch --branch main https://github.com/vchs6/terminal.ui.git
cd terminal.ui
```

[本地开发指南](docs/development/local-setup.md)列出 SDK、stdx、中心仓依赖的确切版本、下载来源和 SHA-256，并提供正常构建、测试和运行示例的命令。依赖由开发者从上游获取。

部分克隆保留交互 C 测试所需的提交祖先，按需获取历史文件。普通完整克隆还会下载旧迁移卷和证据归档。查询历史时可打开[清理前的固定快照](https://github.com/vchs6/terminal.ui/tree/61e25f009f8f26c991c3f2ba758987db83bedc4a)。

## 继续项目

- [当前 Linux 工作](docs/development/continue-linux.md)提供宿主验证、制品与整体验收的执行顺序和任务入口。
- [项目文档](docs/README.md)索引需求、架构、构造设计及验收矩阵。
- [产品说明](docs/product/README.md)记录可用能力，[最小示例](examples/minimal/README.md)提供非交互快照和真实终端入口。

仓颉包名为 `cjtui`。项目采用 [MulanPSL-2.0](LICENSE)，第三方授权见 [NOTICE](NOTICE)。
