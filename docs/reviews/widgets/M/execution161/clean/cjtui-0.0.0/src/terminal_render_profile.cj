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
    let glyphPolicy: GlyphRenderPolicy
    init(colorMode!: ColorMode, supportsBold!: Bool = true, supportsDim!: Bool = true, supportsItalic!: Bool = true,
        supportsUnderline!: Bool = true, supportsInverse!: Bool = true, supportsStrikethrough!: Bool = true,
        noColorVideo!: Int64 = -1, glyphPolicy!: GlyphRenderPolicy = GlyphRenderPolicy.unicode()) {
        this.colorMode = colorMode
        this.supportsBold = supportsBold
        this.supportsDim = supportsDim
        this.supportsItalic = supportsItalic
        this.supportsUnderline = supportsUnderline
        this.supportsInverse = supportsInverse
        this.supportsStrikethrough = supportsStrikethrough
        this.noColorVideo = noColorVideo
        this.glyphPolicy = glyphPolicy
    }
}

func snapshotProfile(colorMode: ColorMode): TerminalRenderProfile {
    TerminalRenderProfile(colorMode: colorMode)
}
