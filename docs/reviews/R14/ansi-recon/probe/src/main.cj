package text_contract_probe

import ansies.core.parseCSIParams
import ansies.utils.StyledText

func check(label: String, value: String): Unit {
    match (parseCSIParams(value, terms: "m")) {
        case None => println("${label}:None")
        case Some(values) =>
            var joined = ""
            for (v in values) {
                joined += "<" + v + ">"
            }
            println("${label}:${values.size}:${joined}")
    }
}

main(): Int64 {
    checkTextOverloads()
    check("sgr", "\u{1b}[31m")
    check("empty", "\u{1b}[m")
    check("empty-fields", "\u{1b}[;31;m")
    check("no-final", "\u{1b}[31")
    check("wrong-final", "\u{1b}[31R")
    check("private", "\u{1b}[?31m")
    check("colon", "\u{1b}[38:2::1:2:3m")
    check("c1-unicode", "\u{9b}31m")
    let encoded = StyledText("A").bold().then("B").toString()
    var bytes = ""
    for (b in encoded.toArray()) {
        bytes += b.toString() + ","
    }
    println("styled-text-bytes:${bytes}")
    return 0
}
