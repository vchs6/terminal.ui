package acnl.terminal.core

import std.collection.HashSet

private func onSetColor(color: AnsiColor): UInt64 {
    UInt64(match(color) {
        case BLACK          => UInt32(0) | 0x1000000
        case RED            => UInt32(1) | 0x1000000
        case GREEN          => UInt32(2) | 0x1000000
        case YELLOW         => UInt32(3) | 0x1000000
        case BLUE           => UInt32(4) | 0x1000000
        case MAGENTA        => UInt32(5) | 0x1000000
        case CYAN           => UInt32(6) | 0x1000000
        case WHITE          => UInt32(7) | 0x1000000
        case BRIGHTBLACK    => UInt32(8) | 0x1000000
        case BRIGHTRED      => UInt32(9) | 0x1000000
        case BRIGHTGREEN    => UInt32(10) | 0x1000000
        case BRIGHTYELLOW   => UInt32(11) | 0x1000000
        case BRIGHTBLUE     => UInt32(12) | 0x1000000
        case BRIGHTMAGENTA  => UInt32(13) | 0x1000000
        case BRIGHTCYAN     => UInt32(14) | 0x1000000
        case BRIGHTWHITE    => UInt32(15) | 0x1000000
        case COLOR256(x)    => UInt32(x) | 0x2000000
        case TRUECOLOR(x)   => x  | UInt32(0x3000000)
    })
}

private func onGetColor(value: UInt32): Option<AnsiColor> {
    let ct = value >> 24 & 0x0f
    match(ct) {
        case 1 => match(value & 0xffffff) {
            case 0      => BLACK        
            case 1      => RED          
            case 2      => GREEN        
            case 3      => YELLOW       
            case 4      => BLUE         
            case 5      => MAGENTA      
            case 6      => CYAN         
            case 7      => WHITE        
            case 8      => BRIGHTBLACK  
            case 9      => BRIGHTRED    
            case 10     => BRIGHTGREEN  
            case 11     => BRIGHTYELLOW 
            case 12     => BRIGHTBLUE   
            case 13     => BRIGHTMAGENTA
            case 14     => BRIGHTCYAN   
            case 15     => BRIGHTWHITE  
            case _      => None
        }
        case 2 => AnsiColor.COLOR256(UInt8(value & 0xffffff))
        case 3 => AnsiColor.TRUECOLOR(value & 0xffffff)
        case _ => None
    }
}

public struct AnsiStyle <: Equatable<AnsiStyle> {
    private var value: UInt64 = 0

    public init() {

    }

    public init(v: UInt64) {
        value = v
    }

    public func isNone(): Bool {
        value == 0
    }

    public mut prop foreground: Option<AnsiColor> {
        get() {
            let v = UInt32(value & 0x0fffffff)
            onGetColor(v)
        }
        set(v) {
            value &= 0xfffffffff0000000
            if (let Some(color) <- v) {
                value |= UInt64(onSetColor(color))
            }
        }
    }

    public mut prop background: Option<AnsiColor> {
        get() {
            let v = UInt32((value >> 28) & 0x0fffffff)
            onGetColor(v) }
        set(v) {
            value &= 0xf0000000fffffff
            if (let Some(color) <- v) {
                value |= UInt64(onSetColor(color)) << 28
            }
        }
    }

    public func getStyles(): HashSet<AnsiTextStyle> {
        let result = HashSet<AnsiTextStyle>()
        let sv = UInt8(value >> 56 & 0xff)
        if (sv == 0) { return result }
        let xx = Array<Byte>(8, {i => sv >> i & 0x1})
        for (x in xx) {
            match(sv) {
                case 1   => result.add(AnsiTextStyle.ITALIC)
                case 2   => result.add(AnsiTextStyle.BOLD)
                case 4   => result.add(AnsiTextStyle.DELETEDLINE)
                case 8   => result.add(AnsiTextStyle.UNDERLINE)
                case 16  => result.add(AnsiTextStyle.BLINK)
                case 32  => result.add(AnsiTextStyle.REVERSE)
                case 64  => result.add(AnsiTextStyle.FAINT)
                case 128 => result.add(AnsiTextStyle.STRIKETHROUGH)
                case _   => continue
            }
        }
        result
    }

    public mut func setStyle(values: Array<AnsiTextStyle>): Unit {
        var sv: UInt64 = 0
        for(v in values) {
            sv += match(v) {
                case NONE        => 0
                case ITALIC      => 1
                case BOLD        => 2
                case DELETEDLINE => 4
                case UNDERLINE   => 8
                case BLINK       => 16
                case REVERSE     => 32
                case FAINT       => 64
                case STRIKETHROUGH  => 128
            }
        }
        value = value & 0x00ffffffffffffff | sv << 56
    }

    public operator func ==(ot: AnsiStyle): Bool {
        value == ot.value
    }
}
