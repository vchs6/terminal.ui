package incremental_invalidation_cache

import cjtui.*

func describeColor(value: Color): String {
    match (value) {
        case Color.Default => "Default"
        case Color.Black => "Black"
        case Color.Red => "Red"
        case Color.Green => "Green"
        case Color.Yellow => "Yellow"
        case Color.Blue => "Blue"
        case Color.Magenta => "Magenta"
        case Color.Cyan => "Cyan"
        case Color.White => "White"
        case Color.BrightBlack => "BrightBlack"
        case Color.BrightRed => "BrightRed"
        case Color.BrightGreen => "BrightGreen"
        case Color.BrightYellow => "BrightYellow"
        case Color.BrightBlue => "BrightBlue"
        case Color.BrightMagenta => "BrightMagenta"
        case Color.BrightCyan => "BrightCyan"
        case Color.BrightWhite => "BrightWhite"
        case Color.Indexed(index) => "Indexed(${index})"
        case Color.Rgb(r, g, b) => "Rgb(${r},${g},${b})"
    }
}
