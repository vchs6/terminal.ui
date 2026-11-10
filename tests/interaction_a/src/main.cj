package interaction_a_contract
import std.env.*
main(): Int64 {
    if (getVariable("CJTUI_INTERACTION_A_DEVICE").isSome()) { return deviceConsumer() }
    valuesAndSignatures()
    threeConsumers()
    fullCanvasCells()
    frameAndAncestorClip()
    selectedCascade()
    dependencyIsolation()
    defaultActionTrace()
    defaultActionSnapshot()
    physicalFocus()
    focusRepair()
    focusBindings()
    readonlyQueries()
    contextExpiry()
    caretFrames()
    lifecycleAndLimits()
    pureCallbacks()
    println("PASS: public interaction A consumer")
    return 0
}
