package ansi_probe
import ansies.api.{Color, Cursor}
import ansies.core.AnsiColor
main(): Int64 {
    if (Color.foreground(AnsiColor.Red) != "\u{1b}[31m" || Cursor.to(2, 3) != "\u{1b}[2;3H") { return 1 }
    println("PASS ansies SGR red and cursor-position sequence generation (no device output)")
    return 0
}
