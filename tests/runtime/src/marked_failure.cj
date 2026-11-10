package runtime_contract

class MarkedFailure <: Exception {
    let tag: String
    var marker: Int64 = 0
    init(tag: String) { super(tag); this.tag = tag }
}
