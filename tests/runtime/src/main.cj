package runtime_contract

import std.env.*

main(): Int64 {
    match (getVariable("CJTUI_RUNTIME_CASE")) {
        case Some("cleanup-context") => cleanupCannotEnterAnotherSession(); return 0
        case Some("owner-render") => ownerRenderFailureDisposes(false); return 0
        case Some("owner-render-cleanup") => ownerRenderFailureDisposes(true); return 0
        case _ => ()
    }
    constructionAndLifetime()
    collectorRecovery()
    observableBindings()
    manualObservableNotification()
    replacementAndNotify()
    subscriptionRace()
    continuousBackgroundUpdates()
    retainedVisibility()
    schedulerTurns()
    contextsAndLimits()
    routedEvents()
    failureCleanup()
    cleanupExceptionPublicContract()
    runtimeCleanupAggregation()
    exportWithoutEffects()
    cleanupCannotEnterAnotherSession()
    ownerRenderFailureDisposes(false)
    ownerRenderFailureDisposes(true)
    println("PASS: runtime public A+B contract")
    return 0
}
