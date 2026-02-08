package acnl.terminal.consoles

import std.env.getStdIn
import std.env.getStdOut
import std.collection.{HashSet, ArrayList}

import acnl.terminal.core.AnsiConsole
import acnl.terminal.core.AnsiColor
import acnl.terminal.core.AnsiTextStyle

public open class TAnsiConsole <: AnsiConsole {
    private static let CSI = "\u{1b}["
    private static let WRITER = getStdOut()
    private static let READER = getStdIn()

    public init() {

    }

    public static func getForegroundCode(color: AnsiColor): String {
        match(color) {
            case BLACK          => "30"        
            case RED            => "31"          
            case GREEN          => "32"        
            case YELLOW         => "33"       
            case BLUE           => "34"         
            case MAGENTA        => "35"      
            case CYAN           => "36"         
            case WHITE          => "37"        
            case BRIGHTBLACK    => "90"  
            case BRIGHTRED      => "91"    
            case BRIGHTGREEN    => "92"  
            case BRIGHTYELLOW   => "93" 
            case BRIGHTBLUE     => "94"   
            case BRIGHTMAGENTA  => "95"
            case BRIGHTCYAN     => "96"   
            case BRIGHTWHITE    => "97"
            case COLOR256(x)    => "38;5;" + x.toString() 
            case TRUECOLOR(x)   =>
                let (r, g, b) = (UInt8(x >> 16 & 0xff), UInt8(x >> 8 & 0xff), UInt8(x))
                "38;2;" + r.toString() + ";" + g.toString() + ";" + b.toString()
        }
    }

    public static func getBackgroundCode(color: AnsiColor): String {
        match(color) {
            case BLACK          => "40"        
            case RED            => "41"          
            case GREEN          => "42"        
            case YELLOW         => "43"       
            case BLUE           => "44"         
            case MAGENTA        => "45"      
            case CYAN           => "46"         
            case WHITE          => "47"        
            case BRIGHTBLACK    => "100"  
            case BRIGHTRED      => "101"    
            case BRIGHTGREEN    => "102"  
            case BRIGHTYELLOW   => "103" 
            case BRIGHTBLUE     => "104"   
            case BRIGHTMAGENTA  => "105"
            case BRIGHTCYAN     => "106"   
            case BRIGHTWHITE    => "107"
            case COLOR256(x)    => "48;5;" + x.toString() 
            case TRUECOLOR(x)   =>
                let (r, g, b) = (UInt8(x >> 16 & 0xff), UInt8(x >> 8 & 0xff), UInt8(x))
                "48;2;" + r.toString() + ";" + g.toString() + ";" + b.toString()
        }
    }

    /*cjlint-ignore -start !G.VAR.02 description */
    public static func getStylesCode(styles: HashSet<AnsiTextStyle>): String {
        var mode: String = ""
        for (style in styles) {
            let m: String = match(style) {
                case NONE        => ""
                case ITALIC      => "3"
                case BOLD        => "1"
                case DELETEDLINE    => "9"
                case STRIKETHROUGH  => "9"
                case UNDERLINE   => "4"
                case BLINK       => "5"
                case REVERSE     => "7"
                case FAINT       => "2"
            }
            if (m != "") {
                mode += if (mode != "") {";"} else {""} + m
            }
        }
        mode
    }
    /* cjlint-ignore -end description */

    public func getEscapeSequence(fg: ?AnsiColor, bg: ?AnsiColor, styles: HashSet<AnsiTextStyle>): String {
        var strs = ArrayList<String>()
        if (let Some(color) <- fg) {
            strs.add(getForegroundCode(color))
        }
        if (let Some(color) <- bg) {
            strs.add(getBackgroundCode(color))
        }

        let ss = getStylesCode(styles)
        if (ss != "") { strs.add(ss) }
        if (strs.size == 0) { return "" }
        CSI + String.join(strs.toArray(), delimiter: ";") + "m"
    }

    public func getCursorSetCode(col: Int64, row: Int64): String {
        CSI + "${row};${col}H"
    }

    public func write(buffer: Array<Byte>): Unit {
        WRITER.write(buffer)
        WRITER.flush()
    }

     public func write(char: Rune): Unit {
        WRITER.write(char)
    }

    public func read(buffer: Array<Byte>): Int64 {
        READER.read(buffer)
    }

    public func gotoxy(col: Int64, row: Int64): Unit {
        WRITER.write(CSI + "${row};${col}H")
    }

    public func showCursor(value: Bool): Unit {
        WRITER.write(CSI + "?25" + if (value) {"h"} else {"l"} )
    }

    public func setForeground(color: AnsiColor): Unit {
        let mode = getForegroundCode(color)
        WRITER.write(CSI + mode + "m")
    }

    public func setBackground(color: AnsiColor): Unit {
        let mode = getBackgroundCode(color)
        WRITER.write(CSI + mode + "m")
    }

    public func setFontStyles(styles: HashSet<AnsiTextStyle>): Unit {
        let mode = getStylesCode(styles)
        if (mode != "") { WRITER.write(CSI + mode + "m") }
    }

    public func setStyles(fg: AnsiColor, bg: AnsiColor, styles: HashSet<AnsiTextStyle>): Unit {
        WRITER.write(getEscapeSequence(fg, bg, styles))
    }

    public func clear(): Unit {
        WRITER.write(CSI + "2J")
    }

    public func reset(): Unit {
        WRITER.write(CSI + "0m" + CSI + "H")
    }
    
    public prop width: Int64 {
        get() {
            640
        }
    }

    public prop height: Int64 {
        get() {
            480
        }
    }

    public prop colorDepth: Byte {
        get() {
            8
        }
    }
}