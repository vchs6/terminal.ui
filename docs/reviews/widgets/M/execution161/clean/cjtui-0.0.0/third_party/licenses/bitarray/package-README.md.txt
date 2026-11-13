# BitArray — 二进制位数组库

一个用仓颉语言实现的通用二进制位数组库，支持 0~64 位宽的位操作、视图模型（可重叠段访问）和分区模型（互斥字段访问）。

## 功能特性

- **纯位存储**：`BitArray` 以 `UInt8` 数组存储，空间紧凑，端序无关
- **多种构造**：从无符号整数、Bool 数组、01 字符串、Rune 字符数组、UInt8 字节数组等多种方式初始化
- **完整位运算**：`&` `|` `^` `!` `<<` `>>` `==` `!=`
- **视图模型**（`SegmentedBitArray`）：命名段可重叠，适合多粒度协议解析
- **分区模型**（`PartitionedBitArray`）：互斥字段，自动重叠检测，适合硬件寄存器位域
- **两模型共存**：同一底层 `BitArray` 同时挂载视图和分区，修改互见

## 快速入门

### 编译与测试

```bash
# 运行全部测试
cjpm test

# 单文件编译（在 src/ 目录下）
cjc src/test/bitarray_test.cj src/bitarray.cj src/bitsegment.cj \
    src/bitarray_view.cj src/bitpartition.cj src/partitioned_bitarray.cj \
    --test -o bitarray_test
./bitarray_test
```

### 构造 BitArray

```cangjie
import bitarray.*

// 从无符号整数
let ba8  = BitArray(0b1010_1101u8)     // 8 位
let ba16 = BitArray(0xA5C3u16)         // 16 位
let ba32 = BitArray(0xDEAD_BEEFu32)    // 32 位
let ba64 = BitArray(0x0123_4567_89AB_CDEFu64)  // 64 位

// 从 Bool 数组（index 0 = LSB）
let ba = BitArray([true, false, true, false])

// 从 "01" 字符串（左 = MSB，支持 _ 分隔符）
let ba = BitArray("1010_1101")

// 从 Rune 字符数组
let ba = BitArray([r'1', r'1', r'0', r'0'])

// 从字节数组（低位在前）
let ba = BitArray([0xABu8, 0xCDu8])

// 空 BitArray
let ba = BitArray()
let ba = BitArray(16)    // 16 位全 0
```

### 位访问与运算

```cangjie
let ba = BitArray(0b1001_0110u8)

// 读取位
let b0: Bool = ba[0]    // LSB → false
let b7: Bool = ba[7]    // MSB → true

// 设置位
ba[3] = true

// 位运算
let a = BitArray("1100")
let b = BitArray("1010")
let r = a & b    // → "1000"
r = a | b        // → "1110"
r = a ^ b        // → "0110"
r = !a           // → "0011"

// 移位
let sh = BitArray("00001111")
sh << 2   // → "00111100"
sh >> 2   // → "00000011"
```

### 视图模型（段可重叠）

```cangjie
let reg = BitArray(0x1A_00_AB_CDu32)
let view = SegmentedBitArray(reg)

view.addSegment(BitSegment("flags",   0,  8))
view.addSegment(BitSegment("length",  8,  16))
view.addSegment(BitSegment("type",    24, 4))
view.addSegment(BitSegment("version", 28, 4))

let flags = view.getSegment("flags")      // → 0xCD
view.setSegment("flags", 0x42u64)

// 段可重叠
view.addSegment(BitSegment("whole", 0, 32))
view.addSegment(BitSegment("high16", 16, 16))
```

### 分区模型（互斥字段）

```cangjie
let pba = PartitionedBitArray(BitArray(0x1A_00_AB_CDu32))
pba.addField(BitSegment("flags",   0,  8))
pba.addField(BitSegment("length",  8,  16))
pba.addField(BitSegment("type",    24, 4))
pba.addField(BitSegment("version", 28, 4))

// 添加重叠字段会抛异常
// pba.addField(BitSegment("overlap", 4, 8))  // → IllegalArgumentException

let v = pba.getField("version")  // → 1
```

### 两模型共存

```cangjie
let ba = BitArray(0x1A_00_AB_CDu32)
let view = SegmentedBitArray(ba)
let pba = PartitionedBitArray(ba)

// 通过分区写入，通过视图读取
pba.setField("flags", 0x42u64)
view.getSegment("whole")  // → 0x1A00AB42（低 8 位已变）
```

### 工具方法

```cangjie
let ba = BitArray("11001010")

ba.slice(2, 6)         // → "0010"
ba.concat(BitArray("0011"))  // → "110010100011"
ba.toUInt64()          // → UInt64
ba.toBoolArray()       // → Array<Bool>
ba.toString()          // → "11001010"
```

## 文档

- [设计文档](doc/DESIGN.md) — 架构、位序约定、存储、两模型设计原理
- [API 参考](doc/API.md) — 所有 public 类型和方法的完整说明

## 测试

67 个单元测试用例，覆盖所有构造方式、位运算、视图/分区模型、边缘情况。

```bash
cjpm test
```

## 许可证

无。
