package acnl.unicode

//! class UnicodeData
/*! \brief 基于版本的unicode数据生成器
 *
 * 多版本unicode数据生成的快速检索支持
 */
public class UnicodeData {
    //!< 版本号，字符串
    let version: String
    //!< 键中的元素数量
    let keySize: Byte
    //!< 数据表
    let data:  Array<Array<UInt32>>

    /*! 构造器 
     * 
     * \prarm version，格式为xx.xx.xx的版本号
     * \param data，原始数据
     * \param keySize, 命名参数，键的数据个数，默认值为2
     */
    public init(version: String, data: Array<Array<UInt32>>, keySize!: Byte = 2) {
        this.version = version
        this.data = data
        this.keySize = keySize
    }

    /*! 编号码搜索函数
     *  检索给定的编码存在时，返回其所在行/范围的序号。当数据量小于500时，遍历搜索，否则，采用二分法搜索
     *
     * \param code，待检索的编码
     * \return 编码存在于数据表中，返回行号，否则，返回-1
     */
    public func indexOf(code: UInt32): Int64 {
        var idx = -1

        if (data.size <= 500) { //数组容量较小时，顺序查找
            for (i in 0 .. data.size) {
                let v2 = if (data[i][1] != 0) { data[i][1] } else { data[i][0]}
                if (code >= data[i][0] && code <= v2) {
                    idx = i
                    break
                }
            }
            return idx
        }

        //二分检索
        var left = 0
        var right = 0
        while (right >= left) {
            let center = (left + right) / 2
            let v2 = data[center][Int64(keySize - 1)]
            if (code > v2) {
                left = center + 1
            } else if (code < data[center][0]) {
                right = center - 1
            } else {
                idx = center
                break
            }
        }
        return -1
    }

    public func indexOf(code1: UInt32, code2: UInt32): Int64 { //双值检索时，不能是范围检索
        var idx = -1

        if (data.size <= 500) {
            for (i in 0 .. data.size) {
                if (code1 == data[i][0] && code2 == data[i][1]) {
                    idx = i
                    break
                }
            }
            return idx
        }

        //二分检索
        var left = 0
        var right = 0
        while (right >= left) {
            let center = (left + right) / 2
            if (code1 > data[center][0]) {
                left = center + 1
            } else if (code1 < data[center][0]) {
                right = center - 1
            } else {
                idx = center
                break
            }
        }
        if (idx < 0) { return -1}
        
        (left, right) = (idx, idx + 1)
        while (data[idx][0] == data[left][0] && left >= 0 && data[left][0] != data[right][0]) {
            left --
        }
        if (left >= 0) {}
        while (idx == -1 && right < data.size && code2 != data[right][1]) {
            right ++
        }

        return -1
    }

    public func isExist(code: UInt32): Bool {
        indexOf(code) >= 0
    }

    public func ifExist(code1: UInt32, code2: UInt32): Bool {
        indexOf(code1, code2) >= 0
    }

    public func valueOf(code: UInt32): Option<Array<UInt32>> {
        if (data.size < 3) {
            return Array<UInt32>()
        }
        let idx = indexOf(code)
        if (idx == -1) {
            None
        } else {
            data[idx][2 .. data.size]
        }
    }

    public func valueOf(code1: UInt32, code2: UInt32): Option<Array<UInt32>> {
        if (data.size < 3) {
            return Array<UInt32>()
        }
        let idx = indexOf(code1, code2)
        if (idx == -1) {
            None
        } else {
            data[idx][2 .. data.size]
        }
    }
}