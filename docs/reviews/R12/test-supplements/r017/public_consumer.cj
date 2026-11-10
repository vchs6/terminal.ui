import cjtui.*
main(): Int64 {
    let error = UICleanupException(Exception("PRIMARY"), Array<Exception>())
    println(error.primary.message)
    println(error.cleanupFailures.size)
    return 0
}
