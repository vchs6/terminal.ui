# G011 限定 preflight 补充

结论：**not_ready**。固定 `fad6301e8c284e6db0c6689186da756959b59c1f` 的 G011 有一处 Important / Battle major 合同冲突，须修订成功 map 的 reason 条件后才可作为独立测试的精确预期。其余新增诊断分支可接受。

范围仅为新增 G011。与上一固定 `6d30da46b36e687d4fe8ca95cfa553f00997c7cf` 机械比较确认 G001–G010 内容不变；旧 preflight 与 G010 产物保持原貌。未跑套件或编译、未读产品作者报告、未改主仓/产品/正式测试、未派代理。

## GLYPH-G011-001：成功空 map 的 reason 存在两种互斥预期

- 严重性：Important（Battle major）；状态：confirmed。
- 责任段：新增 G011 表“完整有界map成功（可0条）”行；既有规范依据 G003 的 ascii-fallback-unavailable。
- 最小反例：实际 stdout 已确证文本 VT；GIO_UNIMAP 成功且 entryCount=0。此时 mapKnown=true，但 bitmap 中没有 `?`。
- G003 要求：source=linux-vt-unimap、reason=ascii-fallback-unavailable、nativeError=0；成功 map 不等于备用字符可见。
- G011 新表要求：source=linux-vt-unimap、reason 为空、nativeVt=true、mapKnown=true、nativeError=0。
- 影响：两个正式合同对同一已要求覆盖的空map场景给出互斥诊断，093无法冻结唯一预期；成功读取但备用字符缺失的公开诊断会被无条件空reason掩盖。
- 最小修订：将成功行 reason 写为“`?` 可映射时为空，否则 ascii-fallback-unavailable（沿 G003）”；或表后明确该成功分支例外优先于空reason。无需改变公共API、读取行为或用户目标。
- 修复验证边界：只复核新增行/例外与 G003 一致；无需重跑旧 preflight 或产品套件。

## 其余限定核验

| 项 | 结论 |
|---|---|
| isatty==0 | 可接受。明确按正常非TTY识别归 not-tty/nativeError0，避免把 isatty 内部 errno 当成承诺的查询异常。 |
| fstat、VT_GETMODE、KDGETMODE失败 | 可接受。确认文本VT前的失败保持 unknown、nativeVt=false、mapKnown=false，记录失败调用原errno；无权限升级或其它VT读取。 |
| 不具体VT及非KD_TEXT | 可接受。正常识别结果与异常调用分开，error0；不得在此前设置nativeVt=true。 |
| map allocation/read/validation失败 | 可接受。仅确证文本VT后进入，nativeVt=true/mapKnown=false；allocation/内部校验error0，GIO_UNIMAP -1记录原errno，所有失败entryCount0。实现须在后续调用或清理前保存异常errno，这是“原errno”的直接实现义务。 |
| pair计数 | 可接受。成功entryCount为实际pairs而非bitmap置位数，重复unicode不影响成功读取事实；空map合法但reason例外须按上项修订。 |
| 不支持目标 | 可接受。unknown/unsupported-platform，两个Bool为false、error0，不声称探测成功。 |
| 接口与证据范围 | 没有新增公共接口或测试专属hook；纯诊断精确化不替代真实宿主证据。 |

固定输入及差异位于 `g011-input/`；独立发现见 `g011-findings.json`；精确摘要见 `g011-reviewed-hashes.json`。
