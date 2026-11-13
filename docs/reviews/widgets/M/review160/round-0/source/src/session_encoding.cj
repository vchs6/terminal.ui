package cjtui

import std.collection.ArrayList

// SDK decoding is authoritative; this locator is used only on rejected input.
func invalidSessionUtf8Offset(bytes: Array<UInt8>): Int64 {
    var offset: Int64 = 0
    while (offset < bytes.size) {
        let lead = bytes[offset]
        let count: Int64 = if (lead < 0x80) {
            1
        } else if (lead >= 0xc2 && lead <= 0xdf) {
            2
        } else if (lead >= 0xe0 && lead <= 0xef) {
            3
        } else if (lead >= 0xf0 && lead <= 0xf4) {
            4
        } else {
            0
        }
        if (count == 0 || count > bytes.size - offset) {
            return offset
        }
        try {
            String.fromUtf8(bytes.slice(offset, count))
        } catch (_: IllegalArgumentException) {
            return offset
        }
        offset += count
    }
    -1
}

func validateSessionText(text: String, limit: Int64, title: Bool): (SessionIssue, Int64) {
    let bytes = text.toArray()
    try {
        String.fromUtf8(bytes)
    } catch (_: IllegalArgumentException) {
        return (SessionIssue.InvalidUtf8, invalidSessionUtf8Offset(bytes))
    }
    if (bytes.size > limit) {
        return (SessionIssue.PayloadTooLarge, limit)
    }
    if (title) {
        var offset: Int64 = 0
        for (scalar in text.runes()) {
            let code = UInt32(scalar)
            if (code < 32 || (code >= 127 && code <= 159)) {
                return (SessionIssue.ForbiddenControl, offset)
            }
            offset += String(scalar).size
        }
    }
    (SessionIssue.NoIssue, -1)
}

// Minimal bounded RFC4648 encoder: no wrapping, mandatory padding.
func encodeSessionBase64(bytes: Array<UInt8>): String {
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toArray()
    let output = Array<UInt8>(4 * ((bytes.size + 2) / 3), repeat: 0x3d)
    var source: Int64 = 0
    var target: Int64 = 0
    while (source < bytes.size) {
        let first = UInt32(bytes[source])
        let remaining = bytes.size - source
        let second = if (remaining > 1) {
            UInt32(bytes[source + 1])
        } else {
            0u32
        }
        let third = if (remaining > 2) {
            UInt32(bytes[source + 2])
        } else {
            0u32
        }
        output[target] = alphabet[Int64(first >> 2)]
        output[target + 1] = alphabet[Int64(((first & 3) << 4) | (second >> 4))]
        if (remaining > 1) {
            output[target + 2] = alphabet[Int64(((second & 15) << 2) | (third >> 6))]
        }
        if (remaining > 2) {
            output[target + 3] = alphabet[Int64(third & 63)]
        }
        source += 3
        target += 4
    }
    String.fromUtf8(output)
}

func wrapSessionSequence(inner: String, route: SessionRoute): String {
    match (route) {
        case SessionRoute.Direct => inner
        case SessionRoute.ScreenPassthrough => "\u{1b}P" + inner + "\u{1b}\\"
        case SessionRoute.TmuxPassthrough =>
            let bytes = ArrayList<UInt8>()
            for (byte in inner.toArray()) {
                bytes.add(byte)
                if (byte == 27) {
                    bytes.add(byte)
                }
            }
            "\u{1b}Ptmux;" + String.fromUtf8(bytes.toArray()) + "\u{1b}\\"
    }
}

func sessionPolicyCapability(policy: SessionPolicy, device: Bool, route: SessionRoute, candidate: String): SessionCapability {
    if (!device) {
        return SessionCapability(SessionSupport.Unsupported, SessionBasis.KnownUnavailable, SessionIssue.NoDevice, route,
            candidate)
    }
    match (policy) {
        case SessionPolicy.Auto => SessionCapability(SessionSupport.Unknown, SessionBasis.NoEvidence,
            SessionIssue.NoIssue, route, candidate)
        case SessionPolicy.Disabled => SessionCapability(SessionSupport.Unsupported, SessionBasis.KnownUnavailable,
            SessionIssue.Disabled, route, candidate)
        case SessionPolicy.DeclaredSupported => SessionCapability(SessionSupport.Supported,
            SessionBasis.ExplicitConfiguration, SessionIssue.NoIssue, route, candidate)
    }
}

func createSessionCapabilities(id: Int64, options: SessionOptions, device: Bool): SessionCapabilities {
    SessionCapabilities(id, sessionPolicyCapability(options.clipboard, device, options.route, "osc52-c"),
        sessionPolicyCapability(options.title, device, options.route, "osc2"),
        sessionPolicyCapability(options.titleStack, device, options.route, "xterm-title-stack-window"),
        SessionCapability(SessionSupport.Unsupported, SessionBasis.KnownUnavailable, SessionIssue.NoImageAdapter,
            options.route, "none"))
}
