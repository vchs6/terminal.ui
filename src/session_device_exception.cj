package cjtui

class SessionDeviceException <: Exception {
    init(unsafeOutput: Bool) {
        super(if (unsafeOutput) {
            "terminal write failed; ParserUnsynchronized; visual state not restored"
        } else {
            "terminal write failed"
        })
    }
}
