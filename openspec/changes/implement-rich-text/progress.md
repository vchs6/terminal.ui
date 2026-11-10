# SDD ledger — plan: openspec/changes/implement-rich-text/tasks.md

主代理基于独立text-contract-audit提出正式候选。只读依赖探针已证明parseCSIParams接受不完整/错误final/private/colon，必须先完整框定再复用；四种Text重载在SDK1.2真实独立stub语言探针通过，但不是正式产品API编译通过。原始证据尚在独立目录，后续选取归档。本文候选待独立builder/preflight，产品等runtime A+B交付和081固定测试，不能把并行合同准备当已完成009。

主代理裁决：显式component字段覆盖span，span覆盖基础Style；TextSpan惰性，RichText拼接后统一validate/分簇，允许跨span CRLF；所有值防数组别名；UTF8非法fail-close；SGR限额与关闭状态精确code；超限控制串持续隔离直到合法终止符。无用户新问题，都是既有目标下可逆工程选择。完整Linux目标保持活动。

独立rich_text_preflight指出成员receiver、验证包方向、原始byte/参数计数、首故障诊断、SGR空operand，以及异常流已交付前缀不可能分块等价的缺口。主代理已逐项落实候选：public validatePlainText下沉text+根薄委托、成员签名分节、原始bytes含intro/terminator、含empty/operand字段数、每序列首错即报且finish可额外Incomplete、资源先于同byte语法、语义左到右首错、38/48空operand拒绝、成功完整流才归一化等价。AnsiTextIssue增加Equatable供公开typed诊断比较。待审查者最终限定核对；尚未派测试或产品。

固定4a7b955复核只余“final前不能知道是否SGR”的限额歧义。主代理将字段明确命名maxParameters，全部CSI参数区适用字段数/连续decimal-run≤3的有界限制，到超限byte即判TooLong，不待final，不让未知final覆盖首错。修正RichText验证函数名为下沉唯一validatePlainText。本项是候选冻结前澄清，无已发布兼容变更。

独立preflight最终7a33ddc ready，design hash656b827e9f40727aa71badb780be86d35cf24199c6cf65de5ef67f2041cf67d4，剩余Important0。DQ12原009转移/081–084AC单引用、DQ13技能来源/使用链接在本次正式准入补齐，不改变功能API；081作者rich_text_test_author指定Sol/high已按冻结合同开工，独立/workspace/work/rich-text-tests/source，不改run-slice并发接线，先纯核心missingAPI RED，runtime相关consumer等固定新输入。009产品尚未准入。

2026-11-10：TASK078 scoped-r1独立双PASS（DYN-F001关闭），079固定216b2ab独立执行PASS，080 Astra/high有限PASS，原AC015/016/032原文范围充分。627执行清单文件与18验收文件、两个严格JSON最终Xorg-artifact投影已验证；原Xorg捕获后正常退出只追加日志prefix证据保留，不修改原件。root正在机械归R13并登记状态，不重复套件。新TASK009 rich_text_implementation_resume Sol/high（仓颉语言适用，AGENTS13.2）从9bc493f独立实施，正式081测试3f60142/7ba2cd4已固定。环境恢复仅重建代理连接，保留原文件/relay/有效证据。

TASK089 async测试准备原83fac077已机械集成179c851，78路径/22场景；真实async-only RED必须等088基础Theme，故089不勾选、026不准入。TASK148独立Sol/high session_test_author准备正式消费者与真实旧产品RED；有限宿主协议只作事实输入。新的cursor_protocol_design Astra/high仅外部候选设计：依据真实VT不回显隐查询/不支持save-restore，root选择Unknown保留显隐、已知才管理并恢复，详细输入兼容待候选及独立审查，不实施/不提前验A或020。

恢复续接索引（原历史完整保留）：
TASK081 originale6b3229a+6d3ae135 integrated3f60142/7ba2cd4, formaltests fixed; independentpreflight7a33ddc noImportant. Runtime080 accepted216 source, R13archived/pushed57403ce.
TASK009 BASE9bc493fe9c1943b8608be0969c0b2d5e4cfdd924, currentauthor /root/rich_text_implementation_resume Sol/high, productdir /workspace/work/rich-text-implementation/source, factualledger /workspace/work/rich-text-implementation/progress.md, brief task-009-brief.md, finalreport /workspace/work/rich-text-implementation/task-009-report.md. Prior rich_text_implementation lost environment before edits; resumed same worktree not restart. Models perAGENTS13.2. Rootfuturecontracts df9612e no source change and do notalterRich0081testcontract. Author reportedfirst11groupsGREEN selfcheck, not independentlyaccepted; final fixedcommit awaited.
After009fixed: generate fullBASE..HEADreviewpackage, freshAstra/high082 noauthorselfassessment, thenSol/medium083 independentactualchecks/normalbundle/cleanpublicconsumer and actualrunPNG asaffected;084 Astra/high independentacceptance. Rootreceivesfindings→formaltestauthor→sameproductauthorfixloop; nevereditproduct/tests. After084 route Session149–152 (148testsbeingprepared) beforeGlyph andTheme; originalallLinuxtask remainsactive.

TASK009固定原034685d已集成d8c5be0（local，082/083/084未通过不推新产品checkpoint）；082独立真实probe确认CSI nonASCII lead先出现但延迟到完整scalar才判语法，后byte资源可能抢首错。root核design5/6 ASCII边界与首个问题立即报，裁定C2已是非法CSIbyte，当时Malformed；后续UTF8验证继续、samebyte资源优先不变。按SDD fix-loop准备round1/5，独立Sol/high formalregression先实际RED，再原产品作者修，根不改产品/tests。完整Linux任务继续。
