package runtime_contract

main(): Int64 {
    constructionAndLifetime()
    collectorRecovery()
    observableBindings()
    replacementAndNotify()
    subscriptionRace()
    schedulerTurns()
    contextsAndLimits()
    routedEvents()
    failureCleanup()
    exportWithoutEffects()
    println("PASS: runtime public A+B contract")
    return 0
}
