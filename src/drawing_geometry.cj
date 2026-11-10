package cjtui

// Saturation is sufficient for clipping against the nonnegative Frame viewport.
func signedAdd(a: Int64, b: Int64): Int64 {
    if (b > 0 && a > Int64.Max - b) {
        Int64.Max
    } else if (b < 0 && a < Int64.Min - b) {
        Int64.Min
    } else {
        a + b
    }
}

func containsAxis(start: Int64, length: Int64, point: Int64): Bool {
    length > 0 && point >= start && point < signedAdd(start, length)
}
