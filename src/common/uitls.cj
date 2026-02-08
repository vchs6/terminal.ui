package acnl.common

public func isExistInTable(value: UInt32, table: Array<(UInt32, UInt32)>): Bool {
    var left = 0
    var right = table.size - 1
    var notFound: Bool = true
    while (notFound && (right >= left)) {
        let center: Int64 = (left + right) / 2
        let v = table[center]
        if (value < v[0]) {
            right = center - 1
        } else if (value > v[1]) {
            left = center + 1
        } else {
            notFound = false
            break
        }
    }
    ! notFound
}