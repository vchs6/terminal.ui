# 维护决策与验证记录

## CLEAN-SCOPE-01

- 决策 CLEAN-D01，统一基线 `61e25f009f8f26c991c3f2ba758987db83bedc4a`。独立范围审查采用只读盘点、交互 C 运行链路反例与恢复路径检查，结论 design_reviewed。维护方案在已授权范围内按普通向前提交执行。
- CLEAN-01 确认八个准入祖先与八个活动证据。其中七份来自旧审查目录，实际命中本地文件测试。单纯删除原目录的准备命令实测退出 77。
- CLEAN-02 确认部分 C008 待用宿主输入只存在历史迁移物和外部工作记录。固定源码与在途现场结果需分别核验。
- CLEAN-03 确认旧环境页的“无源码”说明与当前源码和示例冲突。开始本地开发、工具准备、现有产品构建和未完成验收须有可用入口。

## 分解评审

范围为本变更 GOV-007–GOV-010，参照项目分解规范的 DQ-01–14。

| 检查 | 判定理由 |
|---|---|
| DQ-01–04 | 每个 L3 分别交付测试输入、开发指南、历史退出或在途接续，卡片记录父目标、边界、输入和影响。 |
| DQ-05–06 | 既有脚本给出正负观测，原字节和树可比较，依赖顺序为固定输入后退役历史。 |
| DQ-07–09 | 清理、构建接续和活跃输入三项用户目标均有归属，最终集成由 GOV-009 检查。 |
| DQ-10–12 | 归档成员先查路径索引，在途文件先按固定输入审计。L4 有可检查结果，执行记录与计划分开。 |
| DQ-13–14 | 分类、技能和 OpenSpec 映射明确。CLEAN-D01 裁决历史方式，旧路径归属及兼容方案见设计。 |

## 独立源码审查结论

- 固定范围审查报告 SHA-256 `4a90c9f420459b14ba4f89e00cdde62064e933976226c79d3838585c6d333c1b`，发现表 SHA-256 `d8603513e92769f7f3bd6b629dec1f12ce7f8d7295d491b2f45d3acde2b6634d`。
- 独立源码审查报告 SHA-256 `4b81a6dc01a38bfed5cb28bee520c34721b17a4d2728958ccca5a11dbd10f96c`，发现表 SHA-256 `58b406627ced1662775e10a501726880200905dc6b143b7c4a610df353db898b`。冻结开发基线至清理前 main 的产品目录无差异。首批 315 份候选中的现用内容已由主线源码、正式测试或生成入口覆盖。独有接续输入边界为 C008 的 105 条固定源码/契约和 TASK-023 原两份测试。

## 实施验证

| 条件 | 实际结果 |
|---|---|
| GOV-007 交互 C | 在有祖先且移除旧目录的检出中，`bash tests/interaction_c/run.sh preparation` 退出 0。七份证据的原 SHA-256 相同。`bash tests/interaction_c/gate-selftest.sh` 19 项控制通过，覆盖失效、伪造、非祖先及缺失证据。 |
| GOV-007 颜色 resize oracle | 清理前的 main-only 检出无法读取旧提交 `91c22f82adcd2412d9509b9872ff63450ba81af9`。迁入原 blob 后 `node tests/colors/resize_oracle_test.mjs` 退出 0，仍观察到旧 oracle 的错误拒绝并保留当前 oracle 的严格断言。 |
| GOV-008 开发依赖 | 新下载官方 SDK 与 stdx 的 SHA-256 均匹配锁定值，SDK 工具均报 1.2.0。`npm ci --ignore-scripts`、固定 Superpowers 的 `npm run dev:setup` 及 `npm run check` 通过，OpenSpec 共 24 项通过。 |
| GOV-010 C008 | [源清单](../../../tools/linux-acceptance/c008/source-manifest.json)与独立输入清单一致。105 条共 774,636 字节，源码检查成功解析 C 2、JavaScript 22、Python 21、Shell 6，修改副本触发固定 SHA 检查。 |
| GOV-010 TASK-023 | 两个文件分别匹配 Git blobs `4f685e1e8bdc876029a14f50dbd608ede35f81e3`、`6b40e0be3ebeb79d8e6e85f889dcbb6d7b1da181`。独立 `node --test tests/release/*.test.mjs` 保持现有差距，14 项中 2 条通过、12 条失败，留待 TASK-023。 |
| GOV-007 测试环境 | 控件及主题脚本使用调用者激活的 SDK/stdx。shell 语法和 Python 编译检查通过。小控件 `--oracle`、组合控件 53 项 oracle 及 10 项 PTY 控制在未配置 SDK/stdx 环境通过。 |
| GOV-008 常规构建 | SDK 默认及显式官方中心仓使用空 cache 直连均收到连接拒绝 111，官方 TOML payload 经 curl 校验匹配。隔离的初始空 cache 经环境现有代理桥取官方包后，`cjpm build`、`cjpm test`（0 项注册测试）、最小示例正常编译和直接 `--smoke` 均退出 0，输出 `PASS minimal`。代理桥只用于本次验证。 |
| GOV-009 历史退出 | 两处历史目录在当前树已移除。受影响 Markdown 链接的目标已核对固定 Git 版本，当前链接检查通过。历史归档读、归档操作和检出合约分别有 51、13、6 项通过。 |
| GOV-009 独立检出 | 用本地 Git wire 协议创建可过滤对象、无 alternates 且保留完整祖先的独立候选检出。`npm ci`、24 项检查、交互 C 活动准入及 19 项控制、颜色 oracle、C008 源码检查均通过。候选检出的 Git pack 约 4 MiB。远端 main 检出由集成后独立验收。 |
