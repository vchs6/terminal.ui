package acnl.terminal.core

import std.io.InputStream
import std.io.OutputStream
import std.collection.HashSet

public interface AnsiConsole <: OutputStream & InputStream {
    func writeAt(col: Int64, row: Int64, text: String): Unit {
        gotoxy(col, row)
        write(text.toArray())
    }

    func write(text: String): Unit {
        write(text.toArray())
    }

    func write(char: Rune): Unit
    
    func gotoxy(col: Int64, row: Int64): Unit
    func showCursor(value: Bool): Unit
    func setForeground(color: AnsiColor): Unit
    func setBackground(color: AnsiColor): Unit
    func setFontStyles(styles: HashSet<AnsiTextStyle>): Unit
    func setStyles(fg: AnsiColor, bg: AnsiColor, styles: HashSet<AnsiTextStyle>): Unit

    func getEscapeSequence(fg: ?AnsiColor, bg: ?AnsiColor, styles: HashSet<AnsiTextStyle>): String
    func getCursorSetCode(col: Int64, row: Int64): String

    func clear(): Unit
    func reset(): Unit

    prop width: Int64
    prop height: Int64
    prop colorDepth: Byte
}