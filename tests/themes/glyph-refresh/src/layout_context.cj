package theme_glyph_refresh
import cjtui.*
func layoutContext(): Unit {
    for (mode in [GlyphMode.Unicode,GlyphMode.Auto,GlyphMode.Ascii]) {
        let expected = if (mode == GlyphMode.Ascii) { "A...q" } else { "ABC…q" }
        grid(Row { Text("ABCDE").layoutWeight(1).overflow(TextOverflow.Ellipsis); Text("q").width(1) },5,1,mode,expected,"Row actual allocated width")
        let padded = if (mode == GlyphMode.Ascii) { " A... " } else { " ABC… " }
        grid(Text("ABCDE").padding(left:1,top:0,right:1,bottom:0).overflow(TextOverflow.Ellipsis),6,1,mode,padded,"padding before prefix budget")
        let lines = if (mode == GlyphMode.Ascii) { "A...\nXY  \nZ   " } else { "ABC…\nXY  \nZ   " }
        grid(Column { Text("ABCDE\nXY").overflow(TextOverflow.Ellipsis); Text("Z") },4,3,mode,lines,"hard-line height and sibling")
        grid(Column { Text("ABCDE").width(0).overflow(TextOverflow.Ellipsis); Text("Z") },1,2,mode," \nZ","zero allocation hard-line height")
        grid(Text("ABCDE").visible(false).overflow(TextOverflow.Ellipsis),4,1,mode,"    ","invisible no marker")
    }
    let rich = RichText([TextSpan("e",style:TextStylePatch(foreground:Some(Color.Red))),TextSpan("\u{301}BCDE",style:TextStylePatch(foreground:Some(Color.Blue)))])
    let frame = render(Text(rich).overflow(TextOverflow.Ellipsis),4,1,glyphMode:GlyphMode.Ascii)
    check(frame.toPlainText() == "e\u{301}...","cross-span cluster complete")
    check(frame.cellAt(0,0).grapheme == "e\u{301}" && frame.cellAt(0,0).style.foreground == Color.Red,"first scalar cluster style")
    let explicit = render(Text(rich).foreground(Color.Green).bold(true).overflow(TextOverflow.Ellipsis),4,1,glyphMode:GlyphMode.Ascii)
    for (x in 0..4) {
        check(explicit.cellAt(x,0).style.foreground == Color.Green && explicit.cellAt(x,0).style.bold,"explicit mask prefix/marker ${x}")
    }
    check(rich.toPlainText() == "e\u{301}BCDE","logical RichText unchanged")
}
