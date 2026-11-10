# 动态结构公共契约测试（TASK-076）

独立消费者包 `dynamic_contract`，只导入公开 `cjtui.*`。依据
`openspec/changes/implement-reactive-runtime/design.md` 第 4 节及第 6 节
R001–R018（第 6 节优先），初始契约输入为 `a947857`，正式 RED 的固定 A+B 输入为
`c3d743d2dd5cb125e4ca435b2842d1b10c501281`。每个测试类型单独文件；
旧测试和产品源码不变。测试作者指定 Sol/high，实际具体模型和 effort 无可核验元数据。

## 运行

```bash
source /workspace/work/validation/sdk/cangjie/envsetup.sh
tests/dynamic/run.sh
```

SDK 必须为 1.2.0；依赖使用根包原有清单。调用方可通过忽略的
`cangjie-repo.toml` 指定自己的 registry/cache。脚本先 `cjpm build`，随后直接执行
`target/release/bin/main`，不使用可能隐藏退出状态的 `cjpm run`。超时返回非零。
本单元不改 `tests/run-slice.sh`；共享入口由主代理在 A+B 接线固定后顺序集成。

## 手工 golden

`sequence` 只比较公开 `children()` 快照的 NodeRef 身份；`picture` 比较公开
`Application.snapshot(...).toPlainText()` 与直接写出的完整字符帧。
所有期望均手工写定，未调用协调器、渲染器或产品排序函数生成。
以下每行各自从 `A X B C` 初态开始，空后补项除外：

| 操作 | 手工期望 |
|---|---|
| 数据重排为 C/B/A | C X B A |
| 删除 A，数据为 B/C | B X C |
| 清空数据 | X |
| 空组后加入 D/E | X D E |
| 数据为 D/A/B/C | D X A B C |

测试以 `NodeRef.sameNode/isValid`、组件 `reference`、完整帧和公开 `stats`
观察行为；不读取内部 marker、RuntimeNode、布局节点或私有队列。
人工插入元素从公共 NodeRef API 挂载。计数和清理 trace 是用户回调产生的观察值，
没有替代产品协调或调度的 fake runtime/stub。

## 行为矩阵与预期捕获的错误

| 用例 | 捕获的错误行为 |
|---|---|
| slot-reorder/delete/empty-refill/overflow | 按 key 拖动 manual、漏删、错误溢出位置、空组 marker 丢失 |
| marker-exterior | 协调只搜索 marker 内节点；空后仍从已移动的旧槽补项 |
| manual-remove-rebuild | remove 修改业务数据、自发重建、Structure 不重建或旧 ref 复活 |
| deferred-reads-noops | pending 操作伪造已提交读取、返回 children 可回写、no-op 改身份 |
| commands-before-reconciliation | 先协调后命令，导致“改数据再 remove”保留错误最终结果 |
| key-new-value-local-state | 同 key 缓存旧 T、按位置转移状态、保留 key 重复 body/build、删后复活 |
| multiple-groups-manual-order | key 全局去重、组互相吞节点、manual 相对次序改变 |
| conditional-lifetimes | If 多一层容器、分支未卸载、旧订阅保留、分支重入复用旧代际 |
| empty-conditional-plain-flow | 空 If 分支非法，或把普通 if/for 当作响应式构造 |
| unmount-group-parent | 删除组父节点未撤销后代引用/订阅/owner 工作，或重入时沿用旧数据 |
| invalid-keys/invalid-update-no-partial-body | 未先验证完整 key 数组，错误前半构造新增 key |
| root-counts | ForEach 允许零/多根，If 允许多根 |
| stale-anchor | 本批先 remove 的 anchor 被降级为 append |
| cross-parent-foreign-anchor | 跨父 move 或外父 anchor 被接受 |
| duplicate-insert-cycle | 待提交预留/已挂载描述可重复插入，祖先可形成循环 |
| leaf-parent-removed-move | Text 叶子拥有孩子，或删除后仍可 move |
| structure-limits | 命令预算和动态 mountedNodes 上界不执行，失败仍半挂载 |
| owner-post-cancel | 已卸载 key 的 owner 工作运行，或连同无 owner 工作一起误取消 |
| failed-body-collector | 构造失败前半挂载，原异常吞掉，collector 泄漏到新 session |
| cleanup-continues | 第一个 cleanup 异常中止余下清理，父早于子，重复清理 |
| lifecycle-reentry | onMount/cleanup 直接改树得到允许 |
| evaluation-reentry/body-reentry | items/key/body 求值允许结构重入 |
| lifecycle-post-next-turn | cleanup 无法 post，或在同 turn 递归提交 |
| dynamic-mount-failure | 新 key onMount 异常未停止/清理 session，重复执行已登记 cleanup |
| recursive-structure-boundaries | condition/items/key/body 中 snapshot/dispatch 递归进入 UI |
| observable-write-from-key | key getter 写 Observable 被接受，或误报为结构操作错误 |
| synchronous-structural-loop | 生命周期引发的同步结构循环不受稳定轮数限制，或超限漏清理 |

结构异常按契约终止 session，因此错误用例检查引用失效和公开资源计数归零，
不会在失败后要求 session 继续存活。祖先循环的 `AlreadyMounted` 与 `InvalidParent`
校验优先级未冻结，该例只要求 UIException 拒绝；其他指定错误码精确比较。
原有 `build/measure/paint` 的累计数字不用于猜测动态实现的内部结构。

## 证据边界

正式 RED 使用上述固定 A+B 基线：根包 `cjpm build` 实际 exit 0；动态消费者
`cd tests/dynamic && cjpm build` 实际 exit 1，完整打印的 55 条诊断均为缺少
`If`、`ForEach`、`ListItem` 或 NodeRef 的 `children/append/insertBefore/moveBefore/
moveToEnd/remove`。未生成消费者可执行文件，因此没有运行时通过声明。

编写期间发现并修正测试自身的局部 `var` 逃逸捕获和泛型 `None` 歧义：使用仅测试的
`MutableBox` 引用盒及明确 `Option<T>.None`。另在仓库外独立 scratch 对相同消费者源码
增加缺 C 的声明形状，编译为静态归档以检查被缺接口遮蔽的类型错误；该临时声明全部为
throw 哨兵，从未执行、不进入本提交，也不作为产品 GREEN 或验收证据。

原始 stdout/stderr、实际 exit、UTC、命令、源码及 hash 由主代理归档到 TASK-076
证据目录。测试作者开发检查不代替 TASK-078/079/080 独立审核、执行与验收。
