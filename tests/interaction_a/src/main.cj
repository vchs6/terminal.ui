package interaction_a_contract
import std.env.*
main(): Int64 {
    if(let Some(name)<-getVariable("CJTUI_INTERACTION_A_REGRESSION")){return reviewRegression(name)}
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
