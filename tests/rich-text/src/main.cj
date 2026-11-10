package rich_text_contract

main(): Int64 {
    valueContract()
    graphemeContract()
    sgrContract()
    utf8Contract()
    limitContract()
    controlStringContract()
    unsupportedContract()
    invalidUtf8Contract()
    aliasContract()
    componentContract()
    bindingContract()
    csiUtf8FirstFaultContract()
    println("PASS: rich text public contract")
    return 0
}
