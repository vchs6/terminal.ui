package keyboard_contract

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL ${name}") }
}

main(): Int64 {
    protocolCases()
    c1Cases()
    temporalCases()
    resourceCases()
    publicApiCases()
    protocolReportCases()
    println("PASS public KeyboardDecoder contract; device integration remains separate")
    0
}
