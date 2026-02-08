//! \file caculator.cj
package acnl.unicode

import std.collection.ArrayList
import std.convert.Parsable

import acnl.unicode.unicodedata.{EAW, ZEROWIDTH, NARROWTOWIDE, VERSIONS, MCCATEGORY, MECATEGORY, MNCATEGORY}
import acnl.unicode.unicodedata.{NFDCODES, CCC, COMPOSITION}

public func indexOfTable<T>(value: T, table: Array<T>): Int64 where T <: Comparable<T> {
    var idx: Int64 = -1
    var left = 0
    var right = table.size - 1
    while (right >= left) {
        let center: Int64 = (left + right) / 2
        if (value < table[center]) {
            right = center - 1
        } else if (value > table[center]) {
            left = center + 1
        } else {
            idx = center
            break
        }
    }
    idx
}

public func indexOfTable<T>(value: T, table: Array<Array<T>>, isRangeTable!: Bool = true): Int64 where T <: Comparable<T> {
    var idx: Int64 = -1
    var left = 0
    var right = table.size - 1
    while (right >= left) {
        let center: Int64 = (left + right) / 2
        let v1 = table[center][0]
        var v2 = v1 
        if (isRangeTable) {
            v2 = table[center][1]
        }
        if (v2 < value) {
            left = center + 1
        } else if (v1 > value) {
            right = center - 1
        } else {
            idx = center
            break
        }
    }
    idx
}

public func isExistInRanges<T>(value: T, table: Array<Array<T>>, isRangeTable!: Bool = true): Bool  where T <: Comparable<T> {
    indexOfTable<T>(value, table, isRangeTable: isRangeTable) >= 0
}

//! class Caculator
/*! \brief unicode字符属性计算器
 *
 * 多版本unicode字符/字符串的宽度计算和规格化。
 */
public class Calculator {
    private static var defaultVersion: String = VERSIONS.last ?? ""

    public init(version!: String = "") {
        if (version != "" && VERSIONS.contains(version)) {
            defaultVersion = version
        }
    }

    private static func getVersion(version: String): String {
        if (version.isEmpty()) {
            defaultVersion
        } else {
            version
        }
    }

    // in class IllegalArgumentException
    public static func setDefaultVersion(version: String): Unit {
        if (version.trimAscii() != "" && VERSIONS.contains(version)) {
            defaultVersion = version
        } else {
            throw IllegalArgumentException("the version is not exists.")
        }
    }

    public static func getWidth(char: Rune, version!: String = ""): Int {
        let pos = UInt32(char.position())

        if (pos >= 32 && pos < 0x7F) {
            return 1
        }

        if (pos < 32 || (pos >= 0x7F && pos < 0xA0)) {
            return -1
        }

        let uv = getVersion(version)

        if (isExistInRanges<UInt32>(pos, ZEROWIDTH.get(uv)?? Array<Array<UInt32>>())) {
            return 0
        }

        if (isExistInRanges<UInt32>(pos, EAW.get(uv) ?? Array<Array<UInt32>>())) {
            2
        } else {
            1
        }
    }

    public static func getWidth(text: String, version!: String = ""): Int64 {
        let uv = getVersion(version)

        var isGE: Bool = true
        let verBytes = uv.split(".").map({s => UInt8.parse(s)})
        let baseVer: Array<Byte> = [9, 0, 0]  // cjlint-ignore !G.VAR.02 description
        var i = 0
        while (isGE && i < verBytes.size) {
            if (verBytes[0] < baseVer[i]) {
                isGE = false
                break
            }
            i++
        }

        let xs = text.toRuneArray()
        var width = 0
        var index = 0
        var lastMeasureRune: Option<Rune> = None  // cjlint-ignore !G.VAR.02 description
        while (index < xs.size) {
            if (xs[index] == r'\u{200D}') {     //Zero Width Joiner, do not measure this or next character
                index += 2
                continue
            }
            if (xs[index] == r'\u{FE0F}' && (let Some(char) <- lastMeasureRune)) {
                let r = UInt32(char.position()) // cjlint-ignore !G.VAR.02 description
                if (isGE) {
                    if (isExistInRanges<UInt32>(r, NARROWTOWIDE.get("9.0.0") ?? Array<Array<UInt32>>())) {
                        width ++
                    }
                    lastMeasureRune = None
                }
                index ++
                continue
            }
            let wcw = getWidth(xs[index], version: version)
            if (wcw < 0) { return wcw }
            if (wcw > 0) { lastMeasureRune = xs[index] }
            width += wcw
            index ++
        }
        width
    }

    public static func isMcCombiningMark(char: Rune, version!: String = ""): Bool {
        let uv = getVersion(version)
        isExistInRanges(UInt32(char.position()), MCCATEGORY.get(uv) ?? Array<Array<UInt32>>())
    }

    public static func isMeCombiningMark(char: Rune, version!: String = ""): Bool {
        let uv = getVersion(version)
        isExistInRanges(UInt32(char.position()), MECATEGORY.get(uv) ?? Array<Array<UInt32>>())
    }

    public static func isMnCombiningMark(char: Rune, version!: String = ""): Bool {
        let uv = getVersion(version)
        isExistInRanges(UInt32(char.position()), MNCATEGORY.get(uv) ?? Array<Array<UInt32>>())
    }

    public static func isCombiningMark(char: Rune, version!: String = ""): Bool {
        let uv = getVersion(version)
        isExistInRanges(UInt32(char.position()), MECATEGORY.get(uv) ?? Array<Array<UInt32>>()) ||
        isExistInRanges(UInt32(char.position()), MCCATEGORY.get(uv) ?? Array<Array<UInt32>>()) ||
        isExistInRanges(UInt32(char.position()), MNCATEGORY.get(uv) ?? Array<Array<UInt32>>())
    }

    //获取组合类别
    public static func getCCC(char: Rune, version!: String = ""): ?Byte {
        let uv = getVersion(version)
        let table = CCC.get(uv) ?? Array<Array<UInt32>>()
        let idx = indexOfTable(UInt32(char.position()), table)
        if (idx >= 0) {
            UInt8(table[idx][2])
        } else {
            None
        }
    }

    public static func sortByCombiningClass(value: Array<Rune>, version!: String = ""): String {
        let table = CCC.get(getVersion(version)) ?? Array<Array<UInt32>>()

        if (table.isEmpty()) {
            return String(value)
        }

        //按规范组合类别进行逆序排列
        for (i in 0 .. value.size - 1) {
            for (j in i + 1 .. value.size) {
                let ci = indexOfTable(UInt32(value[i].position()), table)
                let cj = indexOfTable(UInt32(value[j].position()), table)
                if (ci > cj) {
                    let t = value[i]
                    value[i] = value[j]
                    value[j] = t
                }
            }
        }
        String(value)
    }

    //字符的规范分解（NFD）
    private static func nfdDecompose(char: UInt32, table: Array<Array<UInt32>>): Array<Rune> {
        let builder = ArrayList<Rune>()
        let idx = indexOfTable<UInt32>(UInt32(char.position()), table, isRangeTable: false)
        if (idx >= 0) {
            for(ch in table[idx][1 .. table[idx].size]) {
                builder.add(all: nfdDecompose(ch, table))
            }
        } else {
            builder.add(Rune(char))
        }
        builder.toArray()
    }

    //字符串的归一化（NFD，规范分解)
    public static func nfdNormalize(value: String, version!: String = ""): String {
        if (value.isEmpty()) {
            return value
        }

        let table = NFDCODES.get(getVersion(version)) ?? Array<Array<UInt32>>()
        if (table.isEmpty()) {
            value
        } else {
            let builder = StringBuilder()
            for (d in value.toRuneArray()) {
                let decomposed = nfdDecompose(UInt32(d.position()), table)
                if (decomposed.size > 1) {
                    sortByCombiningClass(decomposed)
                }
                builder.append(decomposed)
            }
            builder.toString()
        }
    }

    //组合字符
    private static func tryCompose(base: UInt32, mark: UInt32, table: Array<Array<UInt32>>): ?Rune {
        //二分检索组合表找到基础字符，并前移到首个位置
        var left = 0
        var right = table.size - 1
        while(right >= left) {
            let c = (left + right) / 2
            if (base > table[c][0]) {
                left = c + 1
            } else if(
                base < table[c][0]) { right = c - 1
            } else {
                right = c
                while (right > 0 && base == table[right - 1][0]) {
                    right --
                }
                break
            }
        }

        if (right >= table.size) { 
            return None
        }

        //顺序查找
        var result: ?Rune = None
        while(right < table.size && table[right][0] == base) {
            if (mark == table[right][1]) {
                result = Rune(table[right][2])   //返回组合字符
                break
            }
            right ++
        }

        result
    }

    //字符串的归一化（NFC，规范分解后规范组合）
    public static func nfcNormalize(value: String, version!: String = ""): String {
        if (value.isEmpty()) { return value }

        let composeTable = COMPOSITION.get(getVersion(version)) ?? Array<Array<UInt32>>()
        if (composeTable.isEmpty()) { return value }

        let str = nfdNormalize(value, version: version).toRuneArray()

        let result = ArrayList<Rune>()
        for (d in str) {
            if (isCombiningMark(d, version: version)) {
                if (let Some(char) <- tryCompose(UInt32(result[result.size - 1].position()), UInt32(d.position()), composeTable)) {
                    result.remove(at: result.size - 1)
                    result.add(char)
                } else {
                    result.add(d)
                }
            } else {           
                result.add(d)
            }
        }

        String(result.toArray())
    }
}