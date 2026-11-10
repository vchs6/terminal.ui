package interaction_a_contract
import cjtui.*
func contextExpiry(): Unit {
    let saved=Box<?PaintContext>(Option<PaintContext>.None)
    let c=Canvas({ _=>Size(1,1) },{p=>saved.value=Some(p); p.put(0,0,"x")})
    let a=Application(c,theme:plainTheme()); a.startHeadless(); a.snapshot(1,1)
    let p=saved.value.getOrThrow()
    for(read in [{=>p.size;()}, {=>p.clip;()}, {=>p.defaultStyle;()}, {=>p.selectedStyle;()}, {=>p.focused;()}, {=>p.enabled;()},
        {=>p.textWidth("x");()}, {=>p.put(0,0,"x")}, {=>p.put(0,0,RichText("x"))}, {=>p.fill(Rect(0,0,1,1))}, {=>p.caret(0,0)}]) {
        code("ExpiredPaintContext",read)
    }
    let w=spawn { code("WrongUIContext",{=>p.size;()}); code("WrongUIContext",{=>p.put(0,0,"x")}) }; w.get(Duration.second*5)
    let other=Application(Text("o"),theme:plainTheme()); other.startHeadless()
    other.batch({=>code("WrongUIContext",{=>p.clip;()}); code("WrongUIContext",{=>p.caret(0,0)})})
    other.dispose(); a.dispose(); code("ExpiredPaintContext",{=>p.size;()})
}
