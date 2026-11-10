package session_extensions
import std.env.*
main(): Int64 {
    try {
        let scenario = getVariable("CJTUI_SESSION_CASE") ?? "headless"
        if (scenario == "headless") { headless() } else { live(scenario) }
        note("completed", "yes")
        saveRecords()
        return 0
    } catch (error: Exception) {
        note("fatal", error.message)
        saveRecords()
        return 1
    }
}
