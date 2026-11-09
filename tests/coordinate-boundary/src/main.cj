package slice_coordinate_boundary
import cjtui.*
main(): Int64 {
    var failures: Int64 = 0
    for (x in [Int64.Max, Int64.Min]) {
        let frame = Frame(1, 1)
        try {
            frame.put(x, 0, "a")
            let cell = frame.cellAt(0, 0)
            if (frame.toPlainText() != " " || cell.grapheme != " " || cell.width != 1 || cell.continuation) {
                throw Exception("out-of-bounds write modified frame")
            }
            println("PASS: extreme x=${x} clips without exception and preserves frame")
        } catch (error: Exception) {
            failures++
            println("FAIL: extreme x=${x} must clip without exception: ${error}")
        }
    }
    if (failures != 0) {
        println("FAIL: ${failures} extreme-coordinate cases")
        return 1
    }
    return 0
}
