import std.process.*
main(): Int64 {
 match (Process.current.arguments[0]) {
  case "pre-build" => println("UNICODE-PROBE PRE-BUILD"); 0
  case "post-build" => println("UNICODE-PROBE POST-BUILD"); 0
  case _ => 0
 }
}
