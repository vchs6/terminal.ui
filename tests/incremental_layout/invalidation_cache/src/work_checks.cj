package incremental_invalidation_cache

class WorkChecks {
    static var failures: Int64 = 0
    static func verify(value: Bool, label: String): Unit {
        if (!value) {
            failures++
            println("WORK_FAIL ${label}")
        }
    }
}
