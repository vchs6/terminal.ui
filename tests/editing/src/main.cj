package editing_contract
import std.env.getVariable

main(): Int64 {
    if (let Some(mode) <- getVariable("CJTUI_EDITING_MODE")) { liveEditing(mode); return 0 }
    publicConstructors()
    controllerLifecycle()
    callbackTransactions()
    sharedSource()
    unicodeTransactions()
    unicodeSeams()
    validationAndHistory()
    validationBoundaries()
    editorPropertyValidation()
    keyboardDefaults()
    keyboardMatrix()
    eventPhaseDefaults()
    eventIntegration()
    clipboardConservative()
    clipboardDefaults()
    frameAndViewport()
    themeFrames()
    exactViewport()
    concurrentSource()
    println("PASS TASK118 public editing contract")
    0
}
