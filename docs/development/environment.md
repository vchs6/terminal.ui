# 开发环境与 CI

## 安装与生成

要求 Node >=20.19、npm、Git、Bash；根 package.json 是开发工具包，private=true，不是产品依赖。

```sh
npm ci --ignore-scripts
npm run dev:setup
npm run check
```

OpenSpec 版本由 package-lock.json 固定（1.14.3），Superpowers 版本由 tools.lock.json 固定（7.0.0 对应完整提交）。setup 实际拉取技能并创建 .agents/skills/superpowers 链接，检查必需技能可读，运行 OpenSpec init（新仓）或 update（已有仓）；不会改写现有规范。自动安装失败必须修复或记录阻塞，不能跳过需要的技能。

OpenSpec 六个 Codex 入口由 CLI 生成并提交，能发现读取；Superpowers 本地 clone 和链接忽略提交。新开/重载代理后检查技能发现；在支持该布局的 Codex 中显式调用适用技能。本环境使用读取 SKILL.md 的方式加载并遵循，不能把“已安装”当“已调用”。其他宿主须按上游入口配置，不声称当前配置已自动覆盖所有代理。

## 工作记录映射

| 工作法 | 权威位置 |
|---|---|
| Superpowers 方案设计 | 总体设计 docs/architecture.md；具体变更归入或引用对应 OpenSpec design.md |
| Superpowers 实施计划 | 项目任务 docs/tasks.md；进入具体变更后按编号转至对应 OpenSpec tasks.md |
| 长期需求与场景投影 | docs/requirements.md 为完整需求，openspec/specs/ 提供对应流程场景 |
| 验收事实 | docs/acceptance.md |
| Battle 与技能使用证据 | docs/reviews/<round>/ |

项目规范的路径与授权优先；不因技能默认路径另建重复计划。当前不得执行框架 apply；之后获授权的任务仍需准入与必要技能。

## SDK 与检查入口

SDK URL、官方 SHA256、版本及来源锁定在 tools.lock.json。Linux CI 下载校验后解压并 source envsetup.sh。支持 CANGJIE_SDK_URL 指向可信镜像，但摘要必须一致；不配置凭据或绕过下载权限。

```sh
bash scripts/install-sdk.sh /absolute/path/to/sdk-install
# 在当前 shell source 该目录的 cangjie/envsetup.sh 后：
bash scripts/check-product.sh slice
# 产品完整后才运行：
bash scripts/check-product.sh release
```

目前无新源码，产品检查应失败并说明未实现。CI repository 和独立 toolchain 可用性作业现在运行；product 作业在检测到 src/*.cj 后检查已有切片。最终完整检查由 workflow_dispatch 的 release_check=true 触发，不能以普通切片绿色替代最终验收。

最终检查要求 minimal/composition 两个独立示例、rendering 基准、实际 bundle 清单及干净解包构建。示例须在实施时提供 --smoke 无交互入口；当前不创建这些程序。基准执行可能需要较长时间，日常切片只构建测试现有基准，最终交付才执行完整测量。产品自身单测和边界证据仍按 L3 验收完成，不由这条脚本代替。

CI 不执行 publish、不含中心仓 token、不自动合并或修改仓库权限。验证策略统一见 AGENTS 第 11 节：脚本是 CI 集成入口，本地迭代不要求每次编辑全跑；bundle 已执行的相关检查可共享其有效证据。CI 首次远端状态以 R0 记录为准。

## 发行范围

根 cjpm.toml 的 package.include/exclude 为打包权威。scripts/check-bundle.mjs 检查实际 .cjp 文件，不以自建 glob 模拟 CJPM 正式行为。源码仓库 GitHub zip 不遵循该边界。

制品不包含 node_modules、脚本、开发说明、OpenSpec、技能、旧实现或凭据。README 与 docs/product 仅记真实产品状态；不将开发追踪表当产品说明。当前无源码，不执行正式 bundle/publish，也不声称包可用。
