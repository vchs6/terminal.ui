package acnl.terminal.core

import std.convert.Parsable

public enum TBorderStyle <: ToString & Parsable<TBorderStyle> & Equatable<TBorderStyle> {
    | NONE
    | SINGLE
    | DOUBLIE
    | DOTTED
    | DASHED
    | THICK
    | ROUNDED
    | CUSTOM(String)

    public func toString(): String {
        match(this) {
            case SINGLE  => "single"
            case DOUBLIE => "double"
            case DOTTED  => "dotted"
            case DASHED  => "dashed"
            case THICK   => "thick"
            case ROUNDED => "rounded"
            case NONE    => "none"
            case CUSTOM(x)  => "c:" + x.toString()
        }
    }

    public static func tryParse(value: String): Option<TBorderStyle> {
        try {
            parse(value)
        } catch(_) {
            None
        }
    }

    // In class IllegalArgumentException
    public static func parse(value: String): TBorderStyle  {
        let vv = value.toAsciiLower().trimAscii()
        match(vv) {
            case "single"       => SINGLE
            case "double"       => DOUBLIE
            case "dotted"       => DOTTED
            case "dashed"       => DASHED
            case "thick"        => THICK
            case "rounded"      => ROUNDED
            case "" | "none"    => NONE
            case _              => 
                if (vv.startsWith("c:")) {
                    CUSTOM(vv[2 .. vv.size])
                } else {
                    throw IllegalArgumentException()
                }
        }
    }

    public operator func ==(other: TBorderStyle): Bool {
        toString() == other.toString()
    }
}