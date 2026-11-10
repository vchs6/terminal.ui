# TASK-076 正式测试冻结与 RED 交接

执行型任务；消费已经裁决的动态结构公共契约，不修改产品或规格。
指定测试作者 Sol/high；本角色无法独立核验实际具体模型/effort 元数据。

## 固定输入与输出

- A+B 固定基线：`c3d743d2dd5cb125e4ca435b2842d1b10c501281`。
- 初始测试设计契约 `a947857`；本次核对固定基线 design.md 第 4 节和 R001–018，第 6 节优先。
- 测试冻结：`3ee1a9b697db77ee6584905c10ba670ddfd06bff`，父提交即上述基线。
- 独立 clone：`/workspace/work/dynamic-tests/source`，分支 `task076-dynamic-tests`。
- 改动仅 `tests/dynamic/**`，16 文件、32 个命名用例入口；6 个测试类型每类型一文件。
- 无产品/规格/旧测试/共享 tests/run-slice.sh 改动，提交后工作树 clean。
- 本目录 `frozen-product-and-tests-source.tar.gz` 为固定产品源码及测试/契约源码；
  `frozen-test-diff.patch` 为 test-only diff；`frozen-tests.sha256` 为逐测试文件 hash。

## 实际执行

SDK 通过 `/workspace/work/validation/sdk/cangjie/envsetup.sh` 选用，实际 cjc/cjpm 1.2.0。
只读 seed 复制到本角色独立 cache，忽略的 registry 配置使用 18973，不共享修改缓存或配置。
未读取其他测试作者分析或产品作者报告，未运行旧 A+B 套件。

| 检查 | 命令 / 实际结果 | UTC |
|---|---|---|
| 固定 A+B 产品正常构建 | 根目录 `cjpm build`，exit 0 | 16:21:53–16:22:51，2026-11-10 |
| 最终真实动态消费者 RED | `cd tests/dynamic && cjpm build`，exit 1 | 16:26:37–16:27:37，2026-11-10 |
| 测试源码解析 | `cjfmt -d tests/dynamic/src -o /workspace/work/dynamic-tests/formatted`，exit 0 | 见 syntax-parser.json |
| 运行入口语法 | `bash -n tests/dynamic/run.sh`，exit 0 | 见 shell-syntax.json |
| 提交范围与空白 | `git diff --cached --check`，exit 0；提交范围只含 tests/dynamic | 提交前已核对 |

每个构建/工具检查的 `*.json` 记录原命令、cwd、开始/结束 UTC 和真实退出码；
同名 `*.stdout` / `*.stderr` 保存原始输出。未使用 `cjpm run`。
消费者没有生成 `target/release/bin/main`，没有执行动态运行时，也没有产品 GREEN 声明。

## 最终 RED 原因

`consumer-final.stderr` 完整打印 55 条错误，全部为尚缺 C 公共 API：

| 缺少项 | 诊断数 |
|---|---:|
| ForEach | 16 |
| If | 7 |
| ListItem | 2 |
| NodeRef.append | 11 |
| NodeRef.children | 5 |
| NodeRef.insertBefore | 4 |
| NodeRef.moveBefore | 3 |
| NodeRef.moveToEnd | 3 |
| NodeRef.remove | 4 |

初始 consumer-initial 使用默认最多打印 8 条诊断；随后 consumer-all 打印全部 63 条，
其中 8 条是测试闭包捕获局部 var 的语言错误。本测试作者改用仅测试 MutableBox 引用盒，
并修正静态核对发现的泛型 None 枚举歧义，最终真实消费者只剩以上 55 项缺 C 错误。
保留全部初始 raw，不把这些自身错误算作正式 RED。

## 声明形状静态核对的严格边界

为暴露缺 C 名称遮蔽的测试体类型错误，在仓库外 `declaration-check/src` 复制完全相同的
13 个消费者源码，额外声明缺 C 的签名与 NodeRef 扩展。所有临时声明体均为 throw 哨兵，
没有协调/渲染/调度实现，没有执行；只以真实 A+B 公共 cjo 依赖编译为静态归档。
最初暴露 8 项泛型 None 歧义，修正为明确 Option<T>.None 后，静态编译实际 exit 0。
14 条 warning 只涉及临时声明未使用参数和静态归档未使用 main。

这些临时声明不在仓库或 test-only 提交中；本目录单独标记的源码压缩包仅用于审计。
它只支持“测试源码按冻结签名通过静态类型核对”，不能证明 C 产品实现或任何运行行为。
正式 RED 始终使用未添加这些声明的真实消费者；`declaration-source-parity.json` 记录源码一致性。

## 覆盖与后续消费

测试 README 中按可捕获错误列出 32 个入口：完整手工槽位表及 NodeRef 身份、marker 外移动、
多组同 key/manual 相对顺序、新 T 更新 ListItem.value 与局部状态、If/原生 if/for、
删除组父、手动 remove 后 Structure 重建、延后提交读取/命令顺序、错误/限额、
所有结构上下文递归入口、异常清理/collector 恢复、owner-post 取消与 cleanup 下一 turn post。
所有帧期望为手工字面量，不使用产品实现生成 golden。

后续实现/独立执行者从固定测试提交正常构建，构建成功后使用 `tests/dynamic/run.sh`
直接执行真实二进制并保留退出码；此记录不代替 TASK-078/079/080 独立审核、执行、验收。
本任务未声称稳定 TASK-014/015/016/032 或 Linux 阶段完成。
