import std.fs.*
func store(action: (String) -> Unit): Unit {}
main(): Int64 {
    let directory = "/tmp"
    let serial = [0]
    store { event =>
        if (event == "h") {
            serial[0]++
            File.writeTo(directory + "/ack-" + serial[0].toString(), [97u8, 99u8, 107u8])
        }
        if (event == "b") { "returns a value" }
        if (event == "q") { () }
    }
    return 0
}
