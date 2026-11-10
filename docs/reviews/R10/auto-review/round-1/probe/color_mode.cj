package cjtui

public enum ColorMode <: Equatable<ColorMode> & ToString {
    | Basic8 | Basic16 | Indexed256 | TrueColor | Monochrome

    public operator func ==(other: ColorMode): Bool {
        match ((this, other)) {
            case (Basic8, Basic8) | (Basic16, Basic16) | (Indexed256, Indexed256) | (TrueColor, TrueColor)
                | (Monochrome, Monochrome) => true
            case _ => false
        }
    }
    public func toString(): String {
        match (this) {
            case Basic8 => "Basic8"
            case Basic16 => "Basic16"
            case Indexed256 => "Indexed256"
            case TrueColor => "TrueColor"
            case Monochrome => "Monochrome"
        }
    }
}
