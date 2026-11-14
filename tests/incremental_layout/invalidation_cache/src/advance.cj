package incremental_invalidation_cache

import cjtui.*

func advance(app: Application, epoch: Array<Int64>, action: () -> Unit): Unit {
    app.batch({ => action(); epoch[0]++ })
}
