package cjtui.style
public enum Dimension <: Equatable<Dimension> {
    | Auto | Cells(Int64)
    public operator func ==(other: Dimension): Bool {
        match ((this, other)) {
            case (Auto, Auto) => true
            case (Cells(a), Cells(b)) => a == b
            case _ => false
        }
    }
}
