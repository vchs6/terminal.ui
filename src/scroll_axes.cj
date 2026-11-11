package cjtui

public enum ScrollAxes <: Equatable<ScrollAxes> {
    | Off | Vertical | Horizontal | Both
    public operator func ==(other: ScrollAxes): Bool {
        match ((this,other)) {
            case (Off,Off) | (Vertical,Vertical) | (Horizontal,Horizontal) | (Both,Both) => true
            case _ => false
        }
    }
    func horizontal(): Bool { this == ScrollAxes.Horizontal || this == ScrollAxes.Both }
    func vertical(): Bool { this == ScrollAxes.Vertical || this == ScrollAxes.Both }
}
