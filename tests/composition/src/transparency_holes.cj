package composition_contract

import cjtui.*

func holeResult(value: Bool, name: String): Bool {
    println((if (value) { "PASS: " } else { "FAIL: " }) + name)
    value
}

// F003: copying data preserves explicit transparent holes in an opaque-default frame.
// All checks run so the RED distinguishes source composition, copy and resized.
func transparentHoleCopies(): Unit {
    var passed = true
    let source = Frame(3, 1)
    source.put(0, 0, "XYZ")
    source.clear(Rect(1, 0, 1, 1), transparent: true)
    let copied = source.copy(Rect(0, 0, 3, 1))
    let resized = source.resized(3, 1)
    let grown = source.resized(5, 2)
    let variants = [source, copied, resized]
    let names = ["original", "copy", "same-size resized"]
    for (i in 0..variants.size) {
        let layer = variants[i]
        passed = holeResult(layer.toPlainText() == "X Z", "${names[i]}: exact source text [${layer.toPlainText()}]") && passed
        passed = holeResult(!layer.cellAt(0, 0).isTransparent && emptyCell(layer, 1, 0, true) &&
            !layer.cellAt(2, 0).isTransparent, "${names[i]}: flags false/true/false with normalized hole") && passed
        for (x in 0..3) {
            passed = holeResult(layer.cellAt(x, 0).isTransparent == source.cellAt(x, 0).isTransparent,
                "${names[i]}: column ${x} transparent flag equals original") && passed
        }
        let lower = Frame(3, 1)
        lower.put(0, 0, "ABC")
        lower.composite(layer)
        passed = holeResult(lower.toPlainText() == "XBZ", "${names[i]} over ABC: [${lower.toPlainText()}], expected [XBZ]") && passed
    }
    passed = holeResult(emptyCell(grown, 1, 0, true), "grown resized: source hole remains transparent") && passed
    passed = holeResult(emptyCell(grown, 3, 0, false) && emptyCell(grown, 4, 0, false) &&
        emptyCell(grown, 0, 1, false) && emptyCell(grown, 4, 1, false),
        "grown resized: new columns and rows inherit opaque source default") && passed
    let lower = Frame(5, 2)
    lower.put(0, 0, "ABCDE\nFGHIJ")
    lower.composite(grown)
    passed = holeResult(lower.toPlainText() == "XBZ  \n     ",
        "grown resized over lower: [${lower.toPlainText()}], expected [XBZ  /     ]") && passed
    copied.put(0, 0, "Q")
    copied.put(1, 0, "C")
    resized.put(2, 0, "R")
    passed = holeResult(source.toPlainText() == "X Z" && emptyCell(source, 1, 0, true),
        "mutating copied/resized cells cannot mutate original hole or text") && passed
    passed = holeResult(copied.toPlainText() == "QCZ" && resized.toPlainText() == "X R",
        "copy and resized own independent mutable cells") && passed
    source.put(0, 0, "S")
    passed = holeResult(copied.toPlainText() == "QCZ" && resized.toPlainText() == "X R" &&
        grown.toPlainText() == "X Z  \n     ", "mutating original cannot mutate existing copies") && passed
    check(passed, "F003 explicit transparent holes survive data copy and resize")
}
