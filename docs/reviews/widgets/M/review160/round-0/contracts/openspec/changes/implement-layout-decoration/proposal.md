# Proposal

## Why

首片只能按内容排列文本，尚不能声明面板的尺寸分配、内边距、边框或阴影。继续既定Linux实施顺序，交付可组合的布局与装饰，使同一公开组件树可构造真实分区界面。

## What Changes

- TASK-011：固定/最小尺寸、加权剩余空间、间距与对齐，实际视口与窄屏降级规则。
- TASK-012：内边距、分类字符边框/圆角、仅扩展绘制的字符阴影，以及同语义低层Frame API。
- 新增可运行layout示例、独立测试、代码审核、执行和验收；保留全部R8回归。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

无需求变更，落实既有ui-runtime/terminal-output/ui-construction要求；skip_specs=true，不复制现有规范。有限公开签名和确定算法见design.md。

## Impact

改动src/component.cj、共享Frame适配及新增layout/decoration模块，示例与产品文档。依赖、Linux后端、版本0.0.0保持现有路线；不实现其他OS、不发布包。既有用户授权继续有效，独立角色顺序执行，主代理只管理契约和集成。
