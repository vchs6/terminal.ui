import audit_supplement_macros.*
@Inspect
class Inspector<T> {
    let label: String
    var state: T
    init(label: String, initial: T) { this.label = label; state = initial }
    func build(): Unit {}
}
main(): Unit { let value = Inspector<Int64>("x", 1) }
