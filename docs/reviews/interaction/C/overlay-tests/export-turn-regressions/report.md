TASK108 追加正式回归：X01 / X02（执行型测试补充；不改变产品契约）。
固定测试：bcaf5c19849a44db9cea884d40d28ed102ab8c46；父版本 b82e9d13a235c13b4b6b6d62a1761e097df45962。
受检产品：68161d37771e7fb5c9b5882a736e6adfecc1a614；仅 source 提交五个 tests/interaction_c 文件。
契约：R004、I009、C.1/C.6；公开 API 与手算 4×2 网格，无旧断言改动。
X01：合法 batch 建层、scrollTo(3)、ensureVisible(6)，随后纯 render(root,0,0)。
X01 原始控制通过；导出后 handle=false / AnchorGone / layer invalid，实际 exit=1，行为 RED。
X01 要求保留 handle/ref/已提交 offset，下一应用快照为 A␠␠␠ / fg␠␠、offset=5。
X02：同 UI 线程普通顶层 openOverlay 返回 handle、code=NO_ERROR，实际 exit=1，行为 RED。
X02 要求 WrongUIContext 且无 reserve/mount；同内容随后合法 batch 挂载、清理各一次。
正常 cjpm build 实际 exit=0；两次实际 binary 单独运行，各自 exit=1，未超时。
复用依据：206 个 prehash 输入、166 个固定产品 tracked 输入、38 个完整测试文件及 env 均核对一致。
SDK cjc/cjpm=1.2.0；recovery-audit exit=0；按 AGENTS 11.1 不重复编译/运行。
命令、cwd、UTC、实际退出、完整 raw/test SHA256 及 binary hash：raw/manifest.json。
历史 original/ 探针仅保留原件，不计本次产品 RED；未读作者报告、未联系作者、未修改主仓/产品。
缺项：修复后 GREEN 未执行；X01 后续身份/offset/ensure 及 X02 无副作用/合法 batch 断言因首个失败尚未到达。
本报告仅交付两条正式测试及固定产品 RED，不代表 Unit C 整体通过或产品修复完成。
技能：cloud-environment-runtime；verification-before-completion；既有 OpenSpec TASK108 卡及契约只读复用。
