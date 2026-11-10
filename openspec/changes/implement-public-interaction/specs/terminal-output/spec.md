# Public interaction output delta

## ADDED Requirements

### Requirement: Scoped paint authority

框架 SHALL 将自绘能力限制在本次同步draw的局部坐标、分配区和有效clip内，不暴露可变整屏Frame、stdout、ANSI或flush。上下文结束后任何读写报ExpiredPaintContext，异线程或异session优先报WrongUIContext；宽字符保持整簇不变量。

#### Scenario: Saved context
- **WHEN** 用户保存PaintContext并在draw返回后读size或调用put
- **THEN** 两者均报ExpiredPaintContext，不能写入后续帧或访问其他节点区域。

#### Scenario: Wide cluster across clip
- **WHEN** 宽簇首格在clip内但延续格在clip外
- **THEN** 整簇不绘，不留下半字或孤立延续格，也不借局部写入突破clip。

### Requirement: Session-owned logical caret

框架 SHALL 只接受当前聚焦Canvas自身的逻辑caret请求，统一转换、裁剪及按后续不透明层遮挡判定显隐。caret与画面由会话统一输出并在完整成功后提交基线；headless能查询最近完成目标的caret，组件不得直接控制终端光标。

#### Scenario: Caret-only movement
- **WHEN** 完整网格未变化但有效逻辑caret位置改变
- **THEN** 会话输出所需位置变化，不因网格相等而丢失caret更新，失败仍按既有恢复围栏处理。

#### Scenario: Clipped or covered caret
- **WHEN** caret位于零尺寸viewport、clip外、宽簇continuation或被opaque格遮挡
- **THEN** caret隐藏；透明hole不遮挡，颜色或字符相同的不透明格仍遮挡。

#### Scenario: Resize ensure from last completed frame
- **WHEN** viewport尺寸变化且最近完成帧有仍有效的caret局部rect
- **THEN** 布局阶段用该rect作一次ensureVisible；新逻辑caret位置由事件明确请求，paint不得发滚动命令或启动布局反馈循环。

### Requirement: Theme-aware opaque surface

框架 SHALL 以公共surface意图区分额外不透明表面填充与透明hole。Modal内容根默认Opaque，以当前解析Style填其布局盒，不能隐式写background(Default)覆盖主题；透明surface不取消原显式或主题本地background填充。

#### Scenario: Modal without local background
- **WHEN** modal没有显式背景声明且应用切换已接受主题
- **THEN** modal布局盒仍由真实空格不透底，背景随同一resolver改变，外围不自动变成全屏幕布。

#### Scenario: Transparent hole versus styled space
- **WHEN** nonmodal层某格未绘制而另一格绘制带Default背景的空格
- **THEN** 前者透出底层，后者覆盖底层；关闭层显示当前底层状态，不恢复打开时截图。

### Requirement: Stable complete render reference

框架 SHALL 保持全局render完整M1布局/绘制参考及独立Frame结果；分离measure/paint依赖只规定失效类别，不使本变更宣称局部测量、局部绘制或大文本增量编辑已经实现。

#### Scenario: Paint dependency invalidation
- **WHEN** 只改变caret或选区且measure依赖不变
- **THEN** measure依赖集合不因此加入caret，dirty分类保持paint；完整参考调用仍可以重跑measure，后续M2收益必须另有证据。

#### Scenario: Detached and mounted root defaults
- **WHEN** 分别对未挂载描述和已挂载Application root调用全局render
- **THEN** 前者保持离线静态默认、不隐建滚动session；后者完整M1消费既有session的viewport/offset/层栈，与snapshot同逻辑输入等价，不读写M2缓存。
