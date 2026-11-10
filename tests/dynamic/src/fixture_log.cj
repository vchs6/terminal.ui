package dynamic_contract

import std.collection.*

class FixtureLog {
    let bodies = ArrayList<String>()
    let mounts = ArrayList<String>()
    let cleanups = ArrayList<String>()
    var builds: Int64 = 0

    func trace(): String {
        var result = ""
        for (entry in cleanups) { result += entry + "," }
        result
    }
}
