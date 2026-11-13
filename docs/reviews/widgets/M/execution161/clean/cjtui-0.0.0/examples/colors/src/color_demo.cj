package cjtui_colors

import cjtui.*

class ColorDemo {
    var color: Int64 = 0
    var styled = true
    var sample = Text("")
    var rgbSample = Text("")
    func nextColor(): Unit {
        color = (color + 1) % 3
        let colors = [Color.Rgb(1, 128, 254), Color.Rgb(250, 0, 0), Color.Rgb(238, 238, 238)]
        rgbSample.foreground(colors[color])
    }
    func toggle(): Unit {
        styled = !styled
        sample.bold(styled).dim(styled).italic(styled).underline(styled).inverse(styled).strikethrough(styled)
    }
}
