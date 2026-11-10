# TASK083 真实终端宽度根因独立调查

根因已确认，未实施产品修复。XTerm398 与 XFCE4 Terminal 1.1.4 / VTE0.80.1 均把 `👩‍💻` 实际推进 **4格**；受检产品的 unicodewidth / displayWidth / Frame 将同一完整字符簇计为 **2格**。第3行增量把实际13格前缀与89空格连续输出，合计102格，因此自动换行后覆盖第4行第1、2格的 `AN`，留下光标在第4行第3格 `S` 上。两宿主完整 DSR 响应都是 `ESC[4;3R`。此因果链不依赖 pyte、wcwidth 或虚拟终端模型。

## 范围与独立性

- 固定受检 SHA：`91c22f82adcd2412d9509b9872ff63450ba81af9`。源码均通过 `git show` 外部冻结；未读取产品作者的报告或自评。
- 主仓当前 HEAD 只读观察为 `4e3da933142519ac5af63c58106025edbd3f01b5`，没有把该工作区当受检源。未修改主仓、产品、正式 tests，未提交；所有调查代码仅在本目录。
- 技能：实际读取并采用 systematic-debugging、cloud-environment-runtime、verification-before-completion。依序冻结证据、定位跨层边界、单变量重放、核验原始字节及恢复；没有先提出修复。
- 旧证据仅复用指定 TASK083 原始 raw/metadata、真实宿主配置、已构建的固定制品及 SDK。新的真实 host DSR 与 PNG 均重新采集。
- 所有 GUI 原PNG直接由 X11 `import -window` 捕获，无重绘、剪贴板读取或外部消息；驱动不用键盘输入，按文件 stage/ack 协调截图。

## 可复现入口与证据

外部入口：`python3 commands/run.py`；它以 `cc -O2 -Wall -Wextra -Werror` 编译 `source/width_probe.c`，在实际 XTerm/VTE 下直接运行，保留 `raw/<profile>/metadata.json` 内完整 host / Xorg argv。`bash commands/product-width.sh` 编译独立仓颉消费者，链接 TASK083 clean-product 既有静态制品；完整 CJC argv 在 `commands/product-width-command.txt`。

`python3 commands/finalize.py` 是证据完整性检查，未加入产品或正式测试：核验116条完整 `CSI row;col R`、每条输入输出字节偏移、两宿主各58个query、两轮原始green/red重放、所有因果对照、34张主PNG、native/host退出0及完整 termios 恢复。实际命令退出0，结果在 `commands/finalize.stdout`、`raw/integrity-verification.json`。`raw/run1` 留存首次调查；主结论引用 `raw/<profile>` 的第二轮增强日志，其宽度及重放结果与首次一致。

主要路径：

- `raw/{xterm-default,xfce-vte}/dsr.jsonl`：UTC、完整原响应hex、实际row/col、输入/输出偏移；`input.bin` 与 `output.bin` 分开保存。
- `raw/<profile>/events.txt`：实际TTY、TERM、COLORTERM、locale、100×28尺寸、原/raw/恢复 termios含控制字符与速率；没有混用DSR回复与普通keys。
- `raw/<profile>/host-version.txt`、`package-versions.txt`、`window.txt`、`xorg-dummy.conf`、`metadata.json`、host/Xorg日志和退出时间。
- `raw/<profile>/original-{0,1}-{initial,green,red}.png`：两轮原始重放；`padding_minus2-0-green.png`、`replace_zwj_cjk-0-green.png`、`remove_zwj_only-0-green.png`：单变量对照。
- `raw/product-width.tsv`：真实产品 API 的宽度、字符簇数与 Frame 单元；`source/` 固定源码；`fixtures/` 原raw及派生重放输入；`source-hashes.sha256`、`manifest.sha256`：来源及完整制品校验。

宿主参数与原 TASK083 相同：XTerm `-geometry 100x28+20+20 -fa Monospace -fs 12`；XFCE `--disable-server --geometry=100x28+20+20`，独立空 XDG_CONFIG_HOME/XDG_CACHE_HOME，沿用 dummy Xorg 配置；无终端模式改写。两者 LANG/LC_ALL=C.UTF-8；实际TERM分别xterm / xterm-256color。XFCE自主设置COLORTERM=truecolor的实际值记录在native日志。仅native自己临时设置TTY raw以接收响应，结束完整恢复。

## 从 Unicode 到 host 的失配位置

1. `source/src/text/unicode.cj:7` 用依赖 `unicode.GraphemeIterator` 分段；`displayWidth` 在22行薄封装 `unicodewidth.StringWidth`。`raw/product-width.tsv` 真实执行确认：`👩‍💻` 是一个字符簇，宽度2，不是推测或仅读代码所得。
2. `source/dependency/unicodewidth/src/lib.cj` 的 String.width 调用 `str_width`。`lookup.cj:296` 从后向前运行依赖自己的状态机；其 ZWJ/emoji presentation 规则把该序列折合2。该库提供的是其 Unicode 宽度政策，未获取当前终端的物理光标推进。
3. `source/src/rich_text_clusters.cj:7` 跨span先按完整Unicode文本分段，选首scalar样式。`frame.cj:64` 获取displayWidth；72行保存 `Cell(cluster,w,false)`，73行起保存延续单元。真实Frame探针显示零基x9为完整 `👩‍💻`,width2；x10 continuation；x11开始空格。因此原第3行逻辑前缀11格、89个填充空格。
4. `frame.cj:305` 差分仅标记第3行。`encodedRowForTerminal` 在351行起遍历整行，跳过continuation，其余grapheme原样输出，含89个空格；没有物理宽度转换或边界保护。`fixtures/original-green.bin` 只有 `CUP 3;1`、样式、完整Unicode及填充；无第4行CUP或擦除命令。
5. 实际终端 `CUP3;1 → é → col2 → ' and ' → col7 → '界 ' → col10 → '👩‍💻' → col14 → 89 spaces → row4,col3`。逻辑预测在ZWJ后应col12，但实际是col14。**失效假设是把该Unicode字符串宽度政策直接等同于所连接host的物理推进，并依此输出整行填充；不是字符簇被切断，也不是色彩投影导致第4行变化。**

`raw/frozen-vs-reused-product.json` 确认所链接clean-product的6个相关产品源码与 git冻结版本逐字节一致；该制品及其依赖库的hash保留在source-hashes。消费者首次直接CJC链接因没有自动加入包静态归档而失败；失败日志保留 `commands/product-width-attempt1.stderr`。显式链接已有归档组后编译运行退出0；VS16源码literal产生的编译警告原样保留，未将warning作为失败或删去字形。

## 实际宽度与suffix

完整数据见 `width-table.md`。两宿主对此次矩阵彼此一致：

| 输入 | 产品宽度 | XTerm398 | VTE0.80.1 |
|---|---:|---:|---:|
| A / e+0301 | 1 | 1 | 1 |
| 界 / 单独👩 / 单独💻 | 2 | 2 | 2 |
| 👩‍💻 | 2 | 4 | 4 |
| 🇨🇳 | 2 | 2 | 2 |
| ❤ / ☀ | 1 | 1 | 1 |
| ❤️ / ☀️ / 1️⃣ | 2 | 1 | 1 |
| 👩‍💻Z | 3 | 5 | 5 |
| 🇨🇳Z | 3 | 3 | 3 |
| ❤️Z | 3 | 2 | 2 |
| é and 界 👩‍💻Z | 12 | 14 | 14 |

额外从第18行第96/97/98/99/100列输出 `👩‍💻Z`，DSR分别为18;100、19;2、19;4、19;4、19;6。宽字符无法放入剩余单格时还有提前换行行为，因此不能仅把字符串总宽做线性mod而忽略字形边界。DSR在最后一列可能表示pending wrap，不能从col100独自推断“已推进还是待换行”；原始delta得到4;3及PNG覆盖提供了无歧义越界证据。

## 单变量因果对照

`fixtures/initial.bin` 仅剥去util-linux script头部一行；其后初始输出全部原样。各变体均先重放同一初始流，再发送指定delta，截图前query；query无普通键输入。具体字节转换记录在 `fixtures/transformations.json`。

| 变体 | 唯一改变 | 两宿主最终DSR | 原PNG第4行 |
|---|---|---|---|
| original，两轮green/red | 无 | 4;3 | AN被两空格覆盖，光标位于S |
| remove_zwj_only | 仅删除U+200D，保留👩和💻 | 4;3 | 同样损坏 |
| replace_zwj_cjk | 仅把整个簇换成界，89空格不变 | 3;100 | 完整ANSI styles |
| padding_minus2 | 完整原Unicode不变，仅89→87空格 | 3;100 | 完整ANSI styles |

原始初始/full resize正常的解释已由输出顺序定位：完整帧在第3行溢出后继续显式 `CUP4;1` 重画第4行，掩盖先前越界；仅第3行变化时没有后续第4行重画，损坏持续。旧原始resize字节和PNG可复用此证据；本轮未把120列resize场景冒充重新实测。padding变体只证明越界的直接原因，不是产品修复；它没有解决含suffix、其他序列、裁剪或宿主差异的统一宽度契约。

## 有限后续选择及契约影响（均未实施）

1. **会话采用有证据的物理占位策略，并贯穿现有Unicode适配、布局、Frame与renderer。** 对本host此簇需要4个物理格；完整原字符串可见，后续suffix按4推进、裁剪按实际边界。应保留Unicode字素作为编辑/逻辑单位、canonical离线文件及显示宽度政策；不能创建另一套Unicode分段/布局/ANSI解析内核。此选项需要决定“会话Frame的宽度可不同于公开canonical displayWidth与离线Frame”契约，以及相同策略如何进入布局、复制、覆盖和差分。当前架构将unicodewidth写为唯一显示宽度来源，需要有意识修订该假设，不能盲改全局width为4。
2. **保留canonical网格，自动将实际不相容的序列投影为已证实有界的终端替代呈现。** 保留完整逻辑Unicode、原样离线输出及同一编辑字符簇；只有会话的可见字形可能降级。必须明确替代语义、宽度、来源与诊断，并对正支持的emoji保持原呈现；不能禁用所有emoji、删掉示例内容或要求应用按终端写分支。此选项需用户接受可见呈现与逻辑原文可能不同的公共契约。

两者共同约束：框架默认自动处理，不要求程序员判断；未知能力不能假称支持。仅减少padding、永久全帧刷新、禁止自动换行、全局emoji宽度4都不是本调查支持的完整方案：它们分别未解决suffix/裁剪、掩盖损坏、改变宿主模式但不解决位置、或被单emoji/flag/VS16实测反例否定。本宿主同时满足“原字形完整显示”“固定2格”“后续字符位置与网格严格吻合”不可由当前原样文本流同时保证。

## 尚无证据的能力边界

本轮没有建立或实现产品能力探测协议。DSR只测实际被输出的特定序列、该host版本/配置/字体与上下文；一个ZWJ探针不能推出所有ZWJ、VS16、旗帜、modifier、Unicode版本或字体行为。上述矩阵本身已经展示不同类别相反的误差，不能把某一个宽度flag当全Unicode保证。

若后续引入测量，需要独立证明：启动/重绘时的可逆测量区域与光标恢复、DSR超时/拒答、普通键与响应路由、复用/缓存的身份和失效条件、复用器与远程会话、未知序列的有界降级。不应为此生成新终端模拟器或第二parser。上述项目是具体未决证据边界，不是本轮已验证能力，也不阻止本次根因确认。

调查结论仅覆盖固定制品、上述两个真实宿主及所列输入/对照；TASK083产品验收仍为FAIL，等待有契约依据的修复及独立复验。
