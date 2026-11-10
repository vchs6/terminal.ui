package runtime_contract

main(): Int64 {
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
    println("PASS: runtime public A+B contract")
    return 0
}
