# TASK148 headless key 测试设施独立审核

规格符合性 **PASS**；代码质量 **PASS**。Critical 0 / Important 0 / Minor 0。结论仅适用于测试设施修正，不是149产品审或运行成功声明。

固定完整范围：`e9121c9768291b65fae56ca9b0f38b9bb6c3ee1f` → `47d267fe802dcb817b4f95247eac18a4a30c2fab`，六文件282+/3-，全在tests/session_extensions。完整审核包与独立`git diff -U10`字节一致，见`fixed.diff`。按S002/S003/S006核源与原始TSV/命令记录；未读149产品源码/report/progress、未读测试作者推理/自评report。未改任何测试/产品/main/状态，未派代理。

## 缺陷与合同

S002区分五字段SessionCapability（support/basis/reason/route/candidate）和SessionResult；未变的`tests/session_extensions/src/record.cj:75`及`:79`分别把capability写成五字段值，把operation主要结果写成六字段值，session/cap/steps另记附属行。`capabilities:97`在给定prefix后生成id/clipboard/title/titleStack/imageIcon。

旧headless调用`capabilities("headless", app)`后又`result("headless.title", app.setHostTitle(...))`，使两个不同形状共享key。实际原件明确包含：

```text
headless.title    Unsupported|KnownUnavailable|NoDevice|Direct|osc2
headless.title    SetHostTitle|Unsupported|0|NoDevice|-1|NotNeeded
```

旧parseResults的Map.set保留后一行。旧verifyHeadless既需要六字段SetHostTitle结果，又要求同一key以Unsupported|KnownUnavailable|NoDevice开头；无论换成哪个值，都不能同时满足。此为测试记录接口冲突，不是应改变产品S003 headless NoDevice结果的证据。原公共字段/返回形状符合该区分，不能通过改变产品结果来迎合旧冲突。

原fixture223行SHA256 `cc778a8f355f0a702c4112c57e224f1b9dcdf44064d23c4fce32386e380ab1fd`，与raw/original-results.tsv、origin.json指定的原实际TSV及committed fixture完全相同。独立字节归组只发现这一处跨shape重复，另有60个同shape重复key。

## 修正检查

- `src/headless.cj:21`唯一行为变动是capability记录prefix变为`headless.capabilities`。操作仍为headless.copy/title/restore/icon；被调用公共API、调用顺序、参数、sessionId读取、跨线程getter、InvalidContext/SessionInactive、batch/post/FIFO、队列上限和cleanup检查均不变。
- `oracle.mjs:58`只对应更新capability lookup prefix。verifyHeadless既有operation/status/bytes/issue要求、NoDevice/NoImageAdapter、空wire、common诊断/step数量与byte sum、cleanup.count仍保持。record.cj本身无diff，未更改任何公共字段序列。
- `oracle.mjs:15`在覆盖旧Map值前比较pipe字段数，5→6或6→5都会抛错；不会靠记录顺序隐藏本碰撞。它是有限shape guard，并非全schema/逐次语义验证。previous未定义表示首条，既有同shape覆盖行为原样保留。
- `key_selftest.mjs:6-10`覆盖原实际碰撞及两种字段顺序；`:11-20`仅重命名原capability keys，尤其title按五字段选择，六字段operation原样保留，再运行相同verifyHeadless。`:30-34`从真实fixture挑出60个重复key，确认每key形状一致且解析值等于最后一次记录。
- 原headless启动、重新启动会再次触发getter/mount/cleanup，原TSV有session4及session9同shape记录，因此一律禁止重复会误拒合法fixture。README明确“同shape last-value，不逐invocation验证”，没有把这一限制作成全部S006语义已证。允许同shape并不表示允许任意坏操作值；保留的最终值仍由原oracle检查。但若早次同shape坏值后被好值覆盖，仍是原解析行为/既有覆盖边界，本修正没有声称解决或扩大它。
- `selftest.mjs`只追加await import新控制，既有assertions未删减。无dependency、product/native或公共API修改；所有记录都是测试内固定key，未改实际capability对象字段。

## 证据与验证边界

使用已读取的独立review/verification流程，按AGENTS11.1复用有效记录，未重跑旧277或冷编译。原`raw/headless-key/old-selftest-red`为`node tests/session_extensions/key_selftest.mjs` exit1，报Missing expected exception：旧parser静默覆盖；`fixed-selftest`同命令exit0，stdout明确cross-shape negatives=3、same-shape last-wins keys=60、no product run。这些只证明记录/解析设施，不证明实际新产品headless或host运行。

本角色实际执行`node audit.mjs` exit0：核固定父提交/六文件边界、完整diff、源hash、原TSV三份字节一致、唯一5/6碰撞与60同shape重复，以及原记录exit1/0。执行`git diff --check BASE FIXED`无问题。`reviewed-hashes.json`含六变更文件、相关未变record/wire/contract及raw证据hash，`artifacts.sha256`封存本审核产物。

没有发现需要新增产品探针的具体疑点。S007后续补充不在47固定提交的本次审核范围；不据本次PASS关闭149/真实执行/验收任务或改状态权威文件。
