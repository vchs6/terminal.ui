# TASK-068 F003 scoped recheck and final verdict

最终固定主仓：`5c2a7e7d956b5d8c0284e96514276608616bf8a6`。本次 scoped 区间为 `883444195725224985f29060253017432abaa7f3..5c2a7e7d956b5d8c0284e96514276608616bf8a6`；结合 [初轮报告](review-round1.md)，最终覆盖 `31a7017..5c2a7e7` 的 Frame composition 有限技术范围。

**最终 Spec verdict: PASS。最终 Quality verdict: PASS。** 无未决 Critical / Important / Minor；可进入 TASK-069 独立执行和 TASK-070 有限验收。本轮没有把审核等同于全部 Linux 或完整 TASK-010 验收。

## 范围与固定证据

- 独立 detached checkout 位于 `/workspace/work/frame-review/repo-f003`；初轮 `/workspace/work/frame-review/repo` 仍保持 8834441，初轮报告未覆盖。
- 本次只审核 F003：opaque 默认帧经 clear 产生透明孔后，copy/resized 必须保存源透明位，而 composite 继续跳过；审查该变化可能影响的宽簇裁剪、伙伴清理、预算/策略与快照路径。未重新扫描其余整片。
- 输入 `f003-scoped-review.diff` 的反向 `git apply --check` 在最终 checkout 返回 0。该 patch 未包含新增的 tests/README.md 文案，本角色补读其 19 行独立测试说明差异；没有漏掉新增调用入口的文档。
- src/frame.cj、docs/product/README.md、新测试两文件、tests/README.md 与作者目录内容 hash 完全一致；独立测试作者的 product-source.sha256 全部匹配旧 8834441，tests.sha256 全部匹配最终固定测试。摘要、命令、原始结果和副本位置见 [f003-inspection.json](f003-inspection.json)。
- 旧五类消费者、原 composition boundaries/files/golden/runner、AGENTS 与 cjpm.toml 在 scoped 区间没有变更。产品变化只涉及 src/frame.cj 与产品说明；没有第二个 Frame/Unicode/ANSI 内核。
- 实际应用技能沿用初轮已读取的 code-reviewer 与 verification-before-completion；按项目有效证据复用规则未重跑任何同源 suite。未读作者报告或自评，未改产品/tests，未派子代理。本次为 scoped 复核 1/3。
- 模型指定仍为 Astra/high；无可见 runtime 元数据能够独立证明实际后端型号与推理强度，沿用初轮如实记录。

## 复核结果

1. **透明位确实进入复制结果。** `src/frame.cj:224` 与 `:230` 传入 `skipTransparent=false`，`:257` 将规范化透明 Cell 写入新帧；源 `X[透明]Z` 的 full copy 与同尺寸 resized 都保留中间位，并叠到 `ABC` 得到 `XBZ`。新增分支不依赖源帧默认透明类型，不会再次封闭 opaque 默认帧的孔。
2. **合成的行为保持。** `src/frame.cj:234` 固定传入 true，新透明分支不修改目标。参数验证、clip-before-negation、交集快照及所有不透明宽簇分支原样位于共享 transfer 中；self-overlap 仍先完成快照。没有把复制透明语义泄漏到 composite。
3. **区域外默认类型、独立所有权和宽簇规则保持。** 新 Frame 仍以源默认类型、预算、宽度策略构造；transfer 仅写交集。透明 Cell 始终为 width=1、不含 continuation，因此复制透明位不会引入半簇；相邻完整/截断不透明簇继续走原分支。clearAt 后赋源 Cell 不改变源默认类型或数组。grown 的新行列仍 opaque，同时原孔透明；修改源/副本互不影响。
4. **独立测试针对实际差异而非文本表象。** `tests/composition/src/transparency_holes.cj:14` 构造 `XYZ` 并明确 clear 中间位；同时断言 `false/true/false`、规范化 metadata、字面 `XBZ` 合成、growth padding、双向变更独立性。直接 toPlainText 在 RED 中仍为 `X Z`，证明测试没有仅以文本空格误判透明。聚合先执行 holeResult，再合并 passed，使所有反例可见，末尾 check 让 binary 失败。
5. **入口与旧断言未弱化。** `main.cj` 新增显式环境选择的 focused 路径，并将新函数加入默认完整 suite。旧函数与断言没有删除；常规文件 verifier 仍保留。新 focused 入口不宣称包含文件测试，tests/README.md 明确这一边界。
6. **文档符合澄清。** design 的 copy/resized 行与公共单元规则均改为保留透明位，只有 composite 跳过；产品说明区分交集内源透明位与新增区域默认空白类型。原初轮是按当时明确“透明仍跳过”规则通过；F003 属主代理后续澄清，不倒算成作者违反旧规格。

没有发现需要新 probe 的具体失败假设；上述行为通过源码核查和已给原始 RED/GREEN 共同判断。

## 原始结果及复用理由

| 原始执行 | 实际可见结果 | 范围与用途 |
|---|---|---|
| 独立测试作者 `/workspace/work/frame-tests/evidence/f003/build.*`、`red.*` | 正常 build exit 0；focused binary exit 1，8 条 FAIL：copy/resize 透明位、叠放结果及 grown hole | commands.txt 固定旧产品 8834441，使用直接 binary/timeout；产品与测试摘要已独立比对。这是新契约真实 RED，不是编译/入口故障。 |
| 作者 `/workspace/work/frame-implementation/f003-red.*` | build success；完整 consumer 在 F003 处 exit 1，8 条 FAIL，131 PASS | 原有前置案例通过后命中同一反例；文件后续案例因异常未执行，不能把 RED 当完整套件运行成功。 |
| 作者 `/workspace/work/frame-implementation/f003-green.*` | build success；165 PASS、0 FAIL、0 SKIP；stderr 空，exit 0 | 修复后的完整 composition，包含既有裁剪、目标宽簇、自身重叠、预算/空轴、文件与新25条断言；保留实际 /dev/full 与独立 literal-byte checks。 |
| 初轮五回归 raw | contract 109、coordinates 2、colors 1944、layout 114、decoration 59 PASS；全 exit 0 | scoped 变更没有改旧 put/fill/border/shadow/export、颜色/布局或其断言；F003 对 transfer 的影响由新完整 composition 覆盖，因此复用原有效5回归，不因新提交重复运行。layout 原2条 unused-expression 警告保持记录。 |

新 raw 副本为 `raw/f003-{red,green}.*` 与 `raw/f003-test-author/`，摘要见 f003-inspection.json；初轮 raw 与 [regression-raw-addendum.json](regression-raw-addendum.json) 保留。作者 GREEN 属开发执行证据，不伪称本审核者或 TASK-069 已独立运行。

## Findings / declined to judge / limits

最终缺陷集合为空，Critical 0 / Important 0 / Minor 0。F003 具体反例已由原始 RED 显示，最终实现及 GREEN 消除；这是对澄清契约的复核，不修改原轮 findings。

仍不判断 runtime/ANSI parser、真实应用可见覆盖层捕获、焦点/状态更新、全 Linux/其他平台、全量 release；这些不在当前限定 diff。完整 TASK-010 仍等待 TASK-018 后的应用层捕获验收。独立正式执行、bundle/包消费者及最终 AC 汇合由 TASK-069/070 承担。初轮关于未注入单独 close-failure、未测性能/物理内存极限、无发布授权等限制仍有效。

本次没有扩大必要测试范围，也没有用旧 raw 声称新复制语义通过；新语义由 F003 RED/GREEN 单独覆盖。
