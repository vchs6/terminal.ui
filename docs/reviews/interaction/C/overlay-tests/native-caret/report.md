C03 原生caret遮挡义务补充：单一公开Application.run向量，未扩产品功能。
source-only fixedSHA=eea178fe0c8866a50e4a641f4df0f34769a67051；父3fcba825c6739fdfa6f4204b033866f864160d2b。
受检产品7f43176505aa3c392afc5fc897181a9eeba89e6e；H01五模式源码/预期及旧selector保持字节不变。
独立env=CJTUI_OVERLAY_NATIVE_CARET=opaque；真实按键序列s→o→s→c→s→q，普通PTY受控I015 reply1。
逻辑阶段均实际通过：原caret owner=base/(3,1)/visible→Passive opaque覆盖后None/(0,0)/hidden→关闭后原caret恢复；focus一直为base。
手算8×3中间行ijklmnop→ij   nop→ijklmnop；实际wire整行paint先于后续只读query barrier，Known hide/show及CUP2;4均通过。
一次正常build实际exit0；最终driver实际exit0、直接PTY child真实exit0、精确termios前后一致、cleanup一次/资源全0。
真实binary SHA256=f66a26368c3ade7dc14c8a77d22db03acd1c9d3a0b611e059a36631d8a03f3ab；每次执行前后即时hash一致。
pre/post核对248个repo输入、755个依赖/SDK文件、166个固定产品tracked输入；79个source/replay B/C测试文件一致。
run callback仅读caretSnapshot/immutable terminalCapabilities；snapshot/render重入禁止，action文件仅queued，绝不作为paint成功证据。
历史首次driver只等最小diff，实际backend重画整行，造成工具超时/强制退出-9；原raw保留，不计产品失败，修正driver未改Cj或重编bin。
命令/cwd/UTC/真实exit/termios/input/output/阶段文件及完整hash见raw/manifest.json；README给公开消费和真实host分类。
缺项：111对同一最终bin的三真实host/PNG/物理效果验证；Unknown不得发25h/l/s/r，仍可见物理cursor只能记未管理/不足，不能声称隐藏成功。
本次未读作者report/target、未联系作者、未改产品/契约/主仓，未跑旧五模式/旧全套；GREEN仅此受控PTY覆盖，不代表Unit C整体验收。
