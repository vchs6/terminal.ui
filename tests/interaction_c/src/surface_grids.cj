package interaction_c

import cjtui.*

// Every grid literal was worked out from the contract, independently of product
// layout. See golden.md for coordinates, sources and the exact 8-column rows.
func surfacesAndLatestBase(): Unit {
    let value = Observable<String>("ijklmnop")
    let root = Column {
        Text("abcdefgh");
        Text({=> value.get()});
        Text("qrstuvwx")
    }.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let opaque = Text("X").width(3).height(1)
    let modal = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({
        => modal.value = Some(node(root).openOverlay(opaque, options: OverlayOptions(mode: OverlayMode.Modal)))
    })
    picture(app.snapshot(8, 3), "abcdefgh\nijX  nop\nqrstuvwx", "G01 modal fills only its centered layout box")
    opaque.surface(SurfaceMode.Transparent)
    picture(app.snapshot(8, 3), "abcdefgh\nijXlmnop\nqrstuvwx",
        "G02 explicit transparent overrides default modal surface")
    opaque.background(Color.Default)
    picture(app.snapshot(8, 3), "abcdefgh\nijX  nop\nqrstuvwx",
        "G03 transparent surface does not cancel explicit background fill")
    value.set("IJKLMNOP")
    picture(app.snapshot(8, 3), "abcdefgh\nIJX  NOP\nqrstuvwx", "G04 underlying bindings update while covered")
    app.batch({=> modal.value.getOrThrow().close()})
    picture(app.snapshot(8, 3), "abcdefgh\nIJKLMNOP\nqrstuvwx", "G04 close exposes latest base rather than saved screen")
    let canvas = Canvas(
        {_ => Size(3, 1)},
        {
            context =>
                context.put(0, 0, "X")
                context.put(1, 0, " ")
        }
    )
    let layer = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({
        => layer.value = Some(node(root).openOverlay(canvas, options: OverlayOptions(takeFocus: false)))
    })
    let saved = app.snapshot(8, 3)
    picture(saved, "abcdefgh\nIJX MNOP\nqrstuvwx", "G05 written space opaque while next untouched cell is a hole")
    picture(render(root, 8, 3), "abcdefgh\nIJX MNOP\nqrstuvwx", "G06 mounted full M1 render consumes committed layers")
    check(!saved.toPlainText().contains("\u{1b}"), "G06 headless plain snapshot has no device syntax")
    app.batch({=> layer.value.getOrThrow().close()})
    picture(saved, "abcdefgh\nIJX MNOP\nqrstuvwx", "G06 old snapshot remains independent after close")
    app.dispose()
}

func sourceBasedCaretOcclusion(): Unit {
    let root = Canvas(
        {_ => Size(8, 3)},
        {
            context =>
                context.put(0, 0, "abcdefgh")
                context.put(0, 1, "ijklmnop")
                context.put(0, 2, "qrstuvwx")
                context.caret(3, 1)
        }
    ).focusable(true).viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let original = app.snapshot(8, 3).toPlainText()
    check(app.caretSnapshot().visible, "G07 focused base Canvas supplies visible caret")
    let drawn = Observable<Bool>(false)
    let cover = Canvas({_ => Size(3, 1)}, {
        context => if (drawn.get()) {
            context.put(1, 0, "l")
        }
    })
    let handle = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({
        => handle.value = Some(
            node(root).openOverlay(cover, options: OverlayOptions(mode: OverlayMode.Passive, takeFocus: false)))
    })
    check(app.snapshot(8, 3).toPlainText() == original && app.caretSnapshot().visible,
        "G08 transparent hole keeps logical caret visible")
    drawn.set(true)
    check(app.snapshot(8, 3).toPlainText() == original && !app.caretSnapshot().visible,
        "G09 same glyph and style opaque source hides caret despite identical final pixels")
    focused(app, node(root), "G09 passive visual does not steal logical focus")
    app.batch({=> handle.value.getOrThrow().close()})
    app.snapshot(8, 3)
    check(app.caretSnapshot().visible, "G10 closing visual cover restores caret from latest target")
    app.dispose()
}
