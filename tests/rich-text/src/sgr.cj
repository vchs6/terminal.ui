package rich_text_contract

import cjtui.*

func sgrContract(): Unit {
    ansiCase("", RichText(""), [], "empty stream")
    ansiCase("A\u{1b}[31mR\u{1b}[0mZ", RichText([TextSpan("A"),
        TextSpan("R", style: TextStylePatch(foreground: Some(Color.Red))), TextSpan("Z", style: resetPatch())]),
        [], "unset then red then explicit reset")
    let colors = [Color.Black, Color.Red, Color.Green, Color.Yellow, Color.Blue, Color.Magenta, Color.Cyan, Color.White,
        Color.BrightBlack, Color.BrightRed, Color.BrightGreen, Color.BrightYellow, Color.BrightBlue,
        Color.BrightMagenta, Color.BrightCyan, Color.BrightWhite]
    for (i in 0..16) {
        let fg = if (i < 8) { 30 + i } else { 90 + i - 8 }
        let bg = if (i < 8) { 40 + i } else { 100 + i - 8 }
        ansiCase("\u{1b}[${fg};${bg}mX", RichText([TextSpan("X",
            style: TextStylePatch(foreground: Some(colors[i]), background: Some(colors[i])))]), [],
            "all sixteen foreground/background colors ${i}")
    }
    let enable = ["1", "2", "3", "4", "7", "9"]
    let patches = [TextStylePatch(bold: Some(true)), TextStylePatch(dim: Some(true)),
        TextStylePatch(italic: Some(true)), TextStylePatch(underline: Some(true)),
        TextStylePatch(inverse: Some(true)), TextStylePatch(strikethrough: Some(true))]
    for (i in 0..enable.size) {
        ansiCase("\u{1b}[${enable[i]}mX", RichText([TextSpan("X", style: patches[i])]), [], "enable SGR ${enable[i]}")
    }
    let off = ["22", "23", "24", "27", "29", "39", "49"]
    let offPatches = [TextStylePatch(bold: Some(false), dim: Some(false)), TextStylePatch(italic: Some(false)),
        TextStylePatch(underline: Some(false)), TextStylePatch(inverse: Some(false)),
        TextStylePatch(strikethrough: Some(false)), TextStylePatch(foreground: Some(Color.Default)),
        TextStylePatch(background: Some(Color.Default))]
    for (i in 0..off.size) {
        ansiCase("\u{1b}[${off[i]}mX", RichText([TextSpan("X", style: offPatches[i])]), [], "disable/reset SGR ${off[i]}")
    }
    for (sgr in ["", "0", ";", "0;", ";0"]) {
        ansiCase("\u{1b}[${sgr}mX", RichText([TextSpan("X", style: resetPatch())]), [], "empty top fields reset ${sgr}")
    }
    for (channel in [0, 1, 127, 255]) {
        ansiCase("\u{1b}[38;5;${channel};48;5;${channel}mX", RichText([TextSpan("X",
            style: TextStylePatch(foreground: Some(Color.Indexed(UInt8(channel))),
                background: Some(Color.Indexed(UInt8(channel)))))]), [], "indexed endpoints ${channel}")
    }
    ansiCase("\u{1b}[38;2;0;128;255;48;2;255;1;0mX", RichText([TextSpan("X",
        style: TextStylePatch(foreground: Some(Color.Rgb(0, 128, 255)),
            background: Some(Color.Rgb(255, 1, 0))))]), [], "RGB typed channels")
    ansiCase("\u{1b}[1;2;3;4;7;9;22;23;24;27;29mX", RichText([TextSpan("X",
        style: TextStylePatch(bold: Some(false), dim: Some(false), italic: Some(false),
            underline: Some(false), inverse: Some(false), strikethrough: Some(false)))]), [], "on then off atomic mapping")
    ansiCase("\u{1b}[;31mX", RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red),
        background: Some(Color.Default), bold: Some(false), dim: Some(false), italic: Some(false),
        underline: Some(false), inverse: Some(false), strikethrough: Some(false)))]), [], "reset then red in same sequence")
    // Unknown/invalid suffix must discard even valid leading operations.
    let unknown = ["1;999", "31:1", "?31", "31 ", "38;3;1", "48;4", "1;999;38;5;"]
    for (params in unknown) {
        ansiCase("\u{1b}[32mA\u{1b}[${params}mB", RichText([TextSpan("AB",
            style: TextStylePatch(foreground: Some(Color.Green)))]),
            [(AnsiTextIssue.UnsupportedSequence, 6)], "atomic unsupported ${params}")
    }
    let malformed = ["38", "48", "38;5", "48;2;1;2", "38;5;", "38;2;1;;3", "48;;1", "38;5;256",
        "48;2;1;999;3", "38;2;1;2;", "38;5;;999"]
    for (params in malformed) {
        ansiCase("\u{1b}[32mA\u{1b}[1;${params}mB", RichText([TextSpan("AB",
            style: TextStylePatch(foreground: Some(Color.Green)))]),
            [(AnsiTextIssue.MalformedSequence, 6)], "atomic malformed ${params}")
    }
    println("PASS: complete SGR whitelist, reset and atomic first-error goldens")
}
