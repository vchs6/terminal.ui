package session_lifecycle

import std.env.*

main(): Int64 {
    try {
        lifecycle(getVariable("CJTUI_020_CASE").getOrThrow())
        record("complete", "yes")
        return 0
    } catch (error: Exception) {
        record("assertion", error.message)
        return 1
    }
}
