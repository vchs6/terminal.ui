package incremental_invalidation_cache

import cjtui.*

class WorkSample {
    let frame: Frame
    let before: RuntimeStats
    let after: RuntimeStats
    let full: RuntimeStats
    let label: String
    init(frame: Frame, before: RuntimeStats, after: RuntimeStats, full: RuntimeStats, label: String) {
        this.frame = frame; this.before = before; this.after = after; this.full = full; this.label = label
    }
    func noLayout(): Unit {
        check(after.measures == before.measures && after.arranges == before.arranges,
            "${label}: zero measures/arranges expected, got ${after.measures-before.measures}/${after.arranges-before.arranges}")
    }
    func noTarget(): Unit {
        noLayout()
        check(after.paints == before.paints && after.frames == before.frames, "${label}: typed-equal/idle target work")
    }
    func reducedMeasure(): Unit {
        check(after.measures - before.measures < full.measures - after.measures,
            "${label}: changed path must measure fewer nodes than full reference")
    }
    func reducedArrange(): Unit {
        check(after.arranges - before.arranges < full.arranges - after.arranges,
            "${label}: changed path must arrange fewer nodes than full reference")
    }
}
