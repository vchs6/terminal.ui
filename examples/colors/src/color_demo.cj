package cjtui_colors

import cjtui.*

class ColorDemo {
    var mode: Int64 = 0
    var styled = true
    var sample = Text("")
    func nextMode(app: Application): Unit {
        mode = (mode + 1) % 4
        let modes = [ColorMode.Basic16, ColorMode.Indexed256, ColorMode.TrueColor, ColorMode.Monochrome]
        app.colorMode(modes[mode])
    }
    func toggle(): Unit {
        styled = !styled
        sample.bold(styled).dim(styled).italic(styled).underline(styled).inverse(styled).strikethrough(styled)
    }
}
