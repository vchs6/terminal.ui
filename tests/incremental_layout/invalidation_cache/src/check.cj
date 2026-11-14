package incremental_invalidation_cache

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL: ${label}") }
}
