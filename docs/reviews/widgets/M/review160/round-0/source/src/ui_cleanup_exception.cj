package cjtui

import std.collection.ArrayList

func cleanupPrimary(error: Exception): Exception {
    if (let Some(aggregate) <- (error as UICleanupException)) { return cleanupPrimary(aggregate.primary) }
    error
}

func appendFlattenedFailure(result: ArrayList<Exception>, error: Exception): Unit {
    if (let Some(aggregate) <- (error as UICleanupException)) {
        appendFlattenedFailure(result, aggregate.primary)
        for (additional in aggregate.cleanupFailures) { appendFlattenedFailure(result, additional) }
    } else { result.add(error) }
}

func cleanupExtras(primary: Exception, additional: Array<Exception>): Array<Exception> {
    let all = ArrayList<Exception>()
    if (let Some(aggregate) <- (primary as UICleanupException)) {
        for (error in aggregate.cleanupFailures) { appendFlattenedFailure(all, error) }
    }
    for (error in additional) { appendFlattenedFailure(all, error) }
    all.toArray()
}

func cleanupDescription(primary: Exception, additional: Array<Exception>): String {
    let first = cleanupPrimary(primary)
    let extras = cleanupExtras(primary, additional)
    var description = first.message
    for (error in extras) { description += "; ${error.message}" }
    "${description}; additional cleanup failures: ${extras.size}"
}

public class UICleanupException <: Exception {
    public let primary: Exception
    private let extras: Array<Exception>

    public init(primary: Exception, cleanupFailures: Array<Exception>) {
        super(cleanupDescription(primary, cleanupFailures))
        this.primary = cleanupPrimary(primary)
        extras = cleanupExtras(primary, cleanupFailures)
    }

    public prop cleanupFailures: Array<Exception> {
        get() { Array<Exception>(extras.size, { index => extras[index] }) }
    }
}

func aggregateCleanup(primary: Exception, extra: Exception): Exception {
    UICleanupException(primary, [extra])
}
