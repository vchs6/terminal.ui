TASK108：TASK110 十项公开覆盖层回归一次批量冻结（执行型测试补充）。
fixedSHA=dc0e07eda0db7277992494c8a25f376e24419070；父 b745660d8e1cf5cd24daf82e205250857c981a24。
产品固定61e4de9d5c9d2681ea94242f0ffe64f2fd7fafef；只提交source五个测试文件，旧断言/golden不变。
正常构建build-formal=0；I10最小fixture修正后build-I10-corrected=0；cjc/cjpm均1.2.0。
C-I01 RED/1：cleanup仍见有效owner且接受owner post；闭包必须先整体撤销。
C-I02 RED/1：If及ForEach退休后modal仍open、ref有效、cleanup0；必须OwnerGone并恢复基础域。
C-I03 RED/1：hidden仍画BPB，hidden/disabled目标均不合格；hidden应BBB。
C-I04 RED/1：ensure提交offset3后仍open且画3/P；应AnchorGone、画3/4。
C-I05 RED/1：候选Applied/Next后minimum sum overflow停止session；应Failed/Old/继续有效。
C-I06 RED/1：独立层weight被并入普通Row预算，等价Next被Failed；应Applied。
C-I07 RED/1：显式根host被InvalidOverlayHost拒绝；应合法并挂载。
C-I08 RED/1：pending host撤销后无错误、内容已mount；应InvalidOverlayHost并统一清理。
C-I09 RED/1：Passive显式dispatch无错误且owner调用1；应InvalidProperty/0，正常NonModal正控已通过。
C-I10 RED/1：首次纯render3×2及fresh5×3漏P；随后真实snapshot后变尺寸输出观察正确，committed均保持。
核对：208个repo prehash输入、755个依赖/SDK文件；39个source/replay测试一致；锁文件仅重排行、解析版本相同。
前九项函数/公共helpers/入口与实际运行字节一致，仅I10层增加viewport(Off)，故复用九项结果而不重复运行。
历史保留且不计RED：缺toml缓存/离线registry失败、测试闭包编译错误、原I10非viewport查询错误。
缺项：修复后GREEN；首失败后的断言范围逐项列于raw/manifest.json；I05禁止measure/draw预检由源码审核承担。
命令/cwd/UTC/实际exit及完整raw/test/config/依赖/SDK hash见raw/manifest.json；无作者报告/作者联系/产品修改/旧全套运行。
本批不代表Unit C/native/package验收；复用现有OpenSpec TASK108及TDD/systematic-debugging/verification技能。
