from pathlib import Path
base=Path('/workspace/work/widgets-small-tests/contract-fix');root=base/'source';ev=base/'evidence'
p=root/'tests/widgets_small/src/construction_cases.cj';before=p.read_text();(ev/'construction-before.cj').write_text(before)
old='''    expectInvalidProperty({ => Label("L").gap(1); () }, "Text-root Label has no gap capability")
    expectInvalidProperty({ => Button("B", { => () }).gap(1); () }, "Text-root Button has no gap capability")'''
new='''    expectLegacyPropertyError({ => Label("L").gap(1); () }, "Label legacy constant gap rejects with IllegalArgumentException")
    expectLegacyPropertyError({ => Button("B", { => () }).gap(1); () }, "Button legacy constant gap rejects with IllegalArgumentException")
    expectInvalidProperty({ => Label("L").setStyle(StyleKeys.gap, StyleValue<Int64>.Value(1)); () }, "Label typed gap rejects with InvalidProperty")
    expectInvalidProperty({ => Button("B", { => () }).gap({ => 1 }); () }, "Button getter gap rejects with InvalidProperty")
    let incompatible = StyleRule().withValue(StyleKeys.gap, StyleValue<Int64>.Value(1))
    expectInvalidProperty({ => frame(Label("L").styles([StyleUse.Inline(incompatible)]), 2, 1); () }, "Label resolved Inline gap rejects with InvalidProperty")'''
helper='''
// LEGACY-PROP-001 preserves this old shortcut's concrete exception type.
func expectLegacyPropertyError(action: () -> Unit, caseName: String): Unit {
    var rejected = false
    try { action() } catch (_: IllegalArgumentException) { rejected = true }
    if (!rejected) { throw IllegalStateException("${caseName}: expected IllegalArgumentException") }
}
'''
oldimport='Radio, TextWrap}';newimport='Radio, StyleKeys, StyleRule, StyleUse, StyleValue, TextWrap}'
assert before.count(old)==1 and before.count(oldimport)==1
newsource=before.replace(oldimport,newimport).replace(old,new)+helper
assert newsource.removesuffix(helper).replace(new,old).replace(newimport,oldimport)==before
p.write_text(newsource);(ev/'construction-after.cj').write_text(newsource)
(ev/'bounded-edit.json').write_text(__import__('json').dumps({'file':str(p),'old_block':old,'new_block':new,'added_helper':helper,'old_import':oldimport,'new_import':newimport,'inverse_equals_baseline':True},indent=2)+'\n')
p=root/'tests/widgets_small/README.md';before=p.read_text();(ev/'readme-before.md').write_text(before)
old='invalid Text-gap/Canvas-wrap must raise InvalidProperty.'
new='legacy constant Text-gap raises IllegalArgumentException; typed/getter/resolved Inline Text-gap and Canvas-wrap raise InvalidProperty (LEGACY-PROP-001).'
assert before.count(old)==1;p.write_text(before.replace(old,new));(ev/'readme-after.md').write_text(p.read_text())
probe=ev/'public-probe'
p=probe/'cjpm.toml';p.write_text(p.read_text().replace('[dependencies]','[dependencies]\ncjtui = { path = "/workspace/work/terminal.ui" }'))
(probe/'cangjie-repo.toml').write_text('[repository.cache]\npath = "/workspace/work/viewport-tests/cache"\n[repository.home]\nregistry = "https://pkg.cangjie-lang.cn/registry"\n')
(probe/'src/main.cj').write_text('''package legacy_property_probe

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
''')
