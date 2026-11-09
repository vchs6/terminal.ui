# TASK-051 第2次修复复核

**spec-compliance: passed。code-quality: passed。** 结论限定于绑定Linux首片的独立代码审核与既有发现闭合；SLICE-051-001至006全部verified，无本审核范围内未解决发现。完整TASK052独立执行与TASK053验收仍由对应角色给出，不把本结论外推为全框架、发行或全部Linux能力完成。

固定受检版本：2f85fcbe4c422f4f45b69875feb4728f9bea3f8f。第1轮修复基准：32010ce47c71d4aadebd9c25288721c84e2f18b3（产品源与49edfc5f971788ca05f24989462245cc1f2a79fc相同）。初审2794136e45aee98300f4b16456dfa6b605cfdf74及review.md/findings.json、第1轮re-review.md均保留原样；那些失败结论对应历史固定版本，以本报告作为当前复核状态。预算已使用2/3次有效修复复核。

本轮没有读取作者自测报告/推理，不修改产品、正式测试或规范，不提交推送或派子代理。只审固定差异和原反例，并按verification-before-completion先运行、再作结论。

## 差异与根因复核

产品差异仅src/application.cj的InputDecoder.state4分支：非ST、非重复ESC字节先转入state3，再feed当前字节。该字节因此仍由同一控制串丢弃路径处理，UTF8 lead E4会建立剩余字节计数；“东”的9C续字节不会被误判为独立C1 ST。state3各分支都直接返回，故此回馈最多增加一层调用，不会形成无界递归。Ctrl-C仍在feed最先处理；ST/BEL与重复ESC的明确分支保持原语义。未增加全局可变状态、平行解析器或按反例文本的特判。

对比32010ce，src/frame.cj、component.cj、unicode.cj、native、build.cj及cjpm.toml均无差异；其他5项原修复路径未改，复用第1轮有效证据。src/application.cj其他分支没有变更，重点关联输入行为由本轮最小诊断和正式回归覆盖。

独立新增sos-escape-utf8测试采用原反例精确字节1b581be4b89c7365637265741b5c，并要求回调列表仅为随后独立发送的text/q，正常退出及完整termios相同。原有断言未被削弱。该模式已加入默认modes；run-slice.sh all也明确包括native-session，其原C正式回归执行仍沿前轮证据，不在本轮无依据重跑。

## 实际执行与原始结果

环境：独立no-hardlinks clone，Linux x86_64，SDK/cjpm1.2.0；SDK、固定官方cache/UCD路径与初审一致。两个普通构建分别在repo根和tests/integration/fixture执行，均退出0、输出cjpm build success：

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip cjpm build
```

正式fixture沿正常CJPM依赖/hook路径构建；未给正式消费者追加手工FFI参数。临时环境配置使用同一官方cache/registry转发路径。第一次复制环境配置误用当前目录相对路径失败，改为从fixture的../../../cangjie-repo.toml复制后正常构建；该环境准备失误未改产品/测试、未作为测试通过证据。

原审核公开API诊断程序也按review.md附录命令重新链接本次主库，再执行re-review.md附录F同一真实PTY刺激，退出0：

```text
{"mode":"basic","exitedAfterInput":false,"events":["KEY=text:a","KEY=enter:","KEY=backspace:","KEY=up:","KEY=down:","KEY=right:","KEY=left:"]}
restored=true
{"mode":"sos-unicode","exitedAfterInput":false,"events":[]}
restored=true
{"mode":"sos-esc-unicode","exitedAfterInput":false,"events":[]}
restored=true
```

这与第1轮相同字节的secret六个事件形成直接对照。诊断最后SIGTERM仅作清理；003的通过依据是payload事件为空。退出及模式恢复另由以下未改的正式测试证明。

命令：

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main sos-ignore sos-escape-utf8
```

退出0，原始输出：

```text
PASS non-TTY: no ESC
SEND PTY sos-ignore: 1b587365637265741b5c; then q
OBSERVED PTY sos-ignore: [{"code":"text","text":"q"}]
PASS PTY sos-ignore: exit=0, termios restored, bytes=206
SEND PTY sos-escape-utf8: 1b581be4b89c7365637265741b5c; then q
OBSERVED PTY sos-escape-utf8: [{"code":"text","text":"q"}]
PASS PTY sos-escape-utf8: exit=0, termios restored, bytes=206
```

固定差异git diff --check通过。构建生成的两份未跟踪cjpm.lock已清除；git status --short为空，HEAD为2f85fcbe4c422f4f45b69875feb4728f9bea3f8f。

## 最终发现状态

| ID | 状态 | 修复版本与证据 |
|---|---|---|
| SLICE-051-001 | verified | 49edfc5：Ctrl-C在未结束OSC/UTF8内退出；复用re-review.md原真实PTY证据，本轮最先处理0x03路径未变。 |
| SLICE-051-002 | verified | 49edfc5：跨160ms UTF8正常产生单个“中”事件；复用re-review.md，正常解码路径未变。 |
| SLICE-051-003 | verified | 2f85fcb：简单SOS及ESC+东残余反例均无payload回调；本轮正式PTY只收到q、退出0并恢复termios。 |
| SLICE-051-004 | verified | 49edfc5：原子owner/完整恢复；复用re-review.md及32010ce正式C回归，native源码未变。 |
| SLICE-051-005 | verified | 49edfc5：setup SIGTERM保留、read=-2；复用re-review.md及32010ce正式C回归，native源码未变。 |
| SLICE-051-006 | verified | 49edfc5：Int64极值裁剪；复用re-review.md，Frame源码未变。 |

## 验证边界

本轮只重建受检产物并运行与003修复相关的短诊断/正式PTY模式，没有重跑整套contract/native/PTY。完整Application写故障下的真实TTY端到端恢复仍未由本审核执行；初审的C partial/error/EINTR注入与成功写后提交baseline的固定源码证据保持有效，不能冒充整栈故障验收。构造、样式、宽簇、构建和包装边界沿初审及前轮范围证据复用；未宣称尚未交付的响应式、主题、编辑、覆盖层、M2或其他平台已完成。
