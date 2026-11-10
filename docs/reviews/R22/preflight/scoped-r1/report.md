# scoped-r1 限定复核结果

**规划preflight通过（design_reviewed），LC-PF-001–003全部verified，无本范围未决Important。所有任务仍planned，不等于产品ready或功能/完整Linux验收通过。**

最终固定修正输入 `59bea18063a4f830e93844ac194169167b165132`。首轮失败版本 `df9612e66418750c6cb712b3ff035c1789ef8292` 的report/findings/dq/hashes未覆盖；本轮中间 `9b3776d475cd8888dc13d45ec6a978aba9cf33ef` 的报告、finding和指纹保存在 `intermediate-9b3776d/`。只审原三finding及其修正行，没有新开其他功能审查。未改主仓、未跑功能套件、未派代理。

| Finding | 固定文本复核 | 结论 |
|---|---|---|
| LC-PF-001 | C003完整snapshot签名含glyphMode默认Unicode，旧双参调用兼容；010输入加097、L4核Unicode/Auto=Unicode/Ascii；离线Ascii明确生成ellipsis，业务Unicode不转码、边框设备投影与逻辑文件分开，Frame文件方法不增glyph参数 | verified，无新增公共API或离线边框承诺 |
| LC-PF-002 | 2.1是无L3状态协调标题，001/002/003/004/041各有独立checkbox、输入、实际拟交付docs和manifest、原AC、L4与planning_gaps；001/003主追踪与原AC相符；041.a在124前交M1子接口、不等147、不关闭完整AC，041最终交付仍后置M2 | verified，五项可独立判定且共享证据 |
| LC-PF-003 | 021归WP005，明确010完整可见快照、020 M1恢复输入；不等027/M2/最终041 | verified，原依赖保留，无新增反向环 |

本轮恢复DQ-02/03/08/11/12在这些修正范围的通过；初轮其他检查只沿用原已检查范围，未声称复核后续无关文件变化。未来固定source/test/cjp/host/命令缺失被诚实列为planning_gaps，不是编写未来计划的阻塞。技能/工具可用性、正式测试、产品输入和实际依赖仍须逐卡ready前核对。

## root机械唯一权威迁移的最小步骤

1. 一个可恢复文档提交中，将本change改为明确接管001/002/003/004/008/010/020/021/023/024/041的唯一任务状态；五个最终原任务保留独立记录，所有尚未执行卡保持planned。不得把preflight通过直接勾为ready/completed。
2. docs/tasks对应活动checkbox/status改成稳定编号、父项/需求/前置关系及具体change/tasks链接；旧任务定义可保留只读历史，但不得再维护第二份状态。保留021→010/020(M1)、041 M1→124→M2→最终041的分段语义。
3. 027留在theme/tasks唯一状态，由原卡追加或引用C006的L4/021单向前置；本change只链接。022/031、030和123–162保持现有权威，不新建同义任务。
4. docs/acceptance唯一AC事实不因迁移改变。总计划/progress只记录映射与本复核引用；后续逐卡依实际固定输入、工具技能、共享源屏障和DQ准入推进。

以上迁移可以在产品尚未完成时进行，无需再等未来完整产品作为写计划或转移权威前提。只读复核依据是固定Git对象diff、原Glyph G002/G005/G006/G007/G009、原AC及DQ规范；JSON格式和finding闭合状态经本轮命令核对。
