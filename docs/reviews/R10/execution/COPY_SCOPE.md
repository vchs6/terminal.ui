# 执行证据归档范围

原始执行目录为 `/workspace/work/auto-final-execution`。本目录按字节复制原件，`SOURCE_SHA256SUMS.txt` 为当前归档文件的核对入口；`ORIGINAL_SHA256SUMS.txt` 保留执行者原始目录的完整清单，采用原始路径，不用于直接检查重命名后的目录。

| 原始路径 | 仓内路径 |
| --- | --- |
| `artifacts/real-fixture-bash/` | `terminals-fixture/` |
| `artifacts/real-example/` | `terminals-example/` |
| 其余选定 `artifacts/`、`raw/`、consumer 源码、报告与清单 | 保留相对路径 |

GUI 原图、metadata、callback ACK、ANSI raw、fence、输入、尺寸和恢复记录均保留。排除可重建 ELF、`.cjp` 制品本体、SDK、依赖缓存、XDG 缓存、编译 target 和解包的重复产品源码；实际制品 SHA、逐文件内容与消费者构建证据已保留。历史 RED 的两个源码 tar 位于测试补证目录，逐项检查为普通相对路径源码，不含 ELF、缓存或编译产物。

原 GUI 受检版本仍为 `bf308bf`，执行命令显式使用 Bash。原 XFCE 版本字段中的 Gtk 错误保留；实际版本、宿主路径和二进制关联由 `host-version-supplement.json` 与独立版本日志补足。后续 `8af39f6` 只修测试入口解释器和版本采集，复用依据见最终独立审核，未改写原图或将原执行重新标成新版本。
