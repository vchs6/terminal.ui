package acnl.terminal.core

import std.convert.Parsable
import std.math.round

private func dist(x: (Byte, Byte, Byte), y: (Byte, Byte, Byte)): Int32 {
    let d1 =Int32(x[0] - y[0]) * Int32(x[0] - y[0])
    let d2 =Int32(x[1] - y[1]) * Int32(x[1] - y[1])
    let d3 =Int32(x[2] - y[2]) * Int32(x[2] - y[2])
    d1 + d2 + d3
}

private func nearestCubeIndex(v: Byte): Byte {
    let CUBE: Array<Byte> = [0, 95, 135, 175, 215, 255]
    var (best, dist): (Byte, Int32) = (0, 65535)   // cjlint-ignore !G.VAR.02 description
    for (d in CUBE) {
        let ndist: Int32 = Int32(v - d) * Int32(v - d)
        if (dist > ndist) {
            best = d
            dist = ndist
        }
    }
    best
}

extend Int64 {
    public func toColor(): AnsiColor {
        match(this) {
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
            case _      => if (this < 256) {
                AnsiColor.COLOR256(UInt8(this))
            } else {
                AnsiColor.TRUECOLOR(UInt32(this))
            }
        }
    }
}

public enum AnsiColor <: ToString & Parsable<AnsiColor> & Equatable<AnsiColor> {
    | BLACK            ///<黑色
    | RED              ///<红色
    | GREEN            ///<绿色
    | YELLOW           ///<黄色
    | BLUE             ///<蓝色
    | MAGENTA          ///<品红、桃红
    | CYAN             ///<青色
    | WHITE            ///<白色
    | BRIGHTBLACK      ///<亮黑色
    | BRIGHTRED        ///<亮红色
    | BRIGHTGREEN      ///<亮绿色
    | BRIGHTYELLOW     ///<亮黄色
    | BRIGHTBLUE       ///<亮蓝色
    | BRIGHTMAGENTA    ///<亮品红、亮桃红
    | BRIGHTCYAN       ///<亮青色
    | BRIGHTWHITE      ///<亮白色
    | COLOR256(Byte)   ///8位颜色模式 
    | TRUECOLOR(UInt32)     /// 真彩模式

    public func toString(): String {
        match(this) {
            case BLACK          => "BLACK"        
            case RED            => "RED"          
            case GREEN          => "GREEN"        
            case YELLOW         => "YELLOW"       
            case BLUE           => "BLUE"         
            case MAGENTA        => "MAGENTA"      
            case CYAN           => "CYAN"         
            case WHITE          => "WHITE"        
            case BRIGHTBLACK    => "BRIGHTBLACK"  
            case BRIGHTRED      => "BRIGHTRED"    
            case BRIGHTGREEN    => "BRIGHTGREEN"  
            case BRIGHTYELLOW   => "BRIGHTYELLOW" 
            case BRIGHTBLUE     => "BRIGHTBLUE"   
            case BRIGHTMAGENTA  => "BRIGHTMAGENTA"
            case BRIGHTCYAN     => "BRIGHTCYAN"   
            case BRIGHTWHITE    => "BRIGHTWHITE"
            case COLOR256(x)    => x.toString() 
            case TRUECOLOR(x)   => "#" + x.toString()
        }
    }

    public operator func ==(other: AnsiColor): Bool {
        toString() == other.toString()
    }

    public static func tryParse(value: String): Option<AnsiColor> {
        try {
            parse(value)
        } catch(_) {
            None
        }
    }

    // In class IllegalArgumentException
    public static func parse(value: String): AnsiColor {
        match(value.toAsciiUpper()) {
            case "BLACK"           => BLACK        
            case "RED"             => RED          
            case "GREEN"           => GREEN        
            case "YELLOW"          => YELLOW       
            case "BLUE"            => BLUE         
            case "MAGENTA"         => MAGENTA      
            case "CYAN"            => CYAN         
            case "WHITE"           => WHITE        
            case "BRIGHTBLACK"     => BRIGHTBLACK  
            case "BRIGHTRED"       => BRIGHTRED    
            case "BRIGHTGREEN"     => BRIGHTGREEN  
            case "BRIGHTYELLOW"    => BRIGHTYELLOW 
            case "BRIGHTBLUE"      => BRIGHTBLUE   
            case "BRIGHTMAGENTA"   => BRIGHTMAGENTA
            case "BRIGHTCYAN"      => BRIGHTCYAN   
            case "BRIGHTWHITE"     => BRIGHTWHITE  
            case _ => 
                if (value.startsWith("#")) {
                    TRUECOLOR(UInt32.parse(value[1..value.size]))
                } else if (value.startsWith("(") && value.startsWith(")")) {
                    let vbs = value[1 .. value.size - 1].split(",").map<UInt32>({b => UInt32.parse(b)})
                    TRUECOLOR(vbs[0] << 16 | vbs[1] << 8 | vbs[0])
                } else {
                    COLOR256(UInt8.parse(value))
                }
        }
    }

    public static func fromRGB(r: Byte, g: Byte, b: Byte): AnsiColor {
        return TRUECOLOR( UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b))
    }

    // In class IllegalArgumentException
    public func downgrade(colorDepth!: Byte = 8): AnsiColor {
        match(colorDepth) {
            case 3 => match(this) {
                case BRIGHTBLACK    => BLACK  
                case BRIGHTRED      => RED    
                case BRIGHTGREEN    => GREEN  
                case BRIGHTYELLOW   => YELLOW 
                case BRIGHTBLUE     => BLUE   
                case BRIGHTMAGENTA  => MAGENTA
                case BRIGHTCYAN     => CYAN   
                case BRIGHTWHITE    => WHITE
                case COLOR256(_) | TRUECOLOR(_)    => this.downgrade(colorDepth: 4).downgrade(colorDepth: 3)
                case _              => this
            }
            case 4 => match(this) {
                case TRUECOLOR(_)   => this.downgrade(colorDepth: 8).downgrade(colorDepth: 4)
                case COLOR256(x)    =>
                    var num = Int64(x)
                    if (x >= 232) {
                        num = if(x < 244) { 0 } else if (x < 252) { 8 } else { 15 }
                    } else if (x > 15) {
                        let rgb: Array<Byte> = [(x - 16)/36, (x - 16) % 36 / 6, (x - 16) % 6]
                        let brgb = rgb.map({d => if (d > 2) {1} else {0}})
                        num = (brgb[0] << 2 | brgb[1] << 1 | brgb[2])
                        if (rgb[0] > 4 || rgb[1] > 4 || rgb[2] > 4) {
                            num += 8
                        }                        
                    }
                    num.toColor()
                case _              => this
            }
            case 8 => match(this) {
                case TRUECOLOR(x)   => 
                    let (r, g, b) = (UInt8(x >> 16 & 0xff), UInt8(x >> 8 & 0xff), UInt8(x & 0xff))
                    let (ri, gi, bi) = (nearestCubeIndex(r), nearestCubeIndex(g), nearestCubeIndex(b))
                    let cubeDist = dist((r, g, b), (ri,  gi, bi))
                    var gray = UInt8(round(Float16(((Int32(r) + Int32(g) + Int32(b)) / 3 - 8)) / 10.0))
                    if (gray > 23) { gray = 23 }
                    if (gray < 0) { gray = 0 }
                    let grayVal = 8 + gray * 10
                    let grayDist = dist((r, g, b), (grayVal, grayVal, grayVal))
                    AnsiColor.COLOR256(if (grayDist > cubeDist) { UInt8(16 + 36 * ri + 6 * gi + bi) } else { UInt8(232 + gray)})
                case _              => this
            }
            case _ => throw IllegalArgumentException("Only support 3, 8, 16!")
        }
    }
}