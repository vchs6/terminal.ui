# R8：首个可运行 Linux 实现

正式代码已进入src/、native/、build.cj及examples/minimal/，不再只有规格和探针。技术受检版本为2ad6c5ceeb0068d3b2b2d5efe010059965b9415a；后续提交仅集成证据、文档和状态，实际技术文件的相同范围由独立验收者逐字节核对。

## 本片交付

- 正常CJPM构建触发本包原生构建和相对FFI链接；固定原包/UCD输入，无调查目录运行依赖。
- graphemeClusters/displayWidth、Style/Cell/Frame，Unicode安全覆盖/裁剪及plain/ANSI独立快照。
- Text/Row/Column组件块、属性链、条件/循环及函数复用；统一render，不要求普通用户手写ANSI或坐标。
- Linux Application、基础KeyEvent、实际尺寸/resize、M1完整帧差分、成功写后提交基线、停止及终端模式恢复。
- 真实minimal示例及接入CI的独立测试入口。

## 独立质量结果

测试设计Sol/high、代码实现Terra/high、原生局部审核Sol/high、整片审核Astra/high、执行Sol/medium、验收另Sol/high，分别独立上下文和目录。主代理只做契约、调度、文档和集成，未代写产品代码或测试。许可按用户最新裁决保留实际归属，不设置声明冲突阻塞。

首次审核6个实际问题均已修复并由原审核者独立复核；控制串UTF8残余有第二轮定点回归，冷构建入口顺序有独立fresh-clone失败和后续闭合，原失败不删改。测试作者修正CJPM包装退出码风险，所有消费者先build再直接执行binary，原断言未削弱。

最终fresh clone完整冷入口运行至结尾，退出0。原始输出134行PASS：2项C生命周期、120项公开API断言、1项non-TTY及11项真实PTY。异常场景程序退出1属于预期上报，termios仍精确恢复；测试本身成功。不把cjpm test中的零本地用例冒充功能验证。

独立执行者还在5×24真实PTY运行实际minimal（不是fixture），确认中文/emoji首帧、q退出0、前后termios一致。源码包全新解包后，普通消费者正常构建、运行和直接binary均为0，无额外link参数；实际生成plain/ANSI快照，C桥符号已链接。37个包文件与最终技术提交逐字节相同，复制运行不访问产品checkout、cache或UCD。

入口：

- [独立执行报告](execution/slice-report.md)及其[原始字节](execution/slice-report.original.md.txt)，只为仓库导航作链接投影。
- [完整冷入口原始日志](execution/logs/slice-cold-product.log)与[结构化结果](execution/slice-results.json)。
- [整片复核](whole-review/re-review-2.md)、[入口复核](whole-review/entry-review.md)、[首次发现](whole-review/findings.json)。
- [逐项验收](verification/verification.md)与[实际检查记录](verification/validation.txt)；最终集成单独登记，不以作者自测代签。

## 运行

安装并加载仓颉SDK1.2.0及[Linux构建依赖](../../product/native-build.md)后，在仓库执行：

```sh
cd examples/minimal
cjpm run
```

在支持ANSI的真实Linux TTY内运行；q退出，Ctrl-C取消，窗口缩放自动重排。完整测试入口为`bash scripts/check-product.sh slice`，不是完整产品发行检查。

## 保留范围

这是版本0.0.0的首片，不是整个框架完成。完整控件、编辑、滚动、主题配置/四主题、响应式及定向通知、覆盖层、M2与其他平台继续按原任务实施；完整发行所需composition/benchmark及其验收仍pending。当前环境/证据覆盖Linux x86_64 SDK1.2.0与真实PTY，不以此声称所有Linux宿主或所有字形均验过，也不声称做了完整Application写故障的PTY端到端注入。

最终独立集成核对已通过，见[集成报告](verification/final-integration.md)：35技术文件与受检版本一致、90份原始产物复制一致、报告链接投影准确、旧完整产品验收状态未变、仓库及OpenSpec严格检查9项通过。AC-048–053按真实结果登记passed，六项仅为本有限切片。
