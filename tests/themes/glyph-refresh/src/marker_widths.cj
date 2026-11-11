package theme_glyph_refresh
import cjtui.*
// T005/G006 hand goldens, never helper or renderer output.
func markerWidths(): Unit {
    let unicode = ["", "…", "A…", "AB…", "ABC…"]
    let ascii = ["", ".", "..", "...", "A..."]
    for (width in 0..5) {
        let node = Text("ABCDE").wrap(TextWrap.None).overflow(TextOverflow.Ellipsis)
        for (mode in [GlyphMode.Unicode,GlyphMode.Auto]) {
            grid(node,width,1,mode,unicode[width],"Unicode/Auto width ${width}")
        }
        grid(node,width,1,GlyphMode.Ascii,ascii[width],"Ascii width ${width}")
        check(render(node,width,1).toPlainText() == unicode[width],"default width ${width}")
    }
    for (mode in [GlyphMode.Unicode,GlyphMode.Ascii,GlyphMode.Auto]) {
        grid(Text("ABCD").overflow(TextOverflow.Ellipsis),4,1,mode,"ABCD","exact fit no marker")
        grid(Text("ABCDE").overflow(TextOverflow.Clip),4,1,mode,"ABCD","Clip independent")
        grid(Text("ABCD").wrap(TextWrap.Grapheme).overflow(TextOverflow.Ellipsis),2,1,mode,"AB","vertical hidden wrap no marker")
        grid(Text("AB\r\nCD").overflow(TextOverflow.Ellipsis),2,2,mode,"AB\nCD","CRLF hard break")
    }
    grid(Text("éBCDE").overflow(TextOverflow.Ellipsis),4,1,GlyphMode.Ascii,"é...","offline Ascii preserves Unicode body")
    grid(Text("e\u{301}BCDE").overflow(TextOverflow.Ellipsis),4,1,GlyphMode.Ascii,"e\u{301}...","complete combining prefix")
    grid(Text("A中BCDE").overflow(TextOverflow.Ellipsis),4,1,GlyphMode.Unicode,"A中…","complete CJK prefix")
    grid(Text("中ABCDE").overflow(TextOverflow.Ellipsis),4,1,GlyphMode.Ascii," ...","no half CJK at prefix boundary")
    grid(Text("中X").wrap(TextWrap.Grapheme).overflow(TextOverflow.Ellipsis),1,2,GlyphMode.Ascii,".\nX","oversize wrap horizontal marker")
}
