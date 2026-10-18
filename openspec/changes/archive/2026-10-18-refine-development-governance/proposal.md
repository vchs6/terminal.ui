## Why

Battle 发现阶段字段语义、证据版本定位与固定任务数量检查存在缺口，需要修订开发治理；迁移平台和模型运营建议不适用于 cjtui。

## What Changes

- 明确 planned / ready / 执行后证据及 DQ-05 的准入语义。
- 规定可唯一恢复的审查版本与最小证据索引，历史记录不伪造回填。
- 在现有编码规范内参考 Aegis 补齐接口、状态与范围控制；明确宿主上下文及凭据边界。
- 消除固定 24 个未完成任务的 CI 误判，按稳定任务与验收编号检查映射。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `development-workflow`: 按阶段验证任务准备与证据，版本可定位。

## Impact

仅治理文档、规划任务字段、OpenSpec 流程规格及已有仓库静态检查。用户已明确授权本次文档修改和直接提交；不授权任何产品任务实施。
