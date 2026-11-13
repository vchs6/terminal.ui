package cjtui

class GlyphRenderPolicy {
    let kind: Int64
    private let bitmap: Array<UInt8>
    private init(kind: Int64, bitmap: Array<UInt8>) {
        this.kind = kind
        this.bitmap = bitmap
    }
    static func unicode(): GlyphRenderPolicy { GlyphRenderPolicy(0, []) }
    static func conservativeUnicode(): GlyphRenderPolicy { GlyphRenderPolicy(1, []) }
    static func ascii(): GlyphRenderPolicy { GlyphRenderPolicy(2, []) }
    static func mapped(bitmap: Array<UInt8>): GlyphRenderPolicy {
        if (bitmap.size != 8192) { throw IllegalArgumentException("invalid glyph bitmap") }
        GlyphRenderPolicy(3, Array<UInt8>(bitmap.size, {i => bitmap[i]}))
    }
    func has(code: UInt32): Bool {
        if (kind != 3 || code > 65535) { return false }
        (bitmap[Int64(code / 8)] & (1u8 << Int64(code % 8))) != 0
    }
}
