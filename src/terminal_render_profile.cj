package cjtui

struct TerminalRenderProfile {
    let colorMode: ColorMode
    let supportsBold: Bool
    let supportsDim: Bool
    let supportsItalic: Bool
    let supportsUnderline: Bool
    let supportsInverse: Bool
    let supportsStrikethrough: Bool
    let noColorVideo: Int64
    init(colorMode!: ColorMode, supportsBold!: Bool = true, supportsDim!: Bool = true, supportsItalic!: Bool = true,
        supportsUnderline!: Bool = true, supportsInverse!: Bool = true, supportsStrikethrough!: Bool = true,
        noColorVideo!: Int64 = -1) {
        this.colorMode = colorMode
        this.supportsBold = supportsBold
        this.supportsDim = supportsDim
        this.supportsItalic = supportsItalic
        this.supportsUnderline = supportsUnderline
        this.supportsInverse = supportsInverse
        this.supportsStrikethrough = supportsStrikethrough
        this.noColorVideo = noColorVideo
    }
}

func snapshotProfile(colorMode: ColorMode): TerminalRenderProfile {
    TerminalRenderProfile(colorMode: colorMode)
}
