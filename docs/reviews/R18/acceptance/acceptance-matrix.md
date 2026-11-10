# TASK152 逐REQ / AC证据矩阵

有限Session增量PASS；下列32项当期义务有可定位证据。P30明确为未执行的父平台范围，判insufficient_evidence，不计入当前有限增量通过，也不关闭父041。全部来源与限制详见[验收报告](report.md)。原件主目录为 `/workspace/work/session-extension-execution`；完整路径见[JSON矩阵](acceptance-matrix.json)。

| ID | REQ / AC / 合同 | 验收事实 | 判定及范围 | 原件入口 |
|---|---|---|---|---|
| P01 | AC151/152；来源链 | 固定产品、测试、合同与实际构建内容一致；补充包含47 namespace修复 | pass | `scope/product-source.json`<br>`scope/formal-tests.json`<br>`scope/contracts.json`<br>`scope/sdk-files.json`<br>`scope/seed-files.json`<br>`scope/configs.json` |
| P02 | AC149/151；S002/S011 | 正常公共消费者能使用7入口、全部字段/枚举，既有裸None兼容 | pass | `raw/build/execution.json`<br>`raw/formal-all/execution.json` |
| P03 | REQ010.4；S003 | 首次无snapshot、open后mount前建立、关闭后保留、每run新id；跨线程getter安全 | pass | `raw/session-matrix/000-headless-Direct-0/results.tsv` |
| P04 | REQ010.4；S003 | Auto真实TTY为Unknown/NoEvidence；声明仅ExplicitConfiguration；完整发送均SentUnconfirmed | pass | `raw/session-matrix`<br>`raw/hosts2/xterm-default/consumer/results.tsv`<br>`raw/hosts2/xterm-enabled/consumer/results.tsv` |
| P05 | REQ010.1–4；S003 | 无请求不发可选控制；Disabled/NoDevice合法请求零输出且核心继续 | pass | `raw/session-matrix/000-headless-Direct-0`<br>`raw/session-matrix/004-disabled-Direct-0`<br>`raw/session-matrix/010-no-request-Direct-0` |
| P06 | REQ010.1；S004 | copy空串/Unicode/换行/NUL/ESC/C1保持原始UTF8，仅进入RFC4648数据 | pass | `raw/session-matrix/001-wire-Direct-0`<br>`raw/session-matrix/068-wire-TmuxPassthrough-0`<br>`raw/session-matrix/185-wire-ScreenPassthrough-0` |
| P07 | REQ010.1/2/3；S004 | copy65535/65536/65537、title1023/1024/1025、icon1048575/1048576/1048577及多字节预算 | pass | `raw/session-matrix/002-bounds-Direct-0`<br>`raw/session-matrix/069-bounds-TmuxPassthrough-0`<br>`raw/session-matrix/186-bounds-ScreenPassthrough-0` |
| P08 | REQ010.2/4；S004 | 非法UTF8及全部C0/DEL/C1 title拒绝，首个byte offset准确，拒绝前不push | pass | `raw/session-matrix/003-invalid-Direct-0`<br>`raw/session-matrix/070-invalid-TmuxPassthrough-0`<br>`raw/session-matrix/187-invalid-ScreenPassthrough-0` |
| P09 | REQ010.3；S003/004 | icon预算内Unsupported/NoImageAdapter、零输出、不解析PNG、不发OSC0/1 | pass | `raw/session-matrix/002-bounds-Direct-0`<br>`raw/hosts2`<br>`raw/hosts3/tmux-allow`<br>`raw/hosts4` |
| P10 | REQ010.4；S004/005 | 三个typed单层route精确包装，wire含wrapper；无自动mux猜测 | pass | `raw/session-matrix/001-wire-Direct-0`<br>`raw/session-matrix/069-bounds-TmuxPassthrough-0`<br>`raw/session-matrix/186-bounds-ScreenPassthrough-0` |
| P11 | REQ010.4；S006 | inactive id=0；后台/跨会话/getter/build/mount/cleanup为InvalidContext零输出 | pass | `raw/session-matrix/000-headless-Direct-0` |
| P12 | REQ010.4；S006 | 既有FIFO/4096/cutoff/owner失效/stop丢弃；copy不增加frame | pass | `raw/session-matrix/000-headless-Direct-0`<br>`raw/session-matrix/012-fifo-Direct-0`<br>`raw/session-matrix/011-cancel-before-Direct-0` |
| P13 | REQ010.4；S006/008 | 首字节前stop为Cancelled；完整写后stop仍SentUnconfirmed；忽略Failed仍结束run并抛首错 | pass<br>Stop ordering uses fixed-source review plus boundary runtime evidence, not a claim of exhaustively sampled concurrent timings. | `raw/session-matrix/011-cancel-before-Direct-0`<br>`raw/session-matrix/275-fault-copy-Direct-1-aggregate` |
| P14 | REQ010.2/4；S007 | Unknown stack不push/pop；无scope NoSavedTitle/NotNeeded；修改但未保存RestoreUnavailable | pass | `raw/session-matrix/009-unknown-title-Direct-0` |
| P15 | REQ010.2/4；S007 | 一次push、多次set、一次pop；重复restore零字节NoSavedTitle/NotNeeded；显式pop后close空cleanup；随后set建新scope | pass | `raw/session-matrix/005-ledger-Direct-0`<br>`raw/lifecycle-hosts` |
| P16 | REQ010.2/4；S007/008 | 完整push+set零字节失败必须安全pop一次；普通后续API仍Cancelled，首错不丢 | pass | `raw/session-matrix/038-fault-set-Direct-0`<br>`raw/session-matrix/125-fault-set-TmuxPassthrough-0`<br>`raw/session-matrix/230-fault-set-ScreenPassthrough-0`<br>`raw/session-matrix/277-fault-set-Direct-0-aggregate` |
| P17 | REQ010.4；S007/008 | save失败不set；save/set任意部分失败绝不pop或恢复控制 | pass | `raw/session-matrix/039-fault-set-Direct-1`<br>`raw/session-matrix/126-fault-set-TmuxPassthrough-1`<br>`raw/session-matrix/231-fault-set-ScreenPassthrough-1`<br>`raw/session-matrix` |
| P18 | REQ004/010.4；S008 | 唯一writer准确Int64计数，0/short/EINTR/EAGAIN/write=0/永久失败分类正确 | pass | `raw/session-matrix`<br>`scope/regression-reuse.json` |
| P19 | REQ004/010.4；S008 | pre-write allocation失败零输出不污染parser/停止健康session，后续可重试 | pass | `raw/session-matrix/018-fault-allocation-Direct-0`<br>`scope/regression-reuse.json` |
| P20 | REQ004/010.4；S008 | 部分故障后所有屏幕/模式/扩展/cleanup全静默，无CAN/SUB/ST/BEL/reset/pop | pass | `raw/session-matrix/275-fault-copy-Direct-1-aggregate`<br>`raw/session-matrix/272-fault-screen-Direct-1`<br>`raw/session-matrix/273-fault-screen-Direct-2`<br>`raw/session-matrix/274-fault-screen-Direct-5` |
| P21 | REQ004/011；S008 | unsafe同进程第二Application/open拒绝；零写失败close后可reopen | pass | `raw/session-matrix/038-fault-set-Direct-0`<br>`raw/session-matrix/039-fault-set-Direct-1` |
| P22 | REQ004/011；S007/008；AC020局部 | 正常/取消/输入失败/callback/UI/title/native组合失败仍完成独立清理，主错及附加错不被覆盖 | pass | `raw/session-matrix/275-fault-copy-Direct-1-aggregate`<br>`raw/session-matrix/276-ledger-error-Direct-0-aggregate`<br>`raw/lifecycle-hosts` |
| P23 | S012 | 返回steps与cleanup外层/嵌套steps修改不反写ledger或下次结果 | pass | `raw/session-matrix/005-ledger-Direct-0`<br>`raw/session-matrix/277-fault-set-Direct-0-aggregate` |
| P24 | REQ010.1/2/4；真实XTerm | XTerm398 default clipboard拒绝、SetSelection正例、title-off独立负例 | pass | `raw/hosts2/xterm-default`<br>`raw/hosts2/xterm-enabled`<br>`raw/hosts2/xterm-titleoff` |
| P25 | REQ010.2/4；真实VTE | VTE0.80.1默认与dynamic-title各自效果与恢复程度真实 | pass<br>Instrumented actual VTE current viewport text only; no full cell/style/font-map conclusion. | `raw/hosts2/vte-default`<br>`raw/hosts2/vte-dynamic` |
| P26 | REQ010.1/2/4；真实tmux | default、clipboard-on、outer-denied、passthrough off/on分别验证 | pass | `raw/hosts2/tmux-default`<br>`raw/hosts3/tmux-allow`<br>`raw/hosts2/tmux-outer-deny`<br>`raw/hosts2/tmux-pass-off`<br>`raw/hosts2/tmux-pass-on` |
| P27 | REQ010.1/2/4；真实screen | screenplain与显式passthrough，标题支持不推导栈恢复 | pass | `raw/hosts2/screen-plain`<br>`raw/hosts2/screen-pass` |
| P28 | REQ010.1；AC030局部；真实SSH | stock ssh -T+remote script PTY运行实际产品，OSC52目标为本地私有终端 | pass<br>Private loopback stock SSH -T plus remote script PTY only. | `raw/hosts4/ssh-enabled`<br>`raw/hosts4/ssh-denied` |
| P29 | REQ010.1/4；无query/OS工具 | 产品不调用shell/xclip/wl-copy、不读clipboard、不发OSC52?，host观察工具与产品分离 | pass | `raw/no-product-process`<br>`scope/admission.json` |
| P30 | REQ010/011；有限真实VT | 无图形可选能力不成为核心前提；S008有限资源路径真实 | insufficient_evidence<br>Current830 kernel VT not executed; formal151 card and frozen148 matrix do not require a new kernelVT run. Full AC041/font-map/094 remains pending. | 当前830未执行；后续094/096/097/041 |
| P31 | AC149/151/152；S010 | 无第二writer/runtime/队列/ANSI或Unicode内核/新依赖；每实体单文件 | pass | `scope/admission.json`<br>`scope/product-source.json`<br>`/workspace/work/session-extension-review/report.md` |
| P32 | AC151/152；交付 | 正常bundle lint/advisory不隐藏、实际clean package源码清单与普通消费者一致 | pass<br>Scoped package/consumer passed; full release checker exit1 and 331 advisories retained. | `raw/bundle`<br>`raw/full-bundle-check`<br>`scope/package-members.json`<br>`scope/clean-source-final.json`<br>`raw/clean-build`<br>`raw/clean-example-pty-artifacts` |
| P33 | AC152；归档链 | 每条事实原件可定位，最终hash在host/Xorg退出后冻结，代表PNG实际查看并交叉核对 | pass | `manifest.json`<br>`artifacts.sha256` |

逐host的标题/clip正负例、恢复路径及33项原始证据需求保留在报告与前读pending-matrix，未用本表结果覆盖历史状态。S007补充四配置与真实host自动cleanup三例各自定位；主278矩阵为正式运行，297仅本角色离线核验组数。全部验收判断均限定固定source/deps/config及已记录宿主。
