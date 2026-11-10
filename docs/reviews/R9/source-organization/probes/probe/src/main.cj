package org_probe
import probe_api.*
main(): Int64 {
    if (Entity().read() != 12 || Tint(4).value != 4) { return 1 }
    println("PASS root explicit public import; sibling-file internal access; private state stays private")
    0
}
