package cjtui.style

public enum Color <: Equatable<Color> {
    | Default | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White

    public operator func ==(other: Color): Bool {
        match ((this, other)) {
            case (Default, Default) | (Black, Black) | (Red, Red) | (Green, Green) | (Yellow, Yellow) | (Blue, Blue)
                | (Magenta, Magenta) | (Cyan, Cyan) | (White, White) => true
            case _ => false
        }
    }
}
