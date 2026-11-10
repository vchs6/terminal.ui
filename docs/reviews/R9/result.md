# R9：Linux 布局、装饰与仓颉源码组织

本轮交付声明式布局、字符装饰和可运行面板示例。技术受检版本为40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940；后续集成只记录证据、说明和任务状态。版本保持0.0.0，未发布。

## 实际交付

- 固定/最小/自动尺寸、主轴加权空间分配、padding/gap、主轴和交叉轴对齐、逐行文字对齐；整数余量确定分配，实际视口优先。
- 共享Frame的矩形填充、单线/圆角/双线/ASCII边框及字符阴影；维护宽字符完整性，服从祖先裁剪，只在显式设置时装饰。
- [layout示例](../../../examples/layout/src/main.cj)通过组件块、属性链和事件回调构造标题、加权面板与底栏，不写ANSI或屏幕坐标；d开关装饰，q退出，resize自动重排。
- style、geometry、text按职责分包，12个产品类型各自单文件；[根包重新导出](../../../src/exports.cj)保持现有公开导入方式。用户指定的两份[仓颉工程参考](../../development/cangjie-conventions.md)固定版本并记录采用范围。
- 修复正常源码打包暴露的Application清理问题：finally仅执行清理，正常恢复失败显式报错，业务与恢复双失败同时保留信息。

## 独立质量证据

测试、产品实现、审核、执行和验收分别独立上下文与目录，主代理只做契约、调度、文档和集成。测试设计Sol/high，布局与装饰Terra/high，源码组织与清理修复Sol/high，整片审核Astra/high、定点复核Sol/high，执行Sol/medium，验收Sol/high。仅交接冻结契约和版本产物。

- [布局局部审核](layout-review/review.md)、[整片审核](whole-review/review.md)及[清理修复定点审核](cleanup-review/review.md)：spec与quality通过。
- [独立执行报告](execution/report.md)、[结构化结果](execution/results.json)及[复制清单](execution/evidence-files.json)：原完整冷入口退出0；最终版本补跑受影响会话、六个新增生命周期PTY、原11个PTY与non-TTY、真实layout示例均通过。未变Unicode/Frame/布局/装饰结果按源码哈希复用，不把原全量结果冒充在新版本重新执行。
- 真实layout PTY验证d清除/恢复，48×14→23×9→8×4→48×14，整屏重现、无残留、空闲静默及精确termios恢复。[最终画面](execution/final-40aa4db/layout-pty/01-initial-48x14.txt)与原始字节均归档。
- 正常无skip的cjpm bundle退出0，实际源码包包含新子包；干净解包构建/检查与普通外部消费者构建/直接binary均退出0，无私有FFI或链接参数。[消费者纯文本](execution/final-40aa4db/consumer/plain.txt)及[ANSI快照](execution/final-40aa4db/consumer/ansi.txt)可查。
- [独立验收](verification/verification.md)按合同、原始结果、源码字节和包边界判定，不以测试数量替代验收。最终集成核对另外登记。

原始失败均保留：测试捕获语法由原测试作者修正，正常bundle的G.ERR.04由独立行为回归驱动产品修复，执行审计对合法exclude字符串的假阳性按实际依赖/内容修正，npm缓存权限仅改工作区缓存。没有弱化冻结断言、跳过SDK mandatory lint或改第三方许可原文。

## 运行与边界

加载仓颉SDK1.2.0及[原生构建依赖](../../product/native-build.md)，在真实Linux ANSI TTY执行：

```sh
cd examples/layout
cjpm run
```

本轮证据覆盖Linux x86_64、SDK1.2.0和真实PTY，属于完整框架的一次增量。完整发行checker实际仍退出1，缺composition示例及rendering基准，未标通过。滚动、完整控件、主题配置、响应式/通知、覆盖层、M2与Windows/macOS/HarmonyOS等仍按原任务继续；不以本轮替代完整Linux或跨平台验收。
