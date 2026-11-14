package incremental_composition

class Checks {
    static var correctness: Int64 = 0
    static var work: Int64 = 0
    static func equal(value: Bool, label: String): Unit {
        if (!value) { correctness++; println("CORRECTNESS_FAIL ${label}") }
    }
    static func amount(value: Bool, label: String): Unit {
        if (!value) { work++; println("WORK_RED ${label}") }
    }
}
