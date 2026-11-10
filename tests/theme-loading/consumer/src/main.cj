package theme_loading_contract
main(args:Array<String>): Int64 {
    let env=TestEnvironment(args[1])
    match(args[0]) {
        case "lifecycle" => inactiveAndRestart(env)
        case "session-fence" => oldSessionCannotCommitAfterRestart(env)
        case "queued-restart" => uncommittedIntentClosesBeforeRestart(env)
        case "latest-success" => latestSuccessfulRequest(env)
        case "candidate-order" => newestIntentWinsBeforeAnyUiTurn(env)
        case "latest-failure" => latestFailureDoesNotReviveOld(env)
        case "pending-bound" => onlyLatestPendingFileIsRead(env)
        case "post-capacity" => commitMailboxSurvivesFullPostQueue(env)
        case "atomic-caches" => atomicCandidateValidationUsesCaches(env)
        case "reload-origin" => reloadUsesAcceptedFrozenOrigin(env)
        case "relative-origin" => relativeOriginFreezesAtRequest(env)
        case "observability" => resultAndInfoAreObservable(env)
        case "event-post" => eventAndPostMayLoadTheme(env)
        case "multi-application" => applicationsHaveIndependentLoaders(env)
        case "getter-reentry" => loadingDuringGetterIsRejected(env)
        case "build-reentry" => loadingDuringBuildIsRejected(env)
        case "synchronous-values" => synchronousValuesDoNotMutateApplication(env)
        case "exception-boundary" => applicationExceptionDoesNotRollbackAcceptedTheme(env)
        case "current-cache" => candidateValidatesLatestDeclarationCache(env)
        case "background-race" => backgroundRequestsHaveOneTotalOrder(env)
        case "cleanup" => cleanupFailureStillClosesPendingRequests(env)
        case "recoverable" => recoverableFailuresKeepAcceptedTheme(env)
        case _ => throw Exception("unknown test case ${args[0]}")
    }
    println("PASS CASE ${args[0]}")
    0
}
