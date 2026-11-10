package keyboard_contract
import std.collection.*

func joined(parts: Array<Array<UInt8>>): Array<UInt8> {
    let result = ArrayList<UInt8>()
    for (part in parts) { result.add(all: part) }
    result.toArray()
}
