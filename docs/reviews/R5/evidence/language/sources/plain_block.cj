// Without a collector, only the lambda result is returned, not every expression.
func Block(body: () -> Int64): Int64 { body() }
main(): Int64 {
    let result = Block { 1; 2; 3 }
    if (result != 3) { return 1 }
    println("PASS trailing lambda returns last expression; does not collect three children")
    return 0
}
