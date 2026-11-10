package cjtui

class GlyphRenderPolicy {
    let conservative: Bool

    private init(conservative: Bool) {
        this.conservative = conservative
    }

    static func unicode(): GlyphRenderPolicy {
        GlyphRenderPolicy(false)
    }

    static func conservativeUnicode(): GlyphRenderPolicy {
        GlyphRenderPolicy(true)
    }
}
