# Capability Specification

状态：需求基线；实现 planned，验证 pending。登记基线不代表产品已实现或变更已归档。

## Purpose

使后续开发在既定授权范围内能够连续推进，并保留工具、决策、分层任务和验收的单一可追踪记录；同时使自动检查能够区分规划完备性与真实产品交付证据。

## Requirements

### Requirement: 流程与单一记录

变更 SHALL 使用 OpenSpec 与适用 Superpowers 技能；必需技能缺失时安装并验证，不模拟调用。任务状态只有一个权威位置，其他文档采用引用。

#### Scenario: 新会话继续

- **WHEN** 代理接手已有变更
- **THEN** 读取已有提案与任务，不重复创建平行计划，按治理分类和权限推进。

### Requirement: 粒度与授权

编码 SHALL 仅由准入合格的 L3 执行，L4 有可检查结果；L1/L2 不可编码。仅规划授权不允许进入原型或功能实现。

#### Scenario: 本轮边界

- **WHEN** 规划产物全部生成且静态验证通过
- **THEN** 不进入框架 apply，不归档为功能完成；近期任务仍待后续授权。

### Requirement: CI 与证据

CI SHALL 对仓库与 OpenSpec 进行自动检查，后续产品阶段执行主库/示例/基准及实际制品隔离检查；失败不能 continue-on-error 或用空源码蒙混。验证复用按 AGENTS 第 11 节执行。

#### Scenario: 产品进入实现阶段

- **WHEN** src 出现仓颉实现
- **THEN** CI 自动执行产品入口；检查已引入实现及项目；SDK 或当前切片必需输入缺失时报失败。尚未实现的未来项目保持 pending，最终发行模式必须检查全部必需项目。
