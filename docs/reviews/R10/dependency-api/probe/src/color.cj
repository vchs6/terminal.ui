package color_probe

public enum Color <: Equatable<Color> {
    | Default | Indexed(UInt8) | RGB(UInt8, UInt8, UInt8)

    public operator func ==(other: Color): Bool {
        match ((this, other)) {
            case (Default, Default) => true
            case (Indexed(a), Indexed(b)) => a == b
            case (RGB(a, b, c), RGB(x, y, z)) => a == x && b == y && c == z
            case _ => false
        }
    }
}
