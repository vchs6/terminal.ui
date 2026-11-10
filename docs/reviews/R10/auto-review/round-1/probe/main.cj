package cjtui

main(): Int64 {
    let full = Style(foreground: Color.Red, bold: true, dim: true, italic: true,
        underline: true, inverse: true, strikethrough: true)
    let projected = projectTerminalStyle(full, TerminalRenderProfile(colorMode: ColorMode.Basic8, noColorVideo: 19))
    println("ncv19 color: bold=${projected.bold} dim=${projected.dim} italic=${projected.italic} underline=${projected.underline} inverse=${projected.inverse} strike=${projected.strikethrough}")
    let rich = [Text("AUTO RGB 1,128,254")]
    let marker = [Text("EVENT-FENCE")]
    let root = Column {
        rich[0]
        Text("Unicode")
        marker[0]
        Text("Resize edge")
    }
    println("terminal fixture root children=${root.children.size}")
    for (child in root.children) { println("child=${child.value}") }
    return 0
}
