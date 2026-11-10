package toml_lib
import cangjie_toml.cangjie_toml.*
import stdx.serialization.serialization.*
public func parsedName(input: String): String {
 let dm = (DataModel.fromToml(input) as DataModelStruct).getOrThrow()
 String.deserialize(dm.get("name"))
}
