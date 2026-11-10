package probe_api
public class Entity {
    let state: Int64 = 7
    private let secret: Int64 = 3
    public init() {}
    public func read(): Int64 { secret + crossFile(this) + Tint(2).value }
}
