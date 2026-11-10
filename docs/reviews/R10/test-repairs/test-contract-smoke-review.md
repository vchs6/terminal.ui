# 有限 package-smoke 合同源独立核对

结论：这四份固定内容可作为 AC063 中“正常解包依赖消费者、plain/ANSI 导出、真实 PTY、resize、q 与精确 termios”的有限 smoke 证据，未发现本次已有执行中尚未被原始证据覆盖的缺项。它们不代表全部 AC063，也不代表完整 release checker 通过。resize 的通用等待谓词有明确局限，需与现有 raw 的实际尺寸证据一起引用，不能只引用执行者的 PASS 文案。

本核对只读固定源码、既有命令元数据及原始字节，没有改实现/断言，没有重跑 consumer、构建、既有检查或 GUI。

## 固定合同与输入

合同：bf308bf 中 openspec/changes/implement-color-style-output/tasks.md 的 3.2 / TASK-063 card，以及 docs/acceptance.md AC-063。冻结要求包括 reviewed source、正常 bundle / actual cjp 消费、无私有 flags、真实 TTY 恢复、command/result/raw/hash 齐全；完整 release 缺项不得标为通过。

四个受核原件都位于 /workspace/work/auto-final-execution/，读取后再次核对 hash 未变化：

| 文件 | SHA256 |
| --- | --- |
| consumer/src/main.cj | d4d8e620390fde5f884bb29dd4ad7c530363464e3205f09a13574923a13225a6 |
| consumer/cjpm.toml | c7f8f04ec3921945b4c7226fe371a10039adf4a15455ca870b8b7efcf6c0484c |
| consumer-pty.py | 347ffeb682614c4b68e7b81e8a940d788e54a08fcae46e3382fbbb7413fbdd82 |
| verify-consumer-output.py | cbbed40a5b5f98bc19f57bafb2f34a03e1a30744c0ab7b0a446c9de09bf3f6f2 |

原样源码、合同投影、受核 hash、相关既有日志及 raw 复制保全于 evidence/package-smoke-contract/。复制不修改执行者原件。

## 逐项合同核对

| 范围 | 独立源码判断及既有证据 |
| --- | --- |
| 正常消费者依赖 | manifest 是 SDK 1.2.0 普通 executable，唯一产品依赖 cjtui path=../unpacked/cjtui-0.0.0；无 ffi/private link-option/override flags。main 只导入 cjtui.* 和标准 env/fs。依赖解包目录，与既有消费元数据中的实际 archive SHA 对应；不是从主仓私有内部路径导入。 |
| 公开构造与运行 | Column/Text/Color/render/Frame.toPlainText/toAnsi/Application/onKey/stop 均属冻结公开用法；应用不发 ANSI，也未选择能力 override 或修改 native/product。PTY 与 ioctl 只存在测试驱动侧。 |
| plain 与 ANSI | 同一公开 root 含普通标记、RGB、bold/italic、中文及 ZWJ emoji。普通二进制直接执行后写两类文件。verifier 对离线和交互两份分别要求 plain 无 ESC、两行关键文本和六行结构，ANSI 有 CSI、确切 RGB250,0,0、SGR1/3。该有限 smoke 不重复完整颜色/宽度/diff 套件。 |
| 实际退出 | 既有 stage-a-consumer-build、snapshots、pty、output-check 的 .meta 分别记录真实 cjpm build / 直接 binary / Python driver / output verifier，actual_exit 均为 0。没有 cjpm run 包装状态冒充 binary 状态。 |
| 真实 PTY | pty.openpty 创建真实内核 PTY；setsid/TIOCSCTTY 设置实际 controlling terminal；被测真实 executable 的 stdin/out/err 接 slave。不是虚拟屏幕、替身 executable 或伪造 stdout。原始数据保存在 session.raw。 |
| resize | 驱动对实际 slave 执行 TIOCSWINSZ 6x40→9x54，并发送实际 SIGWINCH。等待谓词本身只检查 raw 增长，局限见下；本次已有 raw 直接证明随后完整出现 9 行、54 列的重绘。 |
| q 与失败行为 | 驱动向真实 master 写 q，等待实际进程退出，要求 p.wait()==0。任一 10 秒 timeout 都抛异常，finally 的 kill 仅清理未退出进程，不计成功。 |
| 精确 termios | 打开 PTY 后取得完整 termios.tcgetattr(slave)，程序实际退出后在关闭 slave 之前再次取得；直接比较两个完整列表（含所有控制字符/速度/flags）。驱动没有代产品恢复 termios。元数据的 restored 来自同一实际比较，源码同时 assert before==after。 |

## resize 等待谓词的边界与现有 raw 补证

consumer-pty.py 在首次看到 CLEAN-CONSUMER 后记录 initial=len(data)，然后 resize，并以 len(data)>initial 为等待条件。若初帧尚有字节留在传输中，该条件理论上可能提前被初帧残留满足。因此此谓词单独不能作为一般 resize 回归 oracle；不能把它描述成完整后渲染 transport fence。

本次不需要重跑或修改这份有限 smoke：只读现有 session.raw 已观察到先后两组 CUP 行序列，第一组 1..6，第二组 1..9；初始第6行是40个 ASCII 空格，第二组第9行是54个 ASCII 空格。后者不可能来自原6x40初帧，直接证明该原始执行确实输出了 resize 后的完整范围。关键尺寸证据使用 ASCII 空格行，未把 Unicode 码点数当一般显示列宽。解析观察记录于 evidence/package-smoke-contract/existing-raw-observation.json。

受核 raw SHA256：524b47e8cee7540313ee3e41f0dde4c110cfe314495978a347a42decd407aca8（920 bytes）。该观察是对既有原件的只读复核，不是重新执行消费检查。接受本次 resize 结果时应同时引用这个 raw 见证；将此脚本以后用作冻结回归，应改为要求可归因的新尺寸完整输出后再声明 resize 通过。

## 证据来源与有限结论

既有四步消费者元数据记录 archive_source_commit=ead6a8d732c96fc108a52df3775dea8f84a84c59、archive_sha256=fe5c09e082012e83cfcfa38c194027b558b02c80596f1aad9e7d032c71c63f95，consumer manifest 为上述已核固定内容。范围是该实际解包产物的公开 smoke，并非这里重新审核或重建了归档。原始源码及元数据归档后再次核对固定源 hash 相同。

没有私有 API/链接补救，也未发现通过更改产品、替换场景、捕获错误退出当成功、人工恢复 termios、略过输出条件来通过的迹象。plain/ANSI 和 q/termios 的直接断言合理；resize 的源码等待局限已由本次原始输出补足，而不是被忽略。

完整 AC063 仍要结合已有 cold 全入口、冻结颜色/静默 PTY、实际 bundle 审查等独立证据判断。既有完整 release checker 因 composition/benchmark 缺项的结果必须继续如实保留，不能被这份有限 smoke 的通过覆盖。没有新增正式 tests 项目或提交；本文件是独立测试设计角色的固定内容核对，非执行者自评。
