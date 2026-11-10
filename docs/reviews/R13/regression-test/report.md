# TASK-076 独立正式回归补充：深层动态描述校验

这是测试作者的 test-only 补充和真实 RED 证据，不是 TASK-077 产品修复或 TASK-079/080 独立执行/验收结论。工作目录 `/workspace/work/dynamic-regression-tests/source`。未派子代理、未修改产品/规格/原有 raw。

- 产品输入：`167c2a3f701b8718e90fe7d9b78050af5665a23b`。
- 正式 test-only 提交：`10c4ee3bf94a63995c2ffa16cedd79c4905d6b73`；基于上述固定候选，仅改 `tests/dynamic/README.md`、`tests/dynamic/src/main.cj`，新增纯函数文件 `tests/dynamic/src/nested_validation_cases.cj`。
- SDK 实测：Cangjie Compiler / CJPM 1.2.0，x86_64-unknown-linux-gnu，见 `raw/sdk-versions.*`。
- 本角色按已冻结合同执行测试补充；不新增合同、不开产品 fix 准入。新测试不冻结构造副作用的任意次数或整个 batch 回滚。

## 依据与手工期望

正式 `openspec/changes/implement-reactive-runtime/design.md` 4.3 要求完整新增描述隔离 build/校验，构造失败不改该 group 已提交树；R012 要求错误清理先撤销整树 token/订阅/队列，再孩子到父执行已登记 cleanup；R011/4.3 保留业务副作用，不宣称整个 batch 事务。

两个公共消费者场景都将重复 key 藏在新 Column 内层 ForEach，均必须抛 `UIException.code == "DuplicateKey"`：

1. manual：`app.batch { business.set(7); root.append(invalidColumn); root.remove(old) }`。正确手工 cleanup trace 为 `old:stopped,root:stopped,`。
2. replacement：外层 ForEach 从 old 更新为 new，new 的 Column 内含 `ForEach(["dup", "dup"])`。正确手工 trace 为 `old-text:stopped,old-row:stopped,root:stopped,`。

`stopped` 由用户 cleanup 回调内父 NodeRef.isValid() 为 false 取得。只有 parent 仍 valid 才合法查询 children 并记录实际数量。测试不在引用失效后读取树、不要求错误后 session 存活；正常子树卸载时 parent 可以有效，本例无效新构造不能先触发正常卸载。由于没有有效结构提交能够先删除 old，旧 cleanup 应来自错误后的全 session 清理。

每例还累计检查：新 subtree/inner text 的 onMount 为零，重复 key 的 inner body 为零，业务写入保持新值（manual=7、replacement=[new]），新描述无 live reference、所有旧 refs 最终失效，mountedNodes/activeBindings/subscriptions/pendingPosts 四项归零，dispose 不重复 cleanup。每条检查均可达；最后才抛累计失败。main 分别捕获两例结果，首例 RED 不会遮蔽第二例，最终返回非零。

## 真实执行

实际命令、cwd、UTC、源码 manifest hash、actual_exit 均在 `raw/commands.jsonl` 和逐命令 JSON；原始输出分别为 `.stdout/.stderr`。`capture.py` 保留子命令真实退出码，不经 cjpm run。

| 命令 | UTC | actual_exit | 结果 |
|---|---|---|---|
| `source .../envsetup.sh && cjpm build`，cwd=source/tests/dynamic | 2026-11-10T18:40:51Z–18:42:05Z | 0 | 正常路径依赖消费者编译成功 |
| `source .../envsetup.sh && timeout 60s target/release/bin/main`，同上 | 2026-11-10T18:42:28Z | 1 | 原 32 组自然 PASS；两条新增均真实 RED |
| SDK 版本 | 2026-11-10T18:43:03Z | 0 | 1.2.0 |
| scope-audit | 2026-11-10T18:43:34Z | 0 | 原断言/产品未改，源码一致 |
| final-audit | 2026-11-10T18:43:59Z | 0 | 固定 test-only 提交、干净 Git 状态、diff check |

实际 RED 输出：

```text
OBSERVED cleanup: old:active-parent:children=1,root:stopped,
ASSERT FAIL: manual: old cleanup follows whole-session token revocation
OBSERVED failed assertions: 1
FAIL: manual-nested-duplicate-before-commit: FAIL: deep construction validation before structural commit
OBSERVED cleanup: old-text:active-parent:children=1,old-row:active-parent:children=1,root:stopped,
ASSERT FAIL: replacement: old subtree cleanup follows whole-session token revocation
OBSERVED failed assertions: 1
FAIL: replacement-nested-duplicate-before-commit: FAIL: deep construction validation before structural commit
```

两例各只有 cleanup/token 顺序断言失败，其余累计检查都执行并通过。children=1 只证明当时有一位公开孩子，不能单凭该数量推断身份；本补充的失败依据是已冻结的构造失败及整树 token 清理顺序。没有产品 GREEN 声明。产品修复后的 GREEN 仍待后续角色。

## 原证据与复用边界

独立 078 公共 probe 原始事实来自 `/workspace/work/dynamic-review/probe/src/main.cj` 和 `raw/probe-run.{log,meta}`，原样只读。`raw/probe-build-corrected.{log,meta}` 证明正常消费者以固定 167 库为路径依赖实际 build exit 0；它不是完整旧 32 的独立执行，也不称为单独根包 build。受检库源码对应 `/workspace/work/dynamic-review/sourcehash.txt`，本补充对其覆盖的 58 个产品文件逐个复核一致。

原 32 的既有 `delivered-dynamic-run.{log,meta}` 仅为 077 开发 raw，不伪称独立执行。此次没有专门重跑旧套件：它们随新默认 main 自然运行，原 32 PASS 均见本次 `consumer-red.stdout`。旧断言和期望保持不变，scope audit 对旧非 entry 测试文件逐字节对照固定候选，并验证 main 原 32 调用前缀不变。

自有 `/workspace/work/dynamic-regression-tests/cache` 从 reviewer cache 复制；只使用既有 relay 18973，未修改共享 seed、服务或他人 checkout。没有 skip。

## 可核验交付与限制

- `sourcehash.txt` 首行为完整 test-only commit，随后为全部产品 src/native、构建清单、正式 design、完整 tests/dynamic 的逐文件 SHA256；其文件 SHA256 为 `cca2ed790fd7064539fb637370e9ca8ead68764408574d694571970146bc488b`。
- `raw/product-source.sha256` 的 manifest SHA256：`07e3d09914d8e38cffb45dbdf1c050cb394459f1df68614fa8111c94115ec506`。
- `raw/consumer-red-tests.sha256` 的完整测试 manifest SHA256：`62fe0e94e0883308edc2999b9f11d97ea6d997b09a2eaba1cb54ec14bee4ca0d`。
- `raw/SHA256SUMS` 覆盖全部 raw；`test-only.patch` 可按固定候选审阅/应用。`audit_scope.py`、`capture.py` 位于 Git 外，可重放核查。
- build 与 direct 之间只补写 README；全部 14 个 `.cj` 消费者文件逐字节一致，见 `raw/scope-audit.stdout`。没有为纯说明修改重复编译或重复运行。
- 读取并使用 CangjieSkills 固定 `277f2e1234ca5217496966887243c679653887a8` 的 SKILL，经脚本批量查询 ArrayList.add 和 Exception try/catch；采用当前 SDK 1.2.0 编译事实。新增文件仅内聚纯函数，遵守 AGENTS14，每实体单文件，不增加产品测试 hook。
- 使用 runtime 环境技能检查环境状态；读取 TDD 及 writing-good-tests 参考，用真实 runtime、公有 API 与手工 golden 确认 RED；使用 verification-before-completion 检查原始退出码与源码范围。OpenSpec 合同未改变，本角色只消费其已冻结 TASK-076/4.3/R012。
- 历史 declaration-only scratch 从未执行、不计 GREEN、不进入 Git。本次没有创建或执行任何 declaration-only scratch。无 mock/stub、无伪造图或假 runtime。
