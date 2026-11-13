package editing_missing_api

import cjtui.*
main(): Int64 {
    let controller = TextEditController()
    let input = TextInput(Observable<String>("a"), controller: Some(controller))
    let area = TextArea(Observable<String>("b"))
    let selection = TextSelection(0, 0)
    let limits = TextEditLimits()
    println("${input} ${area} ${selection} ${limits}")
    0
}
