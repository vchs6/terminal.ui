# Cangjie Unicode Library

<p align="center">
<img alt="" src="https://img.shields.io/badge/version-v0.1.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/state-release-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/category-unicode-red" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-brightgreen" style="display: inline-block;" />
</p>

本项目以易于理解和使用的 API，为仓颉编程语言(Cangjie) 提供 unicode字符宽度计算、字符簇分割、规范化分解和组合等功能。

## 📋 项目信息

### 功能特性
- [x] UCD码点属性快速访问
- [x] Unicode字符文本显示宽度计算
- [x] Unicode字符簇和字符串的文本显示宽度计算
- [x] UTF8 编码 UTF16 编码的相互转换
- [x] 码点及字符串的规范化（支持NFD、NFC、NFKD、NFKC）
- [x] 字符的大小写、标题的相互转换
- [x] Case Floding
- [x] 表情符号
- [x] 字符簇分割
- [ ] script
- [ ] word boundary
- [ ] line breaking

### Unicode技术规范
- [UTS 11](https://unicode.org/reports/tr11/) - character width
- [UTS 24](https://unicode.org/reports/tr24/) - script property
- [UTS 29](https://unicode.org/reports/tr29/) - text segmentation (grapheme cluster)
- [UTS 51](https://unicode.org/reports/tr51/) - Emoji

## 🚀 快速开始
### 编译生成静态库
```shell
cmake --build build --target all
```
### 基本使用
```cangjie
import unicode.UnicodeWidth

main: Int64 {
    var str = "hello world."
    println("${str.width()} columns")
    str = "Ｈｅｌｌｏ, ｗｏｒｌｄ!"
    println("${str.width()} columns")
    let ch: Rune = r'我'
    println("${ch.width()} columns")
    return 0
}
```
### 完整示例
查看 [完整示例代码](test/) 了解详细用法。

## 🔧 环境要求

### 支持的版本

**已验证的开发环境：**

| 组件          | 版本信息 | 状态    |
| ------------- | -------- | ------- |
| 仓颉语言      | v1.0+    | ✅ 支持 |
| DevEco Studio | 5.0+     | ✅ 支持 |
### 平台兼容性

| 平台                | 支持状态      | 备注           |
| ------------------- | ------------- | -------------- |
| Windows/Linux/macOS | ✅ 支持    | 继承和扩展原库功能     |

## 📚 API文档

> 💡 **使用说明**：仓颉语言版本效果对标原语言版本，简化了API的使用方法。
### 主要方法

| 方法名             | 描述         | 参数类型 | 返回类型              | 仓颉支持      |
| ------------------ | ------------ | -------- | --------------------- | ------------- |
| `width()`       | 字符/字符串的宽度     | 无 | Int64              | ✅ 完全支持   |

### 支持状态说明

- ✅ **完全支持**：功能完整，与原库行为一致
- ⚠️ **部分支持**：核心功能可用，但可能有限制
- ❌ **暂不支持**：当前版本不支持，计划后续实现
- 🚧 **开发中**：正在开发中，即将支持

## 💡 使用示例

### 基础用法

```cangjie
import unicode.UnicodeWidth

main(): Int64 {
    let teststr ="Ｈｅｌｌｏ, ｗｏｒｌｄ!"
    //打印每个字符的宽度
    for(ch in teststr.toRuneArray()) {
        println("The rune ${ch} is ${ch.width()} columns wide.")
    }

    //求字符串的文本显示宽度
    let width = teststr.width()
    println("The above string ${teststr} is ${width} columns wide.")
    return 0    
}
```

### 高级用法

```cangjie
// 高级功能使用示例
import unicode.Codepoint
import unicode.types.NormalizationForm
import unicode.GraphemeIterator

main(): Int64 {
  //获取unicode码点的属性
  let ch: Rune = r'A'  // r'我'
  //字符的规范化
  let cps = Codepoint.normalize(UInt32(ch.position()), form: NormalizationForm.NFD)

  //按序访问字符串中的字符簇
  let str = "this is a test."
  let it = GraphemeIterator(str)
  while(true) {
    match(it.next()) {
        case None => break
        case Some(g) => g.width //访问字符簇的属性和方法
    }
  }

  return 0
}
```

## ⚠️ 已知限制
### 本地开发

```bash
# 克隆仓库
git clone https://gitcode.com/vchuoshen6/libunicode.git
cd libunicode

# 运行测试
cjpm test

# 运行示例
cd test && cjpm run
```

### 贡献指南

我们欢迎所有形式的贡献！

- **🐛 报告Bug**：[提交Issue](https://gitcode.com/vchuoshen6/libunicode/issues)
- **💡 功能建议**：[功能请求](https://gitcode.com/vchuoshen6/libunicode/issues)
- **📝 完善文档**：改进README、添加示例、翻译文档
- **🔧 代码贡献**：修复Bug、实现新功能、优化性能
- **🧪 测试验证**：在不同设备上测试、提供测试用例

### 开发者

- **主要维护者**：[@贡献者用户名](https://gitcode.com/vchuoshen6)
- **贡献者列表**：感谢所有为项目做出贡献的开发者

## 📋 更新日志

### v0.1.0 (2026-07-16)

- ✅ 完成仓颉语言基础适配
- ✅ 实现核心API功能
- ✅ 添加示例应用
- 🚧 初始版本发布

## 📄 开源协议

本项目基于 [MulanPSL-2.0](LICENSE) 开源，请自由地享受和参与开源。

## 🙋‍♀️ 常见问题

### Q: 如何在现有项目中集成？

A: 按照安装步骤添加依赖后，替换原有的import语句即可，API有所简化。

### Q: 遇到编译错误怎么办？

A: 请检查仓颉语言和鸿蒙SDK版本是否符合要求，参考[环境搭建指南](../环境搭建/README.md)。

### Q: 某个功能在仓颉语言上不工作？

A: 请查看API文档中的支持状态，如果标记为"暂不支持"，可以关注项目更新或提交PR帮助实现。

---

## 📞 联系我们

- 🐛 **问题反馈**：[AtomGit Issues](https://gitcode.com/vchuoshen6/libunicode/issues)
- 💬 **讨论交流**：[加入社区群](../../README.md#联系我们)
- 📧 **邮件联系**：vchuoshen6@163.com
