package session_lifecycle

import std.env.*

main(): Int64 {
    try {
        let scenario = getVariable("CJTUI_020_CASE").getOrThrow()
        if (scenario.startsWith("initial-")) { initialLifecycle(scenario) }
        else { lifecycle(scenario) }
        record("complete", "yes")
        return 0
    } catch (error: Exception) {
        record("assertion", error.message)
        return 1
    }
}
