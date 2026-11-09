# Spec Delta

## MODIFIED Requirements

### Requirement: 产品范围

发行制品 SHALL 包含主库源码、独立示例与基准项目、产品说明、四套预置主题、覆盖组件及状态的展示应用、许可证和必要归属信息；制品内项目引用不得指向包外开发目录。

#### Scenario: 解包后使用

- **WHEN** 最终制品在干净目录解包
- **THEN** 可按产品文档构建主库、运行示例和基准，无需开发治理工具。

## ADDED Requirements

### Requirement: 开发版本编号

产品版本 SHALL 使用三段非负整数的主版本.次版本.修订号；当前未发布开发状态标记0.0.0，不把版本字段或文档验收当作产品发布。

#### Scenario: 未实现开发版本

- **WHEN** 读取当前cjpm/package清单
- **THEN** 产品开发版本为0.0.0；工具和第三方依赖版本保留实际固定值，不被批量重置。

### Requirement: Target-specific clean build evidence

发行准备 SHALL 分别验证Linux、Windows、macOS、HarmonyOS冻结配置的源码消费、目标依赖/原生构建及示例运行，记录SDK、CPU/ABI与终端宿主。不能把宿主构建成功或Linux原生归档当作其他目标支持，也不要求同一二进制跨OS运行。

#### Scenario: Clean consumption for each required target

- **WHEN** 为必需平台准备最终源码制品并在干净消费环境构建
- **THEN** 各目标能构建并运行对应示例、主题展示与基准；缺失的构建/链接/运行或许可证据阻止完整跨平台发行结论。

#### Scenario: Native dependency portability

- **WHEN** 字符依赖需要生成数据和C/ASM归档
- **THEN** 用目标工具链/ABI生成并链接，运行分段/宽度样本；不能直接复用Linux归档并声称鸿蒙或其他平台已通过。
