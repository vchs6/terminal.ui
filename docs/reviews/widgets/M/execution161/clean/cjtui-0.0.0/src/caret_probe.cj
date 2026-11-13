package cjtui

// One per device run; the decoder's exact CSI branch is its only report source.
class CaretProbe {
    var status = "not-probed"
    var deadline: Int64 = 0
    var originalVisible = false
    var currentVisible = false
    var managed = false
    var dirty = false
    func begin(now: Int64): Unit {
        if (now < 0 || now > Int64.Max - 600) { status = "unknown-clock"; return }
        deadline = now + 600; status = "pending"
    }
    func check(now: Int64): Unit {
        if (status != "pending") { return }
        if (now < 0) { status = "unknown-clock" }
        else if (now >= deadline) { status = "unknown-timeout" }
    }
    func report(value: Int32): Unit {
        if (status != "pending") { return }
        check(unsafe { cjt_monotonic_ms() })
        if (status != "pending" || (value != 1 && value != 2)) { return }
        originalVisible = value == 1; currentVisible = originalVisible
        status = if (originalVisible) { "original-visible" } else { "original-hidden" }
        dirty = true
    }
    func known(): Bool { status == "original-visible" || status == "original-hidden" }
    func committed(visible: Bool): Unit {
        if (!known()) { return }
        if (visible != currentVisible) { managed = true }
        currentVisible = visible; dirty = false
    }
}
