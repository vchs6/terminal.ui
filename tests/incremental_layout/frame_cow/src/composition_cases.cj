package incremental_frame_cow

import cjtui.*

// Catches copying holes as opaque blanks, whole-row overlay, or source mutation.
func opacityAndComposition(): Unit {
    let source = Frame(3, 1)
    source.put(0, 0, "XYZ")
    source.clear(Rect(1, 0, 1, 1), transparent: true)
    let copy = source.copy(Rect(0, 0, 3, 1))
    let resized = source.resized(3, 1)
    let expanded = source.resized(3, 2)
    for (layer in [source, copy, resized, expanded]) {
        let target = Frame(3, 2)
        target.put(0, 0, "ABC\nDEF")
        target.composite(layer)
        plain(target, if (layer.height == 2) { "XBZ\n   " } else { "XBZ\nDEF" }, "F003 transparent hole")
        cell(layer, 1, 0, " ", 1, false, Style(), true, "hole preserved")
    }
    cell(expanded, 1, 1, " ", 1, false, Style(), false, "expansion uses default opacity")
    let styled = Style(background: Color.Blue, bold: true)
    copy.fillRect(Rect(1, 0, 1, 1), style: styled)
    let target = Frame(3, 1)
    target.put(0, 0, "ABC")
    target.composite(copy)
    plain(target, "X Z", "styled space covers lower content")
    cell(target, 1, 0, " ", 1, false, styled, false, "styled space remains opaque")
    cell(source, 1, 0, " ", 1, false, Style(), true, "overlay source unchanged")
    // Different Frame objects can still share an ancestor. Freeze source before writing target.
    let old = Frame(6, 1)
    old.put(0, 0, "abcdef")
    let sibling = old.copy(Rect(0, 0, 6, 1))
    old.composite(sibling, x: 1)
    plain(old, "aabcde", "shared source shift")
    plain(sibling, "abcdef", "shared source unchanged")
    sibling.composite(sibling, x: -1)
    plain(sibling, "bcdeff", "left self composition uses initial source")
    old.composite(old, x: 1)
    plain(old, "aaabcd", "right self composition uses initial source")
}

// Catches a shared fast path losing clipped cluster style/partners, emoji or policy metadata.
func unicodeAndResize(): Unit {
    let style = Style(foreground: Color.Red, background: Color.Blue, inverse: true)
    let source = Frame(7, 2, transparent: true)
    source.put(0, 0, "A中👩‍💻éZ", style: style)
    cell(source, 3, 0, "👩‍💻", 2, false, style, false, "emoji ZWJ lead")
    cell(source, 4, 0, "", 0, true, style, false, "emoji continuation")
    cell(source, 5, 0, "é", 1, false, style, false, "combining cluster")
    let clipped = source.copy(Rect(2, 0, 2, 1))
    plain(clipped, "  ", "both clipped cluster halves become spaces")
    cell(clipped, 0, 0, " ", 1, false, style, false, "left clipped continuation")
    cell(clipped, 1, 0, " ", 1, false, style, false, "right clipped emoji lead")
    let narrowed = source.resized(4, 2)
    plain(narrowed, "A中 \n    ", "width change clips emoji")
    cell(narrowed, 3, 0, " ", 1, false, style, false, "resize half style")
    cell(narrowed, 0, 1, " ", 1, false, Style(), true, "resize keeps hole")
    let shifted = source.copy(Rect(0, 0, 7, 2))
    shifted.composite(source, x: -2)
    // source columns 2..6: half 中 => space, full emoji, combining, Z.
    plain(shifted, " 👩‍💻éZéZ\n       ", "negative clipped overlay and destination partner repair")
    cell(shifted, 0, 0, " ", 1, false, style, false, "negative clipped source style")
    let edge = source.copy(Rect(0, 0, 7, 2))
    edge.put(6, 0, "中") // right-edge omission must not clear the previous Z
    cell(edge, 6, 0, "Z", 1, false, style, false, "right-edge omitted cluster")
    edge.put(-1, 1, "中Q")
    cell(edge, 0, 1, " ", 1, false, Style(), true, "negative lead omitted")
    cell(edge, 1, 1, "Q", 1, false, Style(), false, "negative origin still advances by display columns")
    let policy = Frame(4, 1, ambiguousWide: true, transparent: true, maxCells: 8)
    policy.put(0, 0, "·")
    let policyCopy = policy.copy(Rect(0, 0, 4, 1))
    let policyResize = policy.resized(4, 2)
    cell(policyCopy, 0, 0, "·", 2, false, Style(), false, "copied width policy")
    policyCopy.put(2, 0, "·")
    cell(policyCopy, 3, 0, "", 0, true, Style(), false, "copied write width policy")
    cell(policyResize, 0, 1, " ", 1, false, Style(), true, "default transparent metadata")
    rejects({ => policyResize.resized(5, 2); () }, "resize keeps maxCells")
    rejects({ => policyCopy.copy(Rect(0, 0, 9, 1)); () }, "copy keeps maxCells")
    rejects({ => policyCopy.composite(Frame(0, 0)); () }, "width policy rejects even empty layer")
    cell(policyCopy, 0, 0, "·", 2, false, Style(), false, "policy rejection has no mutation")
    let outside = source.copy(Rect(-1, -1, 3, 2))
    cell(outside, 0, 0, " ", 1, false, Style(), true, "copy outside default")
    cell(outside, 1, 1, "A", 1, false, style, false, "copy shifted intersection")
    cell(outside, 2, 1, " ", 1, false, style, false, "copy right cut")
    // The original remains the literal fixture after all alternate copies/overlays.
    plain(source, "A中👩‍💻éZ\n       ", "source after clipping branches")
}
