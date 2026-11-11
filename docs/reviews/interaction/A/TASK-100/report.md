# TASK100 独立完整源码审查

固定 BASE `3755f5793096b2f76602f5f73433fbb3a4973b65` → HEAD `f02d8124dfad6028da1427c3da877eeec05a5708`。规格 **CHANGES_REQUIRED**；质量 **CHANGES_REQUIRED**。7 个 Important，0 个 Critical。普通入口通过与这些反例同时成立；不得准入源码通过门禁。

已审完整27文件/694新增84删除范围（原7提交全包加mandatory-lint修正），不是HEAD~1或值类型切片。按正式 A.1–A.6、I001/I004–I007/I011/I012/I014/I015 与A相关的I009/M1边界检查，I002/I003/I008/I010/I013的B/C部分保留阶段边界；A-01–A-06均有源码审查。没有读取实现作者报告/自评、联系作者、修改产品/正式测试/合同或派生代理。

覆盖：新增公开签名/值与错误优先级；Canvas content box/单Frame/Unicode/唯一resolver/selected优先级；绑定与measure/draw失效、版本和容量；真实children焦点顺序/修复/只读guard；固定事件路径与处理器快照、Target→框架→Ancestor默认链；逻辑caret所有权/裁剪/continuation/过期context；单decoder HT/CSI-Z/精确mode25回复和隔离；一次query/600ms截止/100ms ESC idle/时钟失败；writer提交与unsafe恢复围栏；现有异步theme候选不执行用户measure/draw、稳定缓存与全局M1路径；公开消费者、文档与包配置。完整范围审查已结束；修复后仅按本批范围复核。

## 可复现发现

### T100-I01 · Important · Canvas 多次约束测量丢掉仍参与布局的依赖

位置：`src/layout_node.cj:33`, `src/layout_node.cj:105`, `src/binding.cj:53`。合同：A.1 多次约束测量；A.2 M/P 独立依赖与 M 变化 Layout+Paint；I001/M1 完整参考。

Row(Canvas(measure: 无 maxWidth 时 Size(width.get(),1)，有 maxWidth 时 constrain(Size(1,1)), draw C), Text B)，width 初始1；snapshot(5,1)，width.set(3)，再次 snapshot 与 render 比较。

**实际：** 首次 snapshot 后 subscriptions=0；更新后 Application=[CB   ]，完整 render=[C  B ]。

后一次 track 清除前一次依赖，但 LayoutNode.naturalW 仍消费前一次结果；业务 Observable 更新不能自动刷新布局。 保留所有仍支持有效测量结果的依赖，或使布局结果与保留的计算依赖一致；维持 M/P 分离、版本复核、容量和 theme validation 不调用业务代码等既有约束。

### T100-I02 · Important · 实际 focus/enabled 状态只重绘，尺寸样式复用旧测量

位置：`src/focus_manager.cj:50`, `src/component.cj:190`, `src/layout_node.cj:128`, `src/runtime_session.cj:150`。合同：I012 自动实际行为外观状态；A.2 影响测量的 style 改变使 measure 失效；M1 等价。

Column(Text A focusable, Text abcd width4 wrapGrapheme focusable + focused width1, Text Z)，首次 snapshot(4,6) 后 requestFocus 第二节点，再 snapshot/render。

**实际：** Application 输出 A/a/Z，剩余空行；M1 输出 A/a/b/c/d/Z。

真实焦点转换会裁掉文本并把后续节点放错位置。enabled 常量/getter 同样只标 Style，自动 disabled 尺寸规则存在同一源级缺口。 实际行为态导致尺寸/排版字段变化时必须使相关测量失效；纯外观路径可继续 paint-only。

### T100-I03 · Important · requestFocus 绕过共享命令容量预算

位置：`src/node_ref.cj:56`, `src/focus_manager.cj:10`, `src/focus_manager.cj:75`。合同：Shared errors/capacity design.md:384–387；命令受 structuralOpsPerBatch，不另无限队列。

两个 focusable Text，RuntimeLimits(structuralOpsPerBatch:1)，同一个 app.batch 先后 requestFocus 两节点。

**实际：** 两次请求均被接受，输出 FOCUS_BUDGET two_requests_accepted。

任意多的 pending focus 请求可累积并在一次边界处理，公开容量保护失效；混合结构/焦点命令也未共享预算。 焦点命令纳入既有每 batch 命令预算并报 CapacityExceeded，维持正常顺序/最后有效请求语义。

### T100-I04 · Important · isEnabled 将 visibility 混入行为 enabled 合取

位置：`src/focus_manager.cj:20`, `src/node_ref.cj:43`。合同：A.4 isEnabled/isVisible 各自沿普通祖先有效合取；候选另要求 visible 且 enabled；I012 effectiveEnabled。

Application(Text x .visible(false).enabled(true)) startHeadless 后查询 NodeRef.isVisible/isEnabled。

**实际：** visible=false、enabled=false；没有节点或祖先 disabled。

隐藏被错误报告为禁用，用户 getter 无法区分两种独立行为状态；统一 resolver 的 effectiveEnabled 也沿此混合 helper。 分开计算 enabled 与 visible 的祖先合取；焦点/dispatch eligibility 再显式组合两者。

### T100-I05 · Important · 时钟失败后裸 ESC 永不超时并吞掉下个普通键

位置：`src/application.cj:595`, `src/application.cj:609`, `src/application.cj:619`。合同：I015 §1.4/6/7/8：Unknown 保守运行、普通输入无阻塞、保留100ms实际键盘 idle；TASK100 brief 同要求。

普通 Application.run 消费者链接测试 clock seam：cjt_monotonic_ms 始终 -1。首帧后输入 ESC，等待400ms，再输入 q，最后 Ctrl-C 退出。

**实际：** 400ms 后仍未退出；CLOCK_EVENTS 为空（ESC 与 q 均未派发），CLOCK_STATUS=unknown-clock；Ctrl-C 退出0。

lastInput=-1 同时表示无 ESC 和时钟读取失败；所有 timeout 分支要求 >=0，使 decoder 长期停在 ESC 状态，吞掉后继字符。 计时失败仍保留旧输入空闲语义与普通键传递；UnknownClock 不得改变 mode25，probe deadline 唤醒仍不得冒充100ms idle。

### T100-I06 · Important · 卸载未取消已排队 focus 请求

位置：`src/runtime_session.cj:658`, `src/focus_manager.cj:75`。合同：Shared lifecycle design.md:387：卸载取消 focus 请求；A.4 在安全提交边界修复焦点。

Column 两个 focusable Text，同 batch 对第二节点 requestFocus，然后父 ref.remove(第二节点)。请求时 ref 有效。

**实际：** 边界抛 StaleReference（UNMOUNT_FOCUS error=StaleReference）。

合法的同 turn 移除触发过期队列引用异常，走应用失败路径，而非取消该节点待处理意图并修复焦点。 卸载撤销该节点/后代的 pending focus 请求；直接使用已过期 ref 的调用仍按原错误规则拒绝。

### T100-I07 · Important · Canvas 可通过动态 NodeRef append 接纳普通 children

位置：`src/canvas.cj:4`, `src/runtime_session.cj:515`, `src/runtime_session.cj:578`。合同：A.1：Canvas 是叶，不收普通 children；construction spec 单个通用 Canvas 叶。

Canvas root startHeadless 后，在 app.batch 中 root.reference.append(Text(hidden child).focusable(true))，检查 children/focusedNode/snapshot。

**实际：** children=1、focused_child=true、frame=[C    ]：普通 child 被挂载并进入焦点候选，而 Canvas 绘制路径不画该 child。

新 kind=3 未纳入两处只拒绝 kind=0 的结构父能力检查，产生不可见却可聚焦的真实子树。 公共结构操作按叶能力拒绝 Canvas 父节点，保持原容器操作和错误/事务语义。

## 执行与身份事实

独立普通SDK1.2消费者使用从固定f02 Git archive导出的148个src/native/build/manifest/themes输入；事后逐项与Git核对0差异。这是事后固定源复核，不补造pre-run哈希。第一次build/direct均0；仅为具体卸载/叶能力风险追加最小消费者，增量build/direct原件分别保留。clock seam仅测试链接层把内部FFI返回-1，产品未增加hook；PTY通过真实Application.run。公开probe源码及命令在本目录，完整stdout/exits/UTC见raw。任何探针exit0只说明探针运行完成；差异结果明确列为失败。

固定正式测试采用76b8dd1与f07635e readonly overlay；当前HEAD中41个tests/interaction_a文件逐项对冻结版本核对（准确文件数见reviewed-hashes.json），0差异。没有重复冷跑正式87向量套件。

原实现纯raw final-lintfix/pre-identity.json UTC 2026-11-11T07:37:07.502378+00:00 的193 tracked项逐项对f02 Git核对0差异；4 config身份仅按该原件与post原件记载，不声称本review捕获其历史磁盘。post UTC 07:44:03.755605+00:00记录0差异。bundle/headless/device/runtime-core/theme-integration/clean-build/clean-run的实际exit文件均0，stdout已核（正式入口含prerequisite与publicconsumer direct）。bundle missing仅src/.gitkeep，raw记录无不同源/compiled members；本review未独立重解包或以此关闭TASK101。原55c mandatory G.EXP.03失败exit1保留；f02两处嵌套条件调整已逐行确认，不改变相应原短路条件。

设备历史65项绑定29b旧源；bare ESC修正重测及剩21项各保留真实源边界，不能合称f02完整87 fresh run。dev4 headless缺当时pre-run身份，只有后续同内容快照；不追补历史证明。f02新正式入口有自己的pre身份。TASK101完整独立执行与TASK102真实host多帧/验收仍未关闭。本审查不把这些待办冒充代码缺陷，也不让有限通过结果掩盖已复现缺陷。

## 交付

`findings.json` 为统一修复批次；`reviewed-hashes.json` 固定合同/源码/测试/diff/外部纯raw身份；`raw/manifest.json` 与 `artifacts.sha256` 固定本次最小探针工件。归档仅这些报告、探针源/命令和轻量raw；source目录、SDK/cache、编译ELF/object及整个合同/Markdown树均不进入归档。
