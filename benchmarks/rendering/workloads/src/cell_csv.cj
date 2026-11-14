package rendering_workloads

import cjtui.*
import std.collection.ArrayList

// These records describe logical Cells, before any terminal projection. This
// function belongs only to correctness runs, outside performance windows.
public func cellCsv(frame: Frame, scenario: String, seed: Int64, epoch: Int64, path: String): String {
    var output = ""
    for (y in 0..frame.height) {
        for (x in 0..frame.width) {
            let cell = frame.cellAt(x, y)
            let style = cell.style
            output += "${scenario},${frame.width},${frame.height},${seed},${epoch},${path},${x},${y},${utf8Hex(cell.grapheme)},${cell.width},${cell.continuation},${cell.isTransparent},\"${colorName(style.foreground)}\",\"${colorName(style.background)}\",${style.bold},${style.dim},${style.italic},${style.underline},${style.inverse},${style.strikethrough}\n"
        }
    }
    output
}

public func cellCsvHeader(): String {
    "scenario,width,height,seed,epoch,path,x,y,grapheme_utf8_hex,cell_width,continuation,transparent,foreground,background,bold,dim,italic,underline,inverse,strikethrough\n"
}

private func utf8Hex(value: String): String {
    let digits = "0123456789abcdef".toArray()
    let result = ArrayList<UInt8>()
    for (byte in value.toArray()) {
        result.add(digits[Int64(byte / 16)])
        result.add(digits[Int64(byte % 16)])
    }
    String.fromUtf8(result.toArray())
}
