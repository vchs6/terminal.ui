package incremental_frame_cow

import cjtui.*

// Catches stale content or projected-style caches attached to a shared row or Frame object.
func ansiSnapshots(): Unit {
    let original = Frame(3, 1)
    original.put(0, 0, "A", style: Style(foreground: Color.Red))
    original.put(1, 0, "中")
    let saved = original.copy(Rect(0, 0, 3, 1))
    let color = "\u{1b}[0m\u{1b}[1;1H\u{1b}[0m\u{1b}[31mA\u{1b}[0m中\u{1b}[0m"
    let mono = "\u{1b}[0m\u{1b}[1;1HA中\u{1b}[0m"
    check(original.toAnsi(colorMode: ColorMode.Basic8) == color, "literal Basic8 full snapshot")
    check(saved.toAnsi(colorMode: ColorMode.Monochrome) == mono, "literal monochrome full snapshot")
    check(original.toAnsi(colorMode: ColorMode.Basic8) == color, "profile round trip")
    original.put(2, 0, "Q")
    let edited = "\u{1b}[0m\u{1b}[1;1H\u{1b}[0m\u{1b}[31mA\u{1b}[0m Q\u{1b}[0m"
    check(original.toAnsi(colorMode: ColorMode.Basic8) == edited, "mutated original ANSI and partner repair")
    check(saved.toAnsi(colorMode: ColorMode.Basic8) == color, "old saved ANSI stays original")
    saved.clear(Rect(0, 0, 1, 1), transparent: true)
    check(saved.toAnsi(colorMode: ColorMode.Basic8) == "\u{1b}[0m\u{1b}[1;1H 中\u{1b}[0m",
        "transparent snapshot flattens to default blank")
    check(original.toAnsi(colorMode: ColorMode.Basic8) == edited, "external saved edit does not affect original ANSI")
    let unrelated = Frame(3, 1)
    unrelated.put(0, 0, "XYZ")
    check(unrelated.toAnsi() == "\u{1b}[0m\u{1b}[1;1HXYZ\u{1b}[0m", "unrelated Frame full ANSI")
}
