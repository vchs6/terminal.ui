package cjtui.style

public enum Color <: Equatable<Color> {
    | Default | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White | BrightBlack | BrightRed | BrightGreen | BrightYellow
    | BrightBlue | BrightMagenta | BrightCyan | BrightWhite | Indexed(UInt8) | Rgb(UInt8, UInt8, UInt8)

    public operator func ==(other: Color): Bool {
        match ((this, other)) {
            case (Default, Default) | (Black, Black) | (Red, Red) | (Green, Green) | (Yellow, Yellow) | (Blue, Blue)
                | (Magenta, Magenta) | (Cyan, Cyan) | (White, White) | (BrightBlack, BrightBlack)
                | (BrightRed, BrightRed) | (BrightGreen, BrightGreen) | (BrightYellow, BrightYellow)
                | (BrightBlue, BrightBlue) | (BrightMagenta, BrightMagenta) | (BrightCyan, BrightCyan)
                | (BrightWhite, BrightWhite) => true
            case (Indexed(a), Indexed(b)) => a == b
            case (Rgb(r, g, b), Rgb(x, y, z)) => r == x && g == y && b == z
            case _ => false
        }
    }
}
