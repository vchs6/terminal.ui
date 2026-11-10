package session_extensions
import cjtui.*
func repeated(byte: UInt8, count: Int64): String { String.fromUtf8(Array<UInt8>(count, repeat: byte)) }
func wireVectors(app: Application): Unit {
    let vectors = ["", "f", "fo", "foo", "foob", "fooba", "foobar", "中😀e\u{301}", "\u{0}\u{1b}\r\n\t\u{7f}\u{85}"]
    for (i in 0..vectors.size) { result("copy.${i}", app.copyLocalText(vectors[i])) }
    result("title.empty", app.setHostTitle(""))
    result("title.unicode", app.setHostTitle("中😀e\u{301}"))
    result("icon.empty", app.setHostImageIcon(Array<UInt8>()))
    app.stop()
}
func boundaries(app: Application): Unit {
    for (n in [65535, 65536, 65537]) { result("copy.${n}", app.copyLocalText(repeated(0x61, n))) }
    for (n in [1023, 1024, 1025]) { result("title.${n}", app.setHostTitle(repeated(0x61, n))) }
    // Exactly 65536 bytes, 16384 astral scalars. UTF8 bytes, not rune count.
    let fourBytes: Array<UInt8> = [0xf0, 0x9f, 0x98, 0x80]
    let astral = String.fromUtf8(Array<UInt8>(65536, { i => fourBytes[i % 4] }))
    result("copy.astral", app.copyLocalText(astral))
    let twoBytes: Array<UInt8> = [0xc3, 0xa9]
    result("title.multibyte", app.setHostTitle(String.fromUtf8(Array<UInt8>(1024, { i => twoBytes[i % 2] }))))
    for (n in [1048575, 1048576, 1048577]) { result("icon.${n}", app.setHostImageIcon(Array<UInt8>(n, repeat: 0))) }
    app.stop()
}
func invalidInputs(app: Application): Unit {
    let invalid: Array<Array<UInt8>> = [[0xff], [0x80], [0xc0, 0xaf], [0xe0, 0x80, 0x80], [0xed, 0xa0, 0x80], [0xf0, 0x80, 0x80, 0x80], [0xf4, 0x90, 0x80, 0x80], [0xe2, 0x82], [0xe2, 0x28, 0xa1]]
    for (i in 0..invalid.size) {
        let bytes = invalid[i]
        let text = "é" + unsafe { String.fromUtf8Unchecked(bytes) }
        result("invalid.copy.${i}", app.copyLocalText(text))
        result("invalid.title.${i}", app.setHostTitle(text))
    }
    for (n in 0..32) {
        result("control.${n}", app.setHostTitle("é" + String.fromUtf8([UInt8(n)])))
    }
    result("control.127", app.setHostTitle("é" + String.fromUtf8([0x7f])))
    for (n in 128..160) {
        result("control.${n}", app.setHostTitle("é" + String.fromUtf8([0xc2, UInt8(n)])))
    }
    result("precedence.invalid.large", app.copyLocalText(repeated(0x61, 65536) + unsafe { String.fromUtf8Unchecked([0xff]) }))
    result("precedence.title.both", app.setHostTitle("\u{1b}" + repeated(0x61, 1024)))
    result("precedence.large", app.copyLocalText(repeated(0x61, 65537)))
    result("precedence.title.large", app.setHostTitle(repeated(0x61, 1025)))
    result("precedence.icon.large", app.setHostImageIcon(Array<UInt8>(1048577, repeat: 0)))
}
