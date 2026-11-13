import std.process.*

main(): Int64 {
    match (Process.current.arguments[0]) {
        case "pre-build" | "pre-test" => Process.run("bash", ["native/build.sh"])
        case _ => 0
    }
}
