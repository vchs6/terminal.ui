package legacy_property_probe

import cjtui.{Canvas, Constraints, PaintContext, Size, StyleKeys, StyleRule, StyleUse, StyleValue, Text, TextWrap, UIException, render}

func legacy(action: () -> Unit): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    if (!caught) { throw Exception("expected legacy IllegalArgumentException") }
}

func invalid(action: () -> Unit): Unit {
    var code = ""
    try { action() } catch (error: UIException) { code = error.code }
    if (code != "InvalidProperty") { throw Exception("expected exact UIException InvalidProperty") }
}

main(): Int64 {
    legacy({ => Text("T").gap(1); () })
    invalid({ => Text("T").setStyle(StyleKeys.gap, StyleValue<Int64>.Value(1)); () })
    invalid({ => Text("T").gap({ => 1 }); () })
    let incompatible = StyleRule().withValue(StyleKeys.gap, StyleValue<Int64>.Value(1))
    invalid({ => render(Text("T").styles([StyleUse.Inline(incompatible)]), 2, 1); () })
    invalid({ => Canvas({ constraints: Constraints => constraints.constrain(Size(1, 1)) },
        { _: PaintContext => () }).wrap(TextWrap.Grapheme); () })
    println("LEGACY_PROP_001_PUBLIC_TEXT_CANVAS_PATHS_PASS")
    0
}
