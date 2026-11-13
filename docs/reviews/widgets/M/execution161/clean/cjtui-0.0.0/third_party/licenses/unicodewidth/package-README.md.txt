# unicodewidth4cj

仓颉编程语言实现的 Unicode 字符宽度计算库。

基于 [unicode-width](https://github.com/unicode-rs/unicode-width)（Rust）移植，依据 [Unicode Standard Annex #11](http://www.unicode.org/reports/tr11/)（East Asian Width）标准计算字符和字符串的显示宽度。

## 功能特性

- 计算单个字符（`Rune`）的显示宽度
- 计算字符串（`String`）的显示宽度
- 支持 CJK 上下文（Ambiguous 字符按 2 列宽计算）
- 支持 Emoji 序列（ZWJ 序列、修饰符序列、展示序列）
- 支持控制字符、CRLF、零宽字符处理
- 支持各类文字合字/连字（阿拉伯语、希伯来语、布吉语、提非纳文、古突厥文、基拉特莱文、傈僳文、高棉文等）
- 支持组合用符（COMBINING LONG SOLIDUS OVERLAY）宽度处理

## 快速开始

### 添加依赖

在 `cjpm.toml` 中添加：

```toml
[dependencies]
  unicodewidth = { git = "https://gitcode.com/cj-awesome/unicodewidth4cj.git" }
```

### 使用示例

```cangjie
import unicodewidth.*
import unicodewidth.gen.WidthInfo

main() {
    // 计算字符宽度
    let cw = r'测'.width()          // Some(2)
    let cw_cjk = r'测'.width_cjk()  // Some(2)

    // 计算字符串宽度
    let sw = "Hello, 世界!".width()       // 13
    let sw_cjk = "Hello, 世界!".width_cjk()  // 15

    // Option<UInt8> 处理
    let w = r'\n'.width()   // None（控制字符）
    let w = r'a'.width()    // Some(1)
    let w = r'ｈ'.width()   // Some(2)
}
```

## API 文档

### Rune 扩展方法

| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `width()` | `?UInt8` | 返回字符宽度（Ambiguous 按 1 列） |
| `width_cjk()` | `?UInt8` | 返回字符宽度（Ambiguous 按 2 列） |

### String 扩展方法

| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `width()` | `UInt64` | 返回字符串宽度（Ambiguous 按 1 列） |
| `width_cjk()` | `UInt64` | 返回字符串宽度（Ambiguous 按 2 列） |

### 独立函数

| 函数 | 返回类型 | 说明 |
|------|---------|------|
| `char_iter_width(s: Array<Rune>)` | `UInt64` | 计算字符迭代器宽度（非 CJK） |
| `char_iter_width_cjk(s: Array<Rune>)` | `UInt64` | 计算字符迭代器宽度（CJK） |

## 宽度计算规则

宽度计算优先级如下：

1. **序列宽度**：`\r\n` 宽度为 1；Emoji ZWJ 序列、修饰符序列、展示序列宽度为 2；各类文字合字/连字序列有特定宽度
2. **字符宽度**：
   - 全角/宽字符（East_Asian_Width=Fullwidth/Wide）：宽度 2
   - 零宽字符（Default_Ignorable、Grapheme_Extend、部分组合用符等）：宽度 0
   - 歧义字符（Ambiguous）：CJK 上下文宽度 2，非 CJK 上下文宽度 1
   - 其他字符：宽度 1

详细规则见 `doc/design.md`。

## 构建与测试

```bash
cjpm build
cjpm test
```

## 适配版本

- LTS：Cangjie 1.0.5 Release
- STS：Cangjie 1.1.3

## 开源协议

本项目基于 Apache 2.0 / MIT 双协议开源，详见 [MIT-LICENSE](./LICENSE-MIT)和 [APACHE-LICENSE](./LICENSE-APACHE)。

## 上游项目

本库是从 [unicode-width](https://github.com/unicode-rs/unicode-width)（Rust）移植而来，原项目版权所有归 Rust 项目开发者所有。
