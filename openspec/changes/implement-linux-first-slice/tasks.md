# Linux first slice Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development. 用户已授权独立子代理顺序实施，主代理只协调/集成，不代写产品代码/测试。

**Goal:** 交付可正常构建运行的Linux声明式文本界面。
**Architecture:** 统一Component→Frame→差分→Linux会话，Unicode/ANSI只复用已选依赖，native桥隔离ABI。
**Tech Stack:** 仓颉SDK1.2.0、C/GNU工具、ansies1.3.113、unicode0.1.0、unicodewidth0.1.113；产品0.0.0。
**Spec:** design.md及现有五项对应主规格（proposal列出），不是全框架完成计划。

## Global Constraints

- Linux ANSI优先，其他OS后置；不引入JS/TS/Node/Python产品运行依赖。
- 测试设计、实现、审核、执行、验收独立角色/目录/上下文；只共享固定产物，不共享推理或自评。
- 用户最新指令：许可证声明冲突不作为实施/交付阻塞，保留实际许可/归属；不上传发行包。
- 版本0.0.0；公共接口见design；此片不伪称响应式、完整组件、M2或完整跨平台完成。

## Review Focus

Unicode宽簇覆盖/边缘、控制注入、构造异常上下文残留、写失败基线、TTY取消/resize清理分别由独立测试覆盖；示例必须用公开入口真实运行。

## 1. 独立测试契约

- [x] 1.1 TASK-048：独立编写本切片测试与执行入口；验收AC-048：缺产品时真实失败，预期独立于实现，正/边界/故障和TTY场景可执行。

## 2. 正式构建

- [x] 2.1 TASK-049：正式原生构建入口与Unicode薄适配；验收AC-049：普通cjpm构建与独立消费者可链接，固定输入/离线处理明确，无探针绝对路径或共享cache修改。

## 3. 首个运行切片

- [x] 3.1 TASK-050：Frame、样式、声明式构造、M1输出及Linux会话/示例；验收AC-050：公开API及独立测试通过，TTY运行、键盘/resize/取消和异常清理有效。

## 4. 独立质量门槛

- [x] 4.1 TASK-051：独立审核固定产品差异；验收AC-051：契约/代码质量双结论，必需缺陷修复复核。
- [x] 4.2 TASK-052：独立执行构建、测试、消费者与TTY集成；验收AC-052：实际命令/退出值/原始结果，无作者自测替代。
- [x] 4.3 TASK-053：独立验收和最终集成检查；验收AC-053：需求逐项与代码/证据对应，未完产品范围明确，主仓库源码可见且构建可用。

## L3 cards

所有任务为L3/WP-001或对应产品WP/implement-linux-first-slice；状态只在本文件，结果只在docs/acceptance.md。共同前置：用户实施已授权；SDK/工具复用R7，设计/API明确；Skill使用记录在本变更progress.md。共同治理：唯一Unicode/ANSI职责、不复制第三方内核、不改共享cache、不预设向后兼容旧产品、不涉及旧产品退役；风险均见design，发现由主代理协调，独立角色不互写。完整产品TASK001–004及005等仅提供范围映射，不被本片部分完成冒充全量通过。

| task / type | classification / objective / scope | inputs / depends_on | deliverable / acceptance / skills | risks / L4 |
|---|---|---|---|---|
| 048 / testing | execution；测试独立于实现，tests及测试文档 | design / 无 | 独立测试commit、RED日志 / AC048 / TDD、verification | API语法可编译性；1按契约写测 2实际运行记录RED 3固定交付 |
| 049 / implementation | execution；正式构建与字符薄适配，build.cj/native/清单 | 048测试及R7固定native证据 / 048 | 构建入口与构建说明 / AC049 / TDD、systematic-debugging、verification | 原生下载/链接；1复现RED 2实现最小集成 3自测并提交，不代签验收 |
| 050 / implementation | execution；首次可运行公开切片，src/example/产品说明 | design、048测试、049构建 / 049 | 正式库及minimal / AC050 / TDD、verification | Unicode/会话/构造；1运行RED 2实现并自测 3固定提交交审核 |
| 051 / verification | execution；产品diff独立审核，不写实现 | 049/050固定版本与测试 / 050 | findings/修复复核 / AC051 / requesting/receiving review | 未完成范围误判；1固定diff 2独立审核 3必要修复后复核 |
| 052 / testing | execution；实际测试执行，不改测例或源码 | 固定源码/测试及审核 / 051 | 构建/测试/PTY原始结果 / AC052 / verification、debugging | 环境/失败；1新clone 2执行 3记录反馈 |
| 053 / acceptance | execution；需求与交付核验，不复述测试数量 | 固定版本、审核、执行原始证据 / 052 | 独立验收矩阵及最终检查 / AC053 / verification | 证据边界；1核公开消费者 2核原始结果/范围 3核最终集成 |
