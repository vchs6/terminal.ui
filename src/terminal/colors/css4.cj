package acnl.terminal.colors

import std.collection.HashMap

import acnl.terminal.core.AnsiColor

public struct CSS4 {
    private static let COLORMAP: HashMap<String, (Byte, Byte, Byte)> = HashMap<String, (Byte, Byte, Byte)>([
        ("ALICEBLUE", (0,248,255)),
        ("ANTIQUEWHITE", (10,235,215)),
        ("AQUA", (0,255,255)),
        ("AQUAMARINE", (127,255,212)),
        ("AZURE", (0,255,255)),
        ("BEIGE", (5,245,220)),
        ("BISQUE", (15,228,196)),
        ("BLACK", (0,0,0)),
        ("BLANCHEDALMOND", (255,255,205)),
        ("BLUE", (0,0,255)),
        ("BLUEVIOLET", (10,43,226)),
        ("BROWN", (165,42,42)),
        ("BURLYWOOD", (14,184,135)),
        ("CADETBLUE", (15,158,160)),
        ("CHARTREUSE", (15,255,0)),
        ("CHOCOLATE", (2,105,30)),
        ("CORAL", (15,127,80)),
        ("CORNFLOWERBLUE", (4,149,237)),
        ("CORNSILK", (15,248,220)),
        ("CRIMSON", (12,20,60)),
        ("CYAN", (0,255,255)),
        ("DARKBLUE", (0,0,139)),
        ("DARKCYAN", (0,139,139)),
        ("DARKGOLDENROD", (8,134,11)),
        ("DARKGRAY", (9,169,169)),
        ("DARKGREEN", (0,100,0)),
        ("DARKKHAKI", (13,183,107)),
        ("DARKMAGENTA", (11,0,139)),
        ("DARKOLIVEGREEN", (5,107,47)),
        ("DARKORANGE", (15,140,0)),
        ("DARKORCHID", (9,50,204)),
        ("DARKRED", (11,0,0)),
        ("DARKSALMON", (9,150,122)),
        ("DARKSEAGREEN", (15,188,143)),
        ("DARKSLATEBLUE", (8,61,139)),
        ("DARKSLATEGRAY", (15,79,79)),
        ("DARKTURQUOISE", (0,206,209)),
        ("DARKVIOLET", (4,0,211)),
        ("DEEPPINK", (255,20,147)),
        ("DEEPSKYBLUE", (0,191,255)),
        ("DIMGRAY", (105,105,105)),
        ("DODGERBLUE", (30,144,255)),
        ("FIREBRICK", (2,34,34)),
        ("FLORALWHITE", (15,250,240)),
        ("FORESTGREEN", (2,139,34)),
        ("FUCHSIA", (15,0,255)),
        ("GAINSBORO", (12,220,220)),
        ("GHOSTWHITE", (8,248,255)),
        ("GOLD", (15,215,0)),
        ("GOLDENROD", (10,165,32)),
        ("GRAY", (0,128,128)),
        ("GREEN", (0,128,0)),
        ("GREENYELLOW", (13,255,47)),
        ("HONEYDEW", (0,255,240)),
        ("HOTPINK", (15,105,180)),
        ("INDIANRED", (13,92,92)),
        ("INDIGO", (11,0,130)),
        ("KHAKI", (0,213,140)),
        ("LAVENDER", (6,230,250)),
        ("LAVENDERBLUSH", (15,240,245)),
        ("LAWNGREEN", (12,252,0)),
        ("LEMONCHIFFON", (15,250,205)),
        ("LIGHTBLUE", (173,216,230)),
        ("LIGHTCORAL", (240,128,128)),
        ("LIGHTCYAN", (224,255,255)),
        ("LIGHTGOLDENROD_YELLOW", (250,250,210)),
        ("LIGHTGREEN", (144,238,144)),
        ("LIGHTGREY", (211,211,211)),
        ("LIGHTPINK", (255,182,193)),
        ("LIGHTSALMON", (255,160,122)),
        ("LIGHTSEAGREEN", (0,178,170)),
        ("LIGHTSKYBLUE", (135,206,250)),
        ("LIGHTSLATEGRAY", (119,136,153)),
        ("LIGHTSTEELBLUE", (176,196,222)),
        ("LIGHTYELLOW", (15,255,224)),
        ("LIME", (0,255,0)),
        ("LIMEGREEN", (50,205,50)),
        ("LINEN", (10,240,230)),
        ("MAGENTA", (255,0,255)),
        ("MAROON", (0,0,0)),
        ("MEDIUMAQUAMARINE", (102,205,170)),
        ("MEDIUMBLUE", (0,0,205)),
        ("MEDIUMORCHID", (186,85,211)),
        ("MEDIUMPURPLE", (147,112,219)),
        ("MEDIUMSEAGREEN", (60,179,113)),
        ("MEDIUMSLATEBLUE", (123,104,238)),
        ("MEDIUMSPRINGGREEN", (0,250,154)),
        ("MEDIUMTURQUOISE", (72,209,204)),
        ("MEDIUMVIOLETRED", (199,19,133)),
        ("MIDNIGHTBLUE", (25,25,112)),
        ("MINTCREAM", (245,255,250)),
        ("MISTYROSE", (255,228,225)),
        ("MOCCASIN", (255,228,181)),
        ("NAVAJOWHITE", (255,222,173)),
        ("NAVY", (0,0,128)),
        ("OLDLACE", (253,245,230)),
        ("OLIVE", (128,128,0)),
        ("OLIVEDRAB", (11,142,35)),
        ("ORANGE", (255,165,0)),
        ("ORANGERED", (255,69,0)),
        ("ORCHID", (218,112,214)),
        ("PALEGOLDENROD", (238,232,170)),
        ("PALEGREEN", (152,251,152)),
        ("PALETURQUOISE", (175,238,238)),
        ("PALEVIOLETRED", (219,112,147)),
        ("PAPAYAWHIP", (255,239,213)),
        ("PEACHPUFF", (255,239,213)),
        ("PERU", (205,133,63)),
        ("PINK", (255,192,203)),
        ("PLUM", (221,160,221)),
        ("POWDERBLUE", (176,224,230)),
        ("PURPLE", (128,0,128)),
        ("REBECCAPURPLE", (102,51,153)),
        ("RED", (255,0,0)),
        ("ROSYBROWN", (188,143,143)),
        ("ROYALBLUE", (65,105,225)),
        ("SADDLEBROWN", (139,69,19)),
        ("SALMON", (250,128,114)),
        ("SANDYBROWN", (244,164,96)),
        ("SEAGREEN", (46,139,87)),
        ("SEASHELL", (255,245,238)),
        ("SIENNA", (160,82,45)),
        ("SILVER", (192,192,192)),
        ("SKYBLUE", (135,206,235)),
        ("SLATEBLUE", (106,90,205)),
        ("SLATEGRAY", (112,128,144)),
        ("SNOW", (255,250,250)),
        ("SPRINGGREEN", (0,255,127)),
        ("STEELBLUE", (70,130,180)),
        ("TAN", (210,180,140)),
        ("TEAL", (0,128,128)),
        ("THISTLE", (216,191,216)),
        ("TOMATO", (255,99,71)),
        ("TURQUOISE", (64,224,208)),
        ("VIOLET", (238,130,238)),
        ("WHEAT", (245,222,179)),
        ("WHITE", (255,255,255)),
        ("WHITESMOKE", (245,245,245)),
        ("YELLOW", (255,255,0)),
        ("YELLOWGREEN", (154,205,50))
    ])

    public static func getColorFromName(name: String): AnsiColor {
        let rgb = COLORMAP[name.toAsciiUpper()]
        AnsiColor.TRUECOLOR(UInt32(rgb[0]) << 16 | UInt32(rgb[1]) << 8 | UInt32(rgb[2]))
    }
    
    public static let ALICEBLUE: AnsiColor = getColorFromName("ALICEBLUE")
    public static let ANTIQUEWHITE: AnsiColor = getColorFromName("ANTIQUEWHITE")
    public static let AQUA: AnsiColor = getColorFromName("AQUA")
    public static let AQUAMARINE: AnsiColor = getColorFromName("AQUAMARINE")
    public static let AZURE: AnsiColor = getColorFromName("AZURE")
    public static let BEIGE: AnsiColor = getColorFromName("BEIGE")
    public static let BISQUE: AnsiColor = getColorFromName("BISQUE")
    public static let BLACK: AnsiColor = getColorFromName("BLACK")
    public static let BLANCHEDALMOND: AnsiColor = getColorFromName("BLANCHEDALMOND")
    public static let BLUE: AnsiColor = getColorFromName("BLUE")
    public static let BLUEVIOLET: AnsiColor = getColorFromName("BLUEVIOLET")
    public static let BROWN: AnsiColor = getColorFromName("BROWN")
    public static let BURLYWOOD: AnsiColor = getColorFromName("BURLYWOOD")
    public static let CADETBLUE: AnsiColor = getColorFromName("CADETBLUE")
    public static let CHARTREUSE: AnsiColor = getColorFromName("CHARTREUSE")
    public static let CHOCOLATE: AnsiColor = getColorFromName("CHOCOLATE")
    public static let CORAL: AnsiColor = getColorFromName("CORAL")
    public static let CORNFLOWERBLUE: AnsiColor = getColorFromName("CORNFLOWERBLUE")
    public static let CORNSILK: AnsiColor = getColorFromName("CORNSILK")
    public static let CRIMSON: AnsiColor = getColorFromName("CRIMSON")
    public static let CYAN: AnsiColor = getColorFromName("CYAN")
    public static let DARKBLUE: AnsiColor = getColorFromName("DARKBLUE")
    public static let DARKCYAN: AnsiColor = getColorFromName("DARKCYAN")
    public static let DARKGOLDENROD: AnsiColor = getColorFromName("DARKGOLDENROD")
    public static let DARKGRAY: AnsiColor = getColorFromName("DARKGRAY")
    public static let DARKGREEN: AnsiColor = getColorFromName("DARKGREEN")
    public static let DARKKHAKI: AnsiColor = getColorFromName("DARKKHAKI")
    public static let DARKMAGENTA: AnsiColor = getColorFromName("DARKMAGENTA")
    public static let DARKOLIVEGREEN: AnsiColor = getColorFromName("DARKOLIVEGREEN")
    public static let DARKORANGE: AnsiColor = getColorFromName("DARKORANGE")
    public static let DARKORCHID: AnsiColor = getColorFromName("DARKORCHID")
    public static let DARKRED: AnsiColor = getColorFromName("DARKRED")
    public static let DARKSALMON: AnsiColor = getColorFromName("DARKSALMON")
    public static let DARKSEAGREEN: AnsiColor = getColorFromName("DARKSEAGREEN")
    public static let DARKSLATEBLUE: AnsiColor = getColorFromName("DARKSLATEBLUE")
    public static let DARKSLATEGRAY: AnsiColor = getColorFromName("DARKSLATEGRAY")
    public static let DARKTURQUOISE: AnsiColor = getColorFromName("DARKTURQUOISE")
    public static let DARKVIOLET: AnsiColor = getColorFromName("DARKVIOLET")
    public static let DEEPPINK: AnsiColor = getColorFromName("DEEPPINK")
    public static let DEEPSKYBLUE: AnsiColor = getColorFromName("DEEPSKYBLUE")
    public static let DIMGRAY: AnsiColor = getColorFromName("DIMGRAY")
    public static let DODGERBLUE: AnsiColor = getColorFromName("DODGERBLUE")
    public static let FIREBRICK: AnsiColor = getColorFromName("FIREBRICK")
    public static let FLORALWHITE: AnsiColor = getColorFromName("FLORALWHITE")
    public static let FORESTGREEN: AnsiColor = getColorFromName("FORESTGREEN")
    public static let FUCHSIA: AnsiColor = getColorFromName("FUCHSIA")
    public static let GAINSBORO: AnsiColor = getColorFromName("GAINSBORO")
    public static let GHOSTWHITE: AnsiColor = getColorFromName("GHOSTWHITE")
    public static let GOLD: AnsiColor = getColorFromName("GOLD")
    public static let GOLDENROD: AnsiColor = getColorFromName("GOLDENROD")
    public static let GRAY: AnsiColor = getColorFromName("GRAY")
    public static let GREEN: AnsiColor = getColorFromName("GREEN")
    public static let GREENYELLOW: AnsiColor = getColorFromName("GREENYELLOW")
    public static let HONEYDEW: AnsiColor = getColorFromName("HONEYDEW")
    public static let HOTPINK: AnsiColor = getColorFromName("HOTPINK")
    public static let INDIANRED: AnsiColor = getColorFromName("INDIANRED")
    public static let INDIGO: AnsiColor = getColorFromName("INDIGO")
    public static let KHAKI: AnsiColor = getColorFromName("KHAKI")
    public static let LAVENDER: AnsiColor = getColorFromName("LAVENDER")
    public static let LAVENDERBLUSH: AnsiColor = getColorFromName("LAVENDERBLUSH")
    public static let LAWNGREEN: AnsiColor = getColorFromName("LAWNGREEN")
    public static let LEMONCHIFFON: AnsiColor = getColorFromName("LEMONCHIFFON")
    public static let LIGHTBLUE: AnsiColor = getColorFromName("LIGHTBLUE")
    public static let LIGHTCORAL: AnsiColor = getColorFromName("LIGHTCORAL")
    public static let LIGHTCYAN: AnsiColor = getColorFromName("LIGHTCYAN")
    public static let LIGHTGOLDENROD_YELLOW: AnsiColor = getColorFromName("LIGHTGOLDENROD_YELLOW")
    public static let LIGHTGREEN: AnsiColor = getColorFromName("LIGHTGREEN")
    public static let LIGHTGREY: AnsiColor = getColorFromName("LIGHTGREY")
    public static let LIGHTPINK: AnsiColor = getColorFromName("LIGHTPINK")
    public static let LIGHTSALMON: AnsiColor = getColorFromName("LIGHTSALMON")
    public static let LIGHTSEAGREEN: AnsiColor = getColorFromName("LIGHTSEAGREEN")
    public static let LIGHTSKYBLUE: AnsiColor = getColorFromName("LIGHTSKYBLUE")
    public static let LIGHTSLATEGRAY: AnsiColor = getColorFromName("LIGHTSLATEGRAY")
    public static let LIGHTSTEELBLUE: AnsiColor = getColorFromName("LIGHTSTEELBLUE")
    public static let LIGHTYELLOW: AnsiColor = getColorFromName("LIGHTYELLOW")
    public static let LIME: AnsiColor = getColorFromName("LIME")
    public static let LIMEGREEN: AnsiColor = getColorFromName("LIMEGREEN")
    public static let LINEN: AnsiColor = getColorFromName("LINEN")
    public static let MAGENTA: AnsiColor = getColorFromName("MAGENTA")
    public static let MAROON: AnsiColor = getColorFromName("MAROON")
    public static let MEDIUMAQUAMARINE: AnsiColor = getColorFromName("MEDIUMAQUAMARINE")
    public static let MEDIUMBLUE: AnsiColor = getColorFromName("MEDIUMBLUE")
    public static let MEDIUMORCHID: AnsiColor = getColorFromName("MEDIUMORCHID")
    public static let MEDIUMPURPLE: AnsiColor = getColorFromName("MEDIUMPURPLE")
    public static let MEDIUMSEAGREEN: AnsiColor = getColorFromName("MEDIUMSEAGREEN")
    public static let MEDIUMSLATEBLUE: AnsiColor = getColorFromName("MEDIUMSLATEBLUE")
    public static let MEDIUMSPRINGGREEN: AnsiColor = getColorFromName("MEDIUMSPRINGGREEN")
    public static let MEDIUMTURQUOISE: AnsiColor = getColorFromName("MEDIUMTURQUOISE")
    public static let MEDIUMVIOLETRED: AnsiColor = getColorFromName("MEDIUMVIOLETRED")
    public static let MIDNIGHTBLUE: AnsiColor = getColorFromName("MIDNIGHTBLUE")
    public static let MINTCREAM: AnsiColor = getColorFromName("MINTCREAM")
    public static let MISTYROSE: AnsiColor = getColorFromName("MISTYROSE")
    public static let MOCCASIN: AnsiColor = getColorFromName("MOCCASIN")
    public static let NAVAJOWHITE: AnsiColor = getColorFromName("NAVAJOWHITE")
    public static let NAVY: AnsiColor = getColorFromName("NAVY")
    public static let OLDLACE: AnsiColor = getColorFromName("OLDLACE")
    public static let OLIVE: AnsiColor = getColorFromName("OLIVE")
    public static let OLIVEDRAB: AnsiColor = getColorFromName("OLIVEDRAB")
    public static let ORANGE: AnsiColor = getColorFromName("ORANGE")
    public static let ORANGERED: AnsiColor = getColorFromName("ORANGERED")
    public static let ORCHID: AnsiColor = getColorFromName("ORCHID")
    public static let PALEGOLDENROD: AnsiColor = getColorFromName("PALEGOLDENROD")
    public static let PALEGREEN: AnsiColor = getColorFromName("PALEGREEN")
    public static let PALETURQUOISE: AnsiColor = getColorFromName("PALETURQUOISE")
    public static let PALEVIOLETRED: AnsiColor = getColorFromName("PALEVIOLETRED")
    public static let PAPAYAWHIP: AnsiColor = getColorFromName("PAPAYAWHIP")
    public static let PEACHPUFF: AnsiColor = getColorFromName("PEACHPUFF")
    public static let PERU: AnsiColor = getColorFromName("PERU")
    public static let PINK: AnsiColor = getColorFromName("PINK")
    public static let PLUM: AnsiColor = getColorFromName("PLUM")
    public static let POWDERBLUE: AnsiColor = getColorFromName("POWDERBLUE")
    public static let PURPLE: AnsiColor = getColorFromName("PURPLE")
    public static let REBECCAPURPLE: AnsiColor = getColorFromName("REBECCAPURPLE")
    public static let RED: AnsiColor = getColorFromName("RED")
    public static let ROSYBROWN: AnsiColor = getColorFromName("ROSYBROWN")
    public static let ROYALBLUE: AnsiColor = getColorFromName("ROYALBLUE")
    public static let SADDLEBROWN: AnsiColor = getColorFromName("SADDLEBROWN")
    public static let SALMON: AnsiColor = getColorFromName("SALMON")
    public static let SANDYBROWN: AnsiColor = getColorFromName("SANDYBROWN")
    public static let SEAGREEN: AnsiColor = getColorFromName("SEAGREEN")
    public static let SEASHELL: AnsiColor = getColorFromName("SEASHELL")
    public static let SIENNA: AnsiColor = getColorFromName("SIENNA")
    public static let SILVER: AnsiColor = getColorFromName("SILVER")
    public static let SKYBLUE: AnsiColor = getColorFromName("SKYBLUE")
    public static let SLATEBLUE: AnsiColor = getColorFromName("SLATEBLUE")
    public static let SLATEGRAY: AnsiColor = getColorFromName("SLATEGRAY")
    public static let SNOW: AnsiColor = getColorFromName("SNOW")
    public static let SPRINGGREEN: AnsiColor = getColorFromName("SPRINGGREEN")
    public static let STEELBLUE: AnsiColor = getColorFromName("STEELBLUE")
    public static let TAN: AnsiColor = getColorFromName("TAN")
    public static let TEAL: AnsiColor = getColorFromName("TEAL")
    public static let THISTLE: AnsiColor = getColorFromName("THISTLE")
    public static let TOMATO: AnsiColor = getColorFromName("TOMATO")
    public static let TURQUOISE: AnsiColor = getColorFromName("TURQUOISE")
    public static let VIOLET: AnsiColor = getColorFromName("VIOLET")
    public static let WHEAT: AnsiColor = getColorFromName("WHEAT")
    public static let WHITE: AnsiColor = getColorFromName("WHITE")
    public static let WHITESMOKE: AnsiColor = getColorFromName("WHITESMOKE")
    public static let YELLOW: AnsiColor = getColorFromName("YELLOW")
    public static let YELLOWGREEN: AnsiColor = getColorFromName("YELLOWGREEN")
}