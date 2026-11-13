TASK113 FORMAL ACTUALGO：K001–K004/F001–F003/F006–F007独立测试冻结，不含编辑/产品实现。
fixed test-onlySHA=c96cc601c547f869e64632e955091cf44546d192；source父91f79bbad8d22d1902f03a267430bbb2bd2a1c14。
当前产品源码等于accepted7f；实际080/084/088/092/102/107/112/152前置由root接受，C112公开原件SHA已核对。
原PF001–004在88ed独立闭合；旧execution_ready=false是历史依赖状态，不伪称仍未designreview；R17 F006/F007资格保留。
phase01真实pipe正控：byte0=0、byte255=255、timeout=-1，实际exit0。
phase01真实POLLIN|HUP：native首-3仍留下完整ABC，独立read取3字节及真实read0=0，native EOF仍-3，合同断言exit1。
phase01外部read/poll仅重映射FD到真实OSpipe：真TTY cjt_open/close、实际read3/read0正控exit0，精确termios恢复；native尾读缺口exit1。
没有mock cjt_read/返回值、没有把PTY masterclose丢尾当EOF；根冻结原Int32->Int32 ABI，新增actual-read0=-4，其余含-5不变。
phase02正常当前源上游public consumer实际build0/run0，覆盖Canvas/focus/activeTarget/viewport/modal关闭恢复与Session152 NoDevice诚实结果。
phase03当前public Keyboard consumer实际compile exit1：缺KeyboardIssue/Decoder/Limits/Batch等K API，无伪造实现、无陈旧可执行文件。
缺API RED不是新K行为失败；旧声明/语法/负例/FIFO仅复用原语言或基础设施范围，不称当前产品通过。
保留原pure手算golden及七模式旧device，追加F006公开报告预算8/9/64与UTF8 C1取消向量。
新formal_dispatch/formal_device按旧ledger冻结目标锁/失效、diag提交→begin、4096公平性、真实EOF回调、stop/signal、2004unsafe及单decoder边界。
UNEXECUTED：所有新K解码行为、完整consumer body类型检查、formal_dispatch、旧七Keyboard device模式和全部formal_pty selector。
UNEXECUTED：114新-4实际应用finish/issue路径、2004故障行为、真实宿主按键/PNG及116/117接受；有限counter/内存证明仍需实现源码审计。
当前能力可行性已实际验证，缺新K API不阻塞本次testfreeze；未来真实fixture问题由独立测试role最小修正，不降合同。
入口bash tests/keyboard/run.sh [--pty]已冻结；run-slice接线归root，未修改main/规格/产品或接触实现者自评。
phase04静态shell/Python AST/native C严格syntax检查exit0；原23文件历史保留，旧断言语义未降。
最终audit0：40正式测试文件source/replay一致，166产品输入及755依赖/SDK文件未变，上游真实bin执行前后hash一致。
01/02/03不可变manifest保持原hash；04冻结manifest、逐命令cwd/UTC/actualexit、pre/post及bin hash由raw/handoff-index.json关联。
只在新keyboard-tests/final修改测试；无子代理、无重跑已有效probe/build或全A/B/C/Theme/包suite，无新registry服务。
本交付是113正式测试准入及准确UNEXECUTED清单，不代表114已实现或117/Linux整体验收完成。
