package cjtui_colors

import cjtui.*

main(): Int64 {
    let demo = ColorDemo()
    let root = Column {
        Text("cjtui colors")
        Row {
            Text("Black ").foreground(Color.Black)
            Text("Red ").foreground(Color.Red)
            Text("Green ").foreground(Color.Green)
            Text("Yellow ").foreground(Color.Yellow)
            Text("Blue ").foreground(Color.Blue)
            Text("Magenta ").foreground(Color.Magenta)
            Text("Cyan ").foreground(Color.Cyan)
            Text("White").foreground(Color.White)
        }
        Row {
            Text("Bright black ").foreground(Color.BrightBlack)
            Text("red ").foreground(Color.BrightRed)
            Text("green ").foreground(Color.BrightGreen)
            Text("yellow ").foreground(Color.BrightYellow)
            Text("blue ").foreground(Color.BrightBlue)
            Text("magenta ").foreground(Color.BrightMagenta)
            Text("cyan ").foreground(Color.BrightCyan)
            Text("white").foreground(Color.BrightWhite)
        }
        Text("Indexed 33 / RGB 250, 0, 0").foreground(Color.Indexed(33)).background(Color.Rgb(250, 0, 0))
        demo.sample = Text("Bold dim italic underline inverse strikethrough")
            .bold()
            .dim()
            .italic()
            .underline()
            .inverse()
            .strikethrough()
        Text("c: color mode   t: text attributes   q: quit")
    }
    let app = Application(root)
    app.onKey {
        event => if (event.text == "q") {
            app.stop()
        } else if (event.text == "c") {
            demo.nextMode(app)
        } else if (event.text == "t") {
            demo.toggle()
        }
    }.run()
    return 0
}
