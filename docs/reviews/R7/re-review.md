# R7 修复复核

受审修复版本：`e2c122de616207c9e5166a9c89416233b8b81268`。初审版本：`9a5c7034d245a053ff4614c3b7f594689a5b1389`；首次部分修复：`f50d60d2553e0f0f8e37cd1dc95ef23a72fff0b3`。

结论：**design_reviewed，仅限本轮顺序、任务分解、治理记录与证据边界设计。** IR-001–003 均已 verified。独立原生测试执行尚待提交，本结论不能将 AC-046、Linux 产品、发布许可或全部风险改为 passed。

## 隔离与历史

沿用独立 clone，通过 fetch 固定 SHA 并 detached checkout。没有读取作者过程上下文，没有编写/执行原生测试，没有修改受审 repo。最初反例及首次复核保留在 independent-review.md，findings.json 保留原始 revision、描述、复现步骤与 history。

## 三项修复

| 发现 | 复核 | 证据与范围 |
|---|---|---|
| IR-001 当前授权冲突 | verified | docs/tasks.md 顶部/Global Constraints/Workflow 与整体提案首页/P1/当前阶段均明确 Linux 已授权、依具体 L3 前置/DQ 推进，发布仍未授权。原反例中的“后续获授权”等当前门槛不再存在。 |
| IR-002 L3 混装 | verified | 044 顺序、046 原生调查、047 许可来源分别具独立交付和验收；045 依赖三者。docs/tasks.md 与 AC-044/046/047 映射保持同步。该修复自 f50d60d 后未改变。 |
| IR-003 技能证据不可定位 | verified | input.md 现链接 skills.md；本地 OpenSpec 1.14.3、Superpowers 7.0.0/revision、既有来源/可用性、实际调用用途和产物映射可定位。云技能仅记录服务资源来源，明确没有 semver，未虚构等同本地版本。工具锁/安装脚本与初审版本无改动。此处认可记录充分性，不要求归档完整调用会话或重新安装。 |

DQ 更新：044 原 DQ-02/08/11 转 pass；044/045 原 DQ-13 转 pass，其余初审设计层面的判定维持。新增 046/047 在当前调查层面有独立目标、固定输入、明确边界和验收、L4、风险及质量治理，纳入 045 审核，不新增 Linux 产品依赖环。任务实际完成仍须独立执行/验收证据。

## 原生脚本修复审查

旧脚本通过追加注释试图触发 CJPM 增量重链接；独立执行发现其不可靠。本次 README 如实记录这一失败，没有删除旧失败断言或把历史开发日志改称新脚本独立通过。

新 owner 阶段恢复确切原包 cjpm.toml，将 FFI 放在中间静态适配库，然后用 mktemp -d 创建全新 target，确认目标 exe 预先不存在，以 cjpm run --target-dir 执行正常构建。之后检查新 exe 可执行、consumer 编译命令包含 -lunicodedata、日志包含新 target exe 路径。新 target 使旧 target 的可执行文件不能作为该阶段产物复用，修复方向对应已知根因。

这里的路径 rg 是日志中出现路径的断言，单独并不证明 Run current project 行；最终独立执行报告仍应保存实际编译、链接和运行行及退出码。当前静态检查没有发现新的必需设计缺陷，也不据此宣布真实链接通过。保留的旧 logs/adapter-owned-ffi-relink.log 是历史开发证据；新脚本的独立结果必须另有固定执行证据，不能只复用旧日志。

原包缺少自动构建与正式产品 hook/干净制品消费仍待 TASK-003/023，766 条测试仍仅证明固定 Unicode17 分段而非规范化/终端显示全量。许可来源事实与法律批准保持区分，bitarray 和最终制品归属门槛继续保留。

## 本次静态核验

- 重新解析当前 37 个产品任务，DFS 无环；TASK-024 传递前置 33 个，非 Linux 前置=[]，Linux 全量闭合结论仍成立。
- native/SHA256SUMS：23/23 一致，退出 0。许可目录与初审无相关改动，复用初审 27/27 摘要核验。
- bash -n run-transitive.sh、git diff --check f50d60d HEAD：无错误。
- tools.lock.json、package-lock.json、setup-development.mjs 与初审固定版本逐字节相同。
- 搜索旧授权反例措辞未命中（rg 退出 1 为无匹配）；git status --short 为空。
- 未运行全量编译、766 条测试、npm check 或许可证上游下载；其运行事实由独立执行者及验收者判断。

后续：接收固定版本的独立执行/验收产物后，由相应角色决定 AC-044/045/046/047 的实际状态。此报告只关闭三个设计/治理发现，不声称 Linux 产品完成。
