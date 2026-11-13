package visible_snapshot

import cjtui.*
import std.collection.*
import std.env.*
import std.fs.File

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL ${label}") }
}

func node(component: Component): NodeRef { component.reference().getOrThrow() }

func bareTheme(): Theme { Theme.parse("schema_version=1\nname='snapshot fixture'\n") }

// Each rune here is deliberately a one-column fixture glyph. Wide/combining
// clusters are installed at explicitly hand-counted coordinates with mark().
func grid(rows: Array<String>): Array<Array<ExpectedCell>> {
    Array<Array<ExpectedCell>>(rows.size, { y =>
        let result = ArrayList<ExpectedCell>()
        for (rune in rows[y].runes()) { result.add(ExpectedCell(rune.toString())) }
        result.toArray()
    })
}

func mark(cells: Array<Array<ExpectedCell>>, x: Int64, y: Int64, glyph: String,
    width!: Int64 = 1, style!: Style = Style()): Unit {
    cells[y][x] = ExpectedCell(glyph, width: width, style: style)
    if (width == 2) { cells[y][x + 1] = ExpectedCell("", width: 0, continuation: true, style: style) }
}

func region(cells: Array<Array<ExpectedCell>>, rect: Rect, style: Style): Unit {
    for (y in rect.y..rect.y + rect.height) {
        for (x in rect.x..rect.x + rect.width) {
            let old = cells[y][x]
            cells[y][x] = ExpectedCell(old.glyph, width: old.width, continuation: old.continuation, style: style)
        }
    }
}

func exact(frame: Frame, plain: String, cells: Array<Array<ExpectedCell>>, name: String): Unit {
    check(frame.height == cells.size, "${name} height")
    check(frame.toPlainText() == plain, "${name} complete literal plain grid")
    check(!plain.contains("\u{1b}"), "${name} plain has no ESC")
    for (y in 0..frame.height) {
        check(frame.width == cells[y].size, "${name} width row ${y}")
        for (x in 0..frame.width) {
            let actual = frame.cellAt(x, y); let wanted = cells[y][x]
            check(actual.grapheme == wanted.glyph && actual.width == wanted.width &&
                actual.continuation == wanted.continuation && actual.style == wanted.style && !actual.isTransparent,
                "${name} complete cell (${x},${y})")
        }
    }
}

func save(frame: Frame, plain: String, cells: Array<Array<ExpectedCell>>, name: String): Unit {
    exact(frame, plain, cells, name)
    let output = getVariable("CJTUI_VISIBLE_SNAPSHOT_FILES").getOrThrow()
    frame.writePlainText(output + "/${name}.txt")
    frame.writeAnsi(output + "/${name}.ansi")
    frame.writeAnsi(output + "/${name}.mono.ansi", colorMode: ColorMode.Monochrome)
    check(String.fromUtf8(File.readFrom(output + "/${name}.txt")) == plain, "${name} actual plain file")
    check(String.fromUtf8(File.readFrom(output + "/${name}.ansi")) == frame.toAnsi(), "${name} ANSI file/method parity")
}

func open(app: Application, owner: Component, content: Component, mode: OverlayMode): OverlayHandle {
    let result = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
    app.batch({ => result[0] = Some(node(owner).openOverlay(content,
        options: OverlayOptions(mode: mode, takeFocus: false))) })
    result[0].getOrThrow()
}
