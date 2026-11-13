package output_recovery

import std.env.*
import std.fs.*

foreign func cjt_test_arm(mode: Int32, offset: Int64, sequence: Int32): Unit

main(): Int64 {
    let directory = getVariable("CJTUI_RECOVERY_DIR").getOrThrow()
    try {
        if (getVariable("CJTUI_RECOVERY_CASE") == Some("pure")) { pureFrames(); return 0 }
        live(directory)
        return 0
    } catch (error: Exception) {
        File.writeTo(directory + "/consumer-error", error.message.toArray())
        return 1
    }
}
