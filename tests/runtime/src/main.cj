package runtime_contract

import std.env.*

main(): Int64 {
    match (getVariable("CJTUI_RUNTIME_CASE")) {
        case Some("post-cross-session") => crossSessionOwnerFailure("post", false); return 0
        case Some("post-cross-session-cleanup") => crossSessionOwnerFailure("post", true); return 0
        case Some("getter-cross-session") => crossSessionOwnerFailure("getter", false); return 0
        case Some("cleanup-same-session") => cleanupSameSessionReentry(); return 0
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
    cleanupSameSessionReentry()
    crossSessionOwnerFailure("post", false)
    crossSessionOwnerFailure("post", true)
    crossSessionOwnerFailure("getter", false)
    println("PASS: runtime public A+B contract")
    return 0
}
