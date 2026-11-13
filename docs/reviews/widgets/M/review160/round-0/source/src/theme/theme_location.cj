package cjtui.theme
public struct ThemeLocation {
    public let line: Int64
    public let column: Int64
    public let runeStart: Int64
    public let runeLength: Int64
    public init(line: Int64, column: Int64, runeStart: Int64, runeLength: Int64) {
        this.line = line; this.column = column; this.runeStart = runeStart; this.runeLength = runeLength
    }
}
