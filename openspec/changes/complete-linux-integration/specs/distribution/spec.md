## MODIFIED Requirements

### Requirement: 产品范围

发行制品 SHALL 包含主库源码、独立示例与基准项目、产品说明、四套预置主题、覆盖组件及状态的展示应用、许可证和必要归属信息；制品内项目引用不得指向包外开发目录。Linux阶段完整交付 SHALL 以最终正常源码包的实际文件清单、干净缓存的正常主库/公开示例/基准消费和完整release检查为依据；直接运行二进制的实际非零退出不得被CJPM包装状态掩盖。公开示例 SHALL 覆盖U1–U5，完整构造、设备恢复和真实跨终端证据按原必需验收逐项判断，不以有限bundle替代整体验收。

#### Scenario: 解包后使用

- **WHEN** 最终制品在干净目录解包
- **THEN** 可按产品文档正常构建主库、运行示例和基准，无需开发治理工具，所有包内引用有效且实际退出可判定

#### Scenario: Complete Linux delivery

- **WHEN** 四主题、composition或benchmark源码缺失，或真实公开消费者返回非零
- **THEN** 完整release与Linux交付保持失败或不足，不能用目录、include字符串或包装工具exit0宣称完成；其他OS仍为后续目标
