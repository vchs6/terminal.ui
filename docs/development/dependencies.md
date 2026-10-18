# 外部依赖与适配边界

2026-10-18 读取中心仓包页面及其公开元数据接口。可复核字段快照见 [central-packages.json](central-packages.json)，只证明版本、摘要、许可证及声明的最低编译器，不证明集成运行通过。

| 依赖 | 固定版本 | 声明 cjc | 内容摘要 SHA256 | 职责 |
|---|---|---|---|---|
| [ansies](https://pkg.cangjie-lang.cn/package/ansies) | 1.3.113 | 1.0.0 | 396ead6ab841eddd12b196fb657848587c4514a435c536146810ee5675344940 | ANSI 序列生成及实际支持的终端回复解析 |
| [unicode](https://pkg.cangjie-lang.cn/package/unicode) | 0.1.0 | 1.1.0 | d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c | 字符簇、显示宽度、码点属性及规范化 |

ansies 的中心仓元数据还声明 bitarray 0.1.0。上述两项许可证均为 MulanPSL-2.0；传递许可证需在 TASK-003 核对。不得手写伪 cjpm.lock；实施阶段用 cjpm update/check 生成解析证据并核对实际内容摘要。

框架负责：能力降级、安全边界、显示宽度策略配置、结构化样式映射及渲染不变量。依赖负责其已有字符和序列算法。终端回复解析不自动等同于任意富文本 ANSI 增量解析；TASK-003 逐项建立适用/缺口矩阵，再形成必要的受限输入适配设计。禁止假设依赖已经提供全部解析能力。

选择 SDK 1.2.0 作为重建与 CJPM bundle 验证基线，未承诺旧 1.0.0 兼容。当前仅清单已配置；依赖下载、编译和运行验收仍为 pending。

CJPM 规则依据：[官方 1.2.0 手册](https://cj-docs.gitcode.com/zh/1.2.0/tools/source_zh_cn/cmd-tools/cjpm_manual.html)。include/exclude 位于 package 表，非 workspace 表；版本固定字符串代表指定版本。bundle 是源码制品包，不是预编译静态库分发。
