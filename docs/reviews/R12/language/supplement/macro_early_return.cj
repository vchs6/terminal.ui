import audit_component_macros.*
import auditsupplement.*

@Component
class Early {
    let value: Int64
    public init(early: Bool) {
        value = 1
        if (early) { return }
    }
    public func build(): Unit {}
}
main(): Unit { let early = Early(true) }
