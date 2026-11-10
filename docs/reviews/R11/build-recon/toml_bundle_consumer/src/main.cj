package toml_bundle_consumer
import toml_lib.*
main(): Unit {
 let name = parsedName("name = \"fresh-cjp\"\n")
 if (name != "fresh-cjp") { throw Exception("bad name") }
 println("bundle-name=${name}")
}
