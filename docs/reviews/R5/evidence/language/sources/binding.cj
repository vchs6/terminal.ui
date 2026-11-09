// Tests ordinary value capture vs an explicitly retained computation.
class Model { var value: Int64 = 1 }
main(): Int64 {
    let model = Model()
    let initial = model.value
    let compute = { => model.value }
    model.value = 9
    if (initial != 1 || compute() != 9) { return 1 }
    println("PASS plain argument snapshots value; explicit closure recomputes current value")
    println("LIMIT no automatic dependency tracking or refresh is provided by trailing lambda")
    return 0
}
