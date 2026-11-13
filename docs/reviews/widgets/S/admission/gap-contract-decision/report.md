# `.gap` 错误契约冲突：独立限定建议
受检版本：3e990fd121133fb344a2ebc4abd82f678813dd51；仅静态契约/既有入口核对，无构建、探针、源码或测试修改。
**推荐：保留已接受常量快捷入口的明确旧异常契约，澄清 S 场景并补充严格分路径断言；由 root 裁决后再解除154阻塞。**
直接依据：layout-decoration/design.md:35–40 明文规定 Text 上 gap/alignItems/justifyContent、容器上 textAlign 等非法旧 setter 立即抛 IllegalArgumentException 且保留旧设置；tests/layout/src/main.cj:12–16、85–93以该具体类型断言，并非宽泛“任意异常”。
Runtime R007（design.md:234）列出新 UIException 错误码且保留旧参数错误，R009:238保留旧常量签名；它们没有明确废除上述旧目标种类错误契约，不能仅凭 InvalidProperty 出现在目录中推定全入口已归一。
Theme design.md:74、270、T013:420将样式应用的不适用目标规定为 UIException("InvalidProperty")；角色不改变 primitive（:76）。Interaction A.1:89明确 Canvas 不适用属性为 InvalidProperty，其共享错误表:377较宽泛，需补明旧快捷入口例外而不能抹去已明确接受的旧合同。
实际入口相符：Component.gap(Int64):151–154 对 Text 抛 IllegalArgumentException；getter gap:396 与 typed setStyle:94–108走 checkStyleTarget:80–85，抛 UIException("InvalidProperty")；Progress 的 Canvas wrap 仍走该新能力路径。
冲突点是 standard-widgets/spec.md:13–15 未区分入口，construction_cases.cj:19–20遂要求 Label/Button 常量gap抛UIException；Label/Button必须普通Text Component，无合法widget专用kind/override可同时满足这两条相反预期。
建议场景明确为：typed setStyle、getter属性及已解析命名/Inline样式应用到不支持primitive时为UIException("InvalidProperty")；继承既有常量快捷setter的Text根控件保留其IllegalArgumentException，不获得容器能力，也不改变旧设置。
测试应分别严格断言 Label/Button.gap(1) 的 IllegalArgumentException、gap({=>1})/setStyle(gap,Value(1))/不兼容样式应用的UIException及code，以及Progress.wrap的InvalidProperty；保持旧Text.gap、负Row.gap和非法Stretch回归，不把helper放宽成接受两种异常或catch Exception。
主题配置解析须单独保留其边界：不支持的已知role属性是UnsupportedProperty诊断（Theme:270），程序化非法数值仍IllegalArgumentException（T013）；不得用“主题路径均InvalidProperty”覆盖这些既有错误类别。
备选全量上游归一可减少入口间不一致，但须明确撤销layout旧错误合同、修改公共Component及原回归并独立审查/执行；会改变现有catch IllegalArgumentException消费者，超出本次公共薄控件组合的最小修复，无当前强制归一裁决证据。
代价：调用者仍需知道旧快捷入口与typed/getter入口的错误类型区别；这是有明确旧合同和回归支撑的有限兼容例外，须在S/交互错误说明中列明，不能成为未来新API的任意例外。
本建议不是154通过或测试已纠正；root应先记录规则与有限例外，再由独立测试角色按新冻结合同调整精确预期，后续仅验证受影响路径，保留原失败证据。
