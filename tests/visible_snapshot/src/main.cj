package visible_snapshot

import std.env.*

main(): Int64 {
    if (getVariable("CJTUI_VISIBLE_SNAPSHOT_SHORT_ONLY") == Some("1")) { shortFileErrors(); return 0 }
    glyphSnapshots()
    layerSnapshots()
    viewportSnapshots()
    decorationSnapshots()
    themeSnapshots()
    zeroSnapshots()
    fileErrors()
    println("PASS C003 visible snapshot public consumer")
    return 0
}
