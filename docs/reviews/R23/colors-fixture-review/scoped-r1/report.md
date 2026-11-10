# CRF001 round1 scoped re-review

**CRF001 ADDRESSED / VERIFIED。测试合同 PASS，代码质量 PASS。** 未发现本修正引入的新问题，open Critical 0 / Important 0 / Minor 0。

受检范围严格为 `3138d1a549c5941793b24183bd71cad74d2c688c` → `0d46c35456db148f08bd407825a4fd559467249a`。三个tests/colors文件、93+/5-，完整diff与root的264行审核包字节相同。未扩审旧scope、未改产品/正式tests/main/状态、未派代理。初次审核及CRF001原FAIL保留于父目录；199产品TASK165原范围PASS独立不变。

## 修正有效性

`tests/colors/pty.mjs:170` 的 `stop(expectedGrid)` 必须接收调用者已验grid，立即克隆并在q前确认当前screen相等。public fixture在精确action+fence字节断言后同步保存checkpoint（`:206`），不会在await之后把新未验证数据当expected；example传入已与最终100×40比较的initial（`:281`）。

等待原stdio **close** 后，既有error/exit/signal/termios检查保留；随后 `Screen.finalize:129` 检查decoder.end无UTF-8尾字节、无未完成resize、style完全reset，且snapshot要求无部分ESC/row。最终deepEqual把完全可解析但错误颜色的同宽晚到行与此前checkpoint比较。这直接修复原三个反例，而不是只拒绝会立即throw的wrong-width。

修正并未禁止全部合法退出输出：quiet、SGR0及同样式完整相同行都能保持完整、reset及原grid。新增stop控制使用实际Node child stdout/close、同一Screen/Session方法体；child必须收到q才能exit0。合成before/after标记明确仅用于oracle测试，未当作产品termios证据。没有另造parser或修改产品hook。

resize采样/有限pair/顺序完整帧、原14动作、手写resize目标及宽度模型未改；调用者checkpoint和终结检查只加强真实会话的最终判据。未发现新调用者遗漏或对三种合法close的回归。

## 证据与复现

按AGENTS11.1复用已证相同scope，不冷跑旧全suite。独立运行 `node audit.mjs` exit0，核154个raw hash、三个变更源hash、完整diff。保存的old-stop模块精确等于3138源经测试允许的import重定位+export，两个green模块精确等于0d46相同变换；fixed-stop-green（实际old91回归之前）与final-stop-controls源完全相同。详情见`hashes.json`、`audit.json`。

| 命令/原件 | 结果与意义 |
|---|---|
| `node tests/colors/stop_oracle_test.mjs`，`raw/crf001/old-stop-red` |3138 exit1，五非法tail均错误接受；原RED不覆盖。 |
| 同命令，`raw/crf001/final-stop-controls` |0d46 exit0。partial row、partial ESC、wrong style、truncated UTF-8、unreset style五项拒绝；quiet/reset/identical-row三项接受；八个实际child均exit0/null signal，拒绝来自正确oracle断言。 |
| `node tests/colors/resize_oracle_test.mjs`，`raw/crf001/resize-controls` |exit0，保留既有finite-pair/完整目标/inflight/负控。 |
| `node tests/colors/pty.mjs fixture example`，`raw/crf001/actual-old91-colors` |exit0，真实旧91消费者的14精确动作、RGB/六属性、31×12→8×4→100×40和q；两会话before/after termios原件相等。 |

三个source SHA256：

- README.md：`c17ec1a73d1dd44d706ab123c4f0a2a2c007968bb1065a64d1e9c6fda24f8951`
- pty.mjs：`96ace9fa46e97b14bf8653a06a2a8e730a8ce6dd306697794ed3c9ff23e90ae5`
- stop_oracle_test.mjs：`bccb4a2ed4e178ad2b20111cb35101a4e073cdc69a95bc947beb36028ffd6f8b`

本轮只判断CRF001及fixdiff新破坏。可将CRF001按独立审核标记解决并继续集成/166；不替代新199实际GUI、全部Linux或其他原有范围验收。本角色未修改任何状态权威文件。
