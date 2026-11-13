package nested_array_probe
import std.fs.File
func choose(callback: (String) -> Unit): String { callback("a"); "chosen" }
func collect(body: () -> Unit): Unit { body() }
main(): Int64 {
    let chosen = [""]
    let calls = [0]
    let mode = "normal"
    let report = { name: String, value: String => File.writeTo("/tmp/native-array-" + name, value.toArray()) }
    let slots = Array<?String>(1, repeat: Option<String>.None)
    collect {
        slots[0] = Some(choose({ key =>
            calls[0]++
            if (mode == "callback-failure") { throw Exception("sentinel") }
            chosen[0] = chosen[0] + "h:" + key + ";"
            report("chosen", chosen[0])
        }))
    }
    let inspect = { =>
        let current: ?String = Some("focus")
        if (let Some(value) <- current) { report("focus", value) }
    }
    inspect()
    if (chosen[0] != "h:a;") { throw Exception(chosen[0]) }
    0
}
