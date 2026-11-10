package cjtui

public struct TerminalCapabilities {
    public let colorMode: ColorMode
    public let colorKnown: Bool
    public let terminfoKnown: Bool
    public let supportsBold: Bool
    public let supportsDim: Bool
    public let supportsItalic: Bool
    public let supportsUnderline: Bool
    public let supportsInverse: Bool
    public let supportsStrikethrough: Bool
    public let noColorVideo: Int64
    public let source: String
    public let reason: String
    init(colorMode!: ColorMode, colorKnown!: Bool, terminfoKnown!: Bool, supportsBold!: Bool, supportsDim!: Bool,
        supportsItalic!: Bool, supportsUnderline!: Bool, supportsInverse!: Bool, supportsStrikethrough!: Bool,
        noColorVideo!: Int64, source!: String, reason!: String) {
        this.colorMode = colorMode
        this.colorKnown = colorKnown
        this.terminfoKnown = terminfoKnown
        this.supportsBold = supportsBold
        this.supportsDim = supportsDim
        this.supportsItalic = supportsItalic
        this.supportsUnderline = supportsUnderline
        this.supportsInverse = supportsInverse
        this.supportsStrikethrough = supportsStrikethrough
        this.noColorVideo = noColorVideo
        this.source = source
        this.reason = reason
    }
}

private func capabilityBit(bits: Int64, index: Int64): Bool {
    (bits & (Int64(1) << index)) != 0
}

private func capabilityMode(bits: Int64): ColorMode {
    match (bits & 7) {
        case 2 => ColorMode.Basic8
        case 3 => ColorMode.Basic16
        case 4 => ColorMode.Indexed256
        case 5 => ColorMode.TrueColor
        case _ => ColorMode.Monochrome
    }
}

private func capabilityReason(bits: Int64): String {
    match ((bits >> 11) & 31) {
        case 1 => "term-unset"
        case 2 => "term-dumb"
        case 3 => "term-invalid"
        case 4 => "unsupported-platform"
        case 5 => "terminfo-library-unavailable"
        case 6 => "terminfo-symbol-unavailable"
        case 7 => "terminfo-entry-unavailable"
        case 8 => "terminfo-database-unavailable"
        case _ => ""
    }
}

func detectTerminalCapabilities(): TerminalCapabilities {
    let bits = unsafe { cjt_capabilities_detect() }
    let terminfoKnown = capabilityBit(bits, 9)
    let colorTermKnown = capabilityBit(bits, 10)
    let mode = capabilityMode(bits)
    let source = if (terminfoKnown && colorTermKnown) {
        "terminfo+COLORTERM"
    } else if (terminfoKnown) {
        "terminfo"
    } else if (colorTermKnown) {
        "COLORTERM"
    } else {
        "unknown"
    }
    let noColorVideo = if (capabilityBit(bits, 48)) {
        (bits >> 16) & 0xffffffff
    } else {
        -1
    }
    TerminalCapabilities(colorMode: mode, colorKnown: (bits & 7) != 0, terminfoKnown: terminfoKnown,
        supportsBold: capabilityBit(bits, 3), supportsDim: capabilityBit(bits, 4), supportsItalic: capabilityBit(bits, 5),
        supportsUnderline: capabilityBit(bits, 6), supportsInverse: capabilityBit(bits, 7),
        supportsStrikethrough: capabilityBit(bits, 8), noColorVideo: noColorVideo, source: source,
        reason: capabilityReason(bits))
}

func terminalRenderProfile(capabilities: TerminalCapabilities, mode: ColorMode): TerminalRenderProfile {
    TerminalRenderProfile(colorMode: mode, supportsBold: capabilities.supportsBold,
        supportsDim: capabilities.supportsDim, supportsItalic: capabilities.supportsItalic,
        supportsUnderline: capabilities.supportsUnderline, supportsInverse: capabilities.supportsInverse,
        supportsStrikethrough: capabilities.supportsStrikethrough, noColorVideo: capabilities.noColorVideo)
}
