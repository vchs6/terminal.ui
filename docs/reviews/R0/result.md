# R0 仓库重建规划审查

## 范围与分类

本轮为决策型规划及执行型配置：重建方向、依赖和工作流由用户指定；目录隔离、CI 分层与工具锁定为可逆工程选择。无功能实现、原型或产品发布。依据基线 SHA 见 design.md。

## 决策 Battle

比较了直接删旧源码、src 并存与 legacy 隔离，选择隔离并明确 TASK-024 删除条件；比较 workspace 根与 package 根，因 CJPM 打包入口选择 package 根；比较单一全量 CI 与阶段检查，按切片和发行边界分层。新方案不保留活动平行内核，不改许可证，不擅自改模块名。

独立 builder-check 审查发现平台支持边界缺失和早期 CI 门槛冲突，已按 findings.json 修订。配置复核还发现 tar 链接类型检查缺口，已默认拒绝链接和特殊条目，并扩展至嵌套依赖表检查。审查未证明任何产品能力可运行。findings.json 记录本轮规划发现，不作为产品运行验证证据。

## DQ 记录

- DQ-01/02：L1/L2 只索引；24 项均按独立结果划分，无直接编码工作包。
- DQ-03/04/05/11：近期四项卡片有目标、边界、交付、验收及 L4；远期候选缺精确接口与入口，保持 planned，不声称完整准入。
- DQ-06/13：产品实施授权未给出；后续依赖未完成，均不得 ready。
- DQ-07/09/12：五个工作包覆盖 REQ-001–007，AC-001–024 关联任务；有最终跨场景、制品与退役集成验收。
- DQ-08/14：任务状态只在 OpenSpec，验收只在 docs/acceptance；旧路径隔离、不复制 ANSI/Unicode 内核，退出条件可定位。
- DQ-10：语法、依赖解析及平台边界明确为调查任务，不预设通过。

## 技能与工具使用证据

Superpowers 源码实际 clone，固定 bb92a77741419a4ab5f06e711a283343f1ada0c3（上游 7.0.0）；通过读取 SKILL.md 加载 using-superpowers、brainstorming、writing-plans、verification-before-completion，并读取 Codex 适配说明。方案使用 brainstorming 的替代比较和 builder-check；任务使用 writing-plans 的任务边界、自检和 review focus，项目路径按 AGENTS 覆盖默认位置。

OpenSpec 1.14.3 实际安装并执行 init --tools codex --language zh-CN，生成 openspec/ 与六个技能入口；读取 openspec-propose，使用 new change、instructions、status 构建本变更。用户已明确要求初始化、配置及 CI，本轮配置属于授权范围；propose 的产品规划边界保留，不进入框架 apply。没有伪称宿主原生技能调度，安装与读取/使用分别记录。

## 验证记录

本地记录（2026-10-18，重建工作树；相关受检文件提交前检查）：

| 检查 | 结果 | 适用范围 |
|---|---|---|
| npm run dev:setup | exit 0 | 固定版本安装、技能可读、OpenSpec 入口生成；另复核重复运行 |
| npm run check | exit 0 | 仓库配置、文档链接、任务映射及 OpenSpec strict |
| actionlint 1.7.7 .github/workflows/ci.yml | exit 0 | Actions 语法与表达式检查 |
| bash -n scripts/*.sh | exit 0 | Shell 语法 |
| 制品策略临时 fixture | 正常清单接收；开发泄漏/缺基准/包外依赖均拒绝 | 仅检查脚本行为；不是实际 CJPM bundle 或产品源码 |
| bash scripts/check-product.sh slice | exit 1，明确 no active Cangjie source | 证明未实现时不会虚报产品通过 |
| SDK 官方 SHA256 | 匹配 8c5fd944…f2ba998f | SDK 下载内容一致性 |
| cjc --version | exit 0，1.2.0 | 编译器可启动，不证明项目构建 |
| cjpm --version | exit 1，EnvException: Initialize current process failed | 本地运行环境限制；尚无依赖解析/打包运行证据 |

诊断尝试：检查已 source 的 SDK 环境及编译器版本；strace 因 PTRACE_TRACEME Operation not permitted 无法进一步跟踪，没有绕过环境限制。本轮不为排障编写产品源码。独立 toolchain CI 将核实 GitHub Ubuntu Runner 中 cjc/cjpm 是否可用。

远端 Actions 状态待提交后记录；未运行前不宣称 CI 通过。当前计划产物与配置不能替代功能验收；产品 AC 均 pending。
