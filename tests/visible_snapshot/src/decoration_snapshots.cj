package visible_snapshot

import cjtui.*

func decoratedGrid(rows: Array<String>, wide: Bool, moved: Bool, small: Bool): Array<Array<ExpectedCell>> {
    let cells = grid(rows)
    if (wide) { mark(cells, if (moved) { 4 } else { 3 }, 2, "界", width: 2) }
    let shadowX = if (moved) { 7 } else if (small) { 5 } else { 6 }
    let bottomX = if (moved) { 4 } else { 3 }
    region(cells, Rect(shadowX, 2, 1, 2), Style(dim: true))
    region(cells, Rect(bottomX, 4, if (small) { 3 } else { 4 }, 1), Style(dim: true))
    cells
}

func decorationSnapshots(): Unit {
    let root = Column {
        for (_ in 0..5) { Text("abcdefgh").height(1) }
    }.viewport(ScrollAxes.Off)
    let app = Application(root, theme: bareTheme()); app.startHeadless()
    try {
        let popup = Text("界").width(4).height(3).surface(SurfaceMode.Opaque)
            .border(BorderStyle.Rounded).shadow(style: Style(dim: true))
        let handle = open(app, root, popup, OverlayMode.NonModal)
        let initial = decoratedGrid(["abcdefgh", "ab╭──╮gh", "ab│__│░h", "ab╰──╯░h", "abc░░░░h"], true, false, false)
        let old = app.snapshot(8, 5)
        save(old, "abcdefgh\nab╭──╮gh\nab│界│░h\nab╰──╯░h\nabc░░░░h", initial, "decorated-initial")
        let moved = decoratedGrid(["abcdefgh  ", "abc╭──╮h  ", "abc│__│░  ", "abc╰──╯░  ", "abcd░░░░  "], true, true, false)
        save(app.snapshot(10, 5), "abcdefgh  \nabc╭──╮h  \nabc│界│░  \nabc╰──╯░  \nabcd░░░░  ", moved, "decorated-moved")
        app.batch({ => popup.width(3); () })
        let small = decoratedGrid(["abcdefgh", "ab╭─╮fgh", "ab│ │░gh", "ab╰─╯░gh", "abc░░░gh"], false, false, true)
        save(app.snapshot(8, 5), "abcdefgh\nab╭─╮fgh\nab│ │░gh\nab╰─╯░gh\nabc░░░gh", small, "decorated-shrunk")
        app.batch({ => handle.close() })
        save(app.snapshot(8, 5), "abcdefgh\nabcdefgh\nabcdefgh\nabcdefgh\nabcdefgh",
            grid(["abcdefgh", "abcdefgh", "abcdefgh", "abcdefgh", "abcdefgh"]), "decorated-closed")
        save(old, "abcdefgh\nab╭──╮gh\nab│界│░h\nab╰──╯░h\nabc░░░░h", initial, "decorated-old")
    } finally { app.dispose() }
}
