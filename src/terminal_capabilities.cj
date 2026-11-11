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

// Packed ABI layout is documented in design D031–D033.
private let capModeMask: Int64 = 7
private let capModeBasic8: Int64 = 2
private let capModeBasic16: Int64 = 3
private let capModeIndexed256: Int64 = 4
private let capModeTrueColor: Int64 = 5
private let capBoldBit: Int64 = 3
private let capDimBit: Int64 = 4
private let capItalicBit: Int64 = 5
private let capUnderlineBit: Int64 = 6
private let capInverseBit: Int64 = 7
private let capStrikeBit: Int64 = 8
private let capTerminfoBit: Int64 = 9
private let capColorTermBit: Int64 = 10
private let capReasonShift: Int64 = 11
private let capReasonMask: Int64 = 31
private let capNcvShift: Int64 = 16
private let capNcvMask: Int64 = 0xffffffff
private let capNcvPresentBit: Int64 = 48
private let capReasonUnset: Int64 = 1
private let capReasonDumb: Int64 = 2
private let capReasonInvalid: Int64 = 3
private let capReasonPlatform: Int64 = 4
private let capReasonLibrary: Int64 = 5
private let capReasonSymbol: Int64 = 6
private let capReasonEntry: Int64 = 7
private let capReasonDatabase: Int64 = 8

private func capabilityBit(bits: Int64, index: Int64): Bool {
    (bits & (Int64(1) << index)) != 0
}

private func capabilityMode(bits: Int64): ColorMode {
    let mode = bits & capModeMask
    if (mode == capModeBasic8) { return ColorMode.Basic8 }
    if (mode == capModeBasic16) { return ColorMode.Basic16 }
    if (mode == capModeIndexed256) { return ColorMode.Indexed256 }
    if (mode == capModeTrueColor) { return ColorMode.TrueColor }
    ColorMode.Monochrome
}

private func capabilityReason(bits: Int64): String {
    let reason = (bits >> capReasonShift) & capReasonMask
    if (reason == capReasonUnset) { return "term-unset" }
    if (reason == capReasonDumb) { return "term-dumb" }
    if (reason == capReasonInvalid) { return "term-invalid" }
    if (reason == capReasonPlatform) { return "unsupported-platform" }
    if (reason == capReasonLibrary) { return "terminfo-library-unavailable" }
    if (reason == capReasonSymbol) { return "terminfo-symbol-unavailable" }
    if (reason == capReasonEntry) { return "terminfo-entry-unavailable" }
    if (reason == capReasonDatabase) { return "terminfo-database-unavailable" }
    ""
}

func detectTerminalCapabilities(): TerminalCapabilities {
    let bits = unsafe { cjt_capabilities_detect() }
    let terminfoKnown = capabilityBit(bits, capTerminfoBit)
    let colorTermKnown = capabilityBit(bits, capColorTermBit)
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
    let noColorVideo = if (capabilityBit(bits, capNcvPresentBit)) {
        (bits >> capNcvShift) & capNcvMask
    } else {
        -1
    }
    TerminalCapabilities(colorMode: mode, colorKnown: (bits & capModeMask) != 0, terminfoKnown: terminfoKnown,
        supportsBold: capabilityBit(bits, capBoldBit), supportsDim: capabilityBit(bits, capDimBit), supportsItalic: capabilityBit(bits, capItalicBit),
        supportsUnderline: capabilityBit(bits, capUnderlineBit), supportsInverse: capabilityBit(bits, capInverseBit),
        supportsStrikethrough: capabilityBit(bits, capStrikeBit), noColorVideo: noColorVideo, source: source,
        reason: capabilityReason(bits))
}

func terminalRenderProfile(capabilities: TerminalCapabilities, mode: ColorMode,
    glyphPolicy!: GlyphRenderPolicy = GlyphRenderPolicy.conservativeUnicode()): TerminalRenderProfile {
    TerminalRenderProfile(colorMode: mode, supportsBold: capabilities.supportsBold,
        supportsDim: capabilities.supportsDim, supportsItalic: capabilities.supportsItalic,
        supportsUnderline: capabilities.supportsUnderline, supportsInverse: capabilities.supportsInverse,
        supportsStrikethrough: capabilities.supportsStrikethrough, noColorVideo: capabilities.noColorVideo,
        glyphPolicy: glyphPolicy)
}
