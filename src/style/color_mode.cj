package cjtui.style

public enum ColorMode <: Equatable<ColorMode> {
    | Basic16 | Indexed256 | TrueColor | Monochrome

    public operator func ==(other: ColorMode): Bool {
        match ((this, other)) {
            case (Basic16, Basic16) | (Indexed256, Indexed256) | (TrueColor, TrueColor) | (Monochrome, Monochrome) => true
            case _ => false
        }
    }
}
