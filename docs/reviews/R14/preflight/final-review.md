# Rich text 限定复核结论

受审固定提交：`7a33ddc7fb93da3f30007e49538cb00821a2d81b`。design.md SHA-256：`656b827e9f40727aa71badb780be86d35cf24199c6cf65de5ef67f2041cf67d4`。五份变更文件逐文件摘要在 `final-reviewed-sha256.json`，副本在 `reviewed-7a33ddc/`。原候选快照、初审 report.md/findings.json 保持原样；本文件及 final-findings.json 是其后续复核。

**contract_preflight: ready；剩余 Important：0。** 这是精确契约可进入独立测试编写的结论，不是产品实现/构建/验收通过。TASK-081正式ready记录需主代理落实已承诺的任务/AC映射和技能证据链接；TASK-009继续等待081固定测试、runtime072–075固定结果及共享文件写入屏障。

| 发现 | 复核结果 |
|---|---|
| RTP-001 | verified：Component.text与Frame.put成员归属及runtime R009规则明确。 |
| RTP-002 | verified：cjtui.text唯一validatePlainText下沉/根重导出，旧validateText仅委托；RichText调用已改为唯一新名字，无反向root依赖。 |
| RTP-003 | verified：原始bytes含intro/terminator；maxParameters字段数包括空字段/颜色操作数；全部CSI受同一digit-run≤3与参数限额，超限即时诊断，后续final不能改首错。 |
| RTP-004 | verified：首个语法/资源问题立即一次；取消/重复超限不重报；闭合未知才Unsupported，finish可追加Incomplete；同时故障与SGR语义顺序明确。 |
| RTP-005 | verified：空field仅在顶层是0，38/48空mode/channel为Malformed，整条原子丢弃。 |
| RTP-006 | verified：内容/样式/diagnostics分块等价只约束成功完整流；失败批次不交付且历史不回滚的例外明确。 |

最后限定修文的关键反例：输入 `ESC[1234` 在第四digit产生一次TooLong；随后K与m都只完成隔离，不覆盖或再报首错；随后finish在已经闭合时不再Incomplete。这消除了等待final才能辨别SGR却要求即时诊断的矛盾。输入 `[9B,33,31,6D]` 在byte上限4下可完整处理，5byte的ESC[31m则超限；不会按规范化后长度混淆。`maxSgrParameters`在最终design中已统一退役为`maxParameters`，接口/构造/复杂度引用一致。

DQ变化：05、09、14由fail转pass；其余01–04、06–08、10–11保持pass。DQ12状态权威引用与DQ13技能证据来源/可用性链接由主代理在正式准入集成元数据时补齐，不能以本次契约ready替代。009和077若同时已满足各自上游，仍必须按共享Component/Layout/run-slice所有者顺序实施；本审查不放宽原禁并行写约束。

验证方法：只读固定git show/diff、逐原反例静态推演、SHA-256。未运行新产品测试，未重复已验语言/库probe，未编辑产品、tests或spec。指定Astra/high；实际serving不可核验。
