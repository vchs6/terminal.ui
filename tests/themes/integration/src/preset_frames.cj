package theme_integration_contract
import cjtui.*
func presetFrame(value: ThemePreset, fg: Color, bg: Color, accent: Color): Unit {
    let frame=picture(Column {Text("x");Text("y").styles([StyleUse.Named("accent")])},Theme.preset(value),3,2)
    check(frame.toPlainText()=="x  \ny  ","preset keeps literal hand-authored grid")
    styleAt(frame,0,0,Style(foreground:fg,background:bg),"preset body foreground/background")
    styleAt(frame,1,0,Style(background:bg),"preset root blank is bg-only")
    styleAt(frame,0,1,Style(foreground:accent,background:bg,bold:true),"preset accent pixels")
    styleAt(frame,2,1,Style(background:bg),"named foreground/bold do not add fill intent")
}
func presetFrames(): Unit {
    presetFrame(ThemePreset.Dark,Color.Rgb(232,237,242),Color.Rgb(16,24,32),Color.Rgb(102,204,255))
    presetFrame(ThemePreset.Light,Color.Rgb(24,32,40),Color.Rgb(255,255,255),Color.Rgb(0,90,156))
    presetFrame(ThemePreset.HighContrast,Color.BrightWhite,Color.Black,Color.BrightYellow)
    presetFrame(ThemePreset.Classic,Color.Default,Color.Default,Color.Cyan)
}
