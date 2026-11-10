package terminal_auto_fixture

import cjtui.*
import std.env.*
import std.fs.*

// This normal consumer deliberately has no color override or capability branch.
// The onKey diagnostic is evidence only; device adaptation remains Application's job.
main(): Int64 {
    let evidenceDirectory = getVariable("CJTUI_TERMINAL_EVIDENCE").getOrThrow()
    let rich = [Text("AUTO RGB 1,128,254").foreground(Color.Rgb(1, 128, 254)).background(Color.Rgb(250, 0, 0))]
    let marker = [Text("EVENT-FENCE")]
    let root = Column {
        rich[0]
        Text("Unicode: 中文 e\u{301} 👩‍💻")
        marker[0]
        Text("Resize edge: 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    }
    let app = Application(root)
    let serial = [0]
    let color = [0]
    let styled = [false]
    app.onKey { event =>
        serial[0]++
        match (app.terminalCapabilities()) {
            case Some(profile) =>
                File.writeTo(evidenceDirectory + "/capabilities-" + serial[0].toString() + ".txt", (
                    "colorMode=${profile.colorMode};colorKnown=${profile.colorKnown};terminfoKnown=${profile.terminfoKnown};" +
                    "supportsBold=${profile.supportsBold};supportsDim=${profile.supportsDim};supportsItalic=${profile.supportsItalic};" +
                    "supportsUnderline=${profile.supportsUnderline};supportsInverse=${profile.supportsInverse};supportsStrikethrough=${profile.supportsStrikethrough};" +
                    "ncv=${profile.noColorVideo};source=${profile.source};reason=${profile.reason};event=${event.text}\n").toArray())
            case None => throw Exception("terminal capabilities unavailable after successful session open")
        }
        if (event.text == "c") {
            color[0] = (color[0] + 1) % 3
            let value = match (color[0]) { case 0 => Color.Rgb(1, 128, 254); case 1 => Color.Rgb(250, 0, 0); case _ => Color.Rgb(238, 238, 238) }
            rich[0].foreground(value)
        }
        if (event.text == "t") {
            styled[0] = !styled[0]
            rich[0].bold(styled[0]).dim(styled[0]).italic(styled[0]).underline(styled[0]).inverse(styled[0]).strikethrough(styled[0])
        }
        if (event.text == "p") { marker[0].bold(serial[0] % 2 == 1) }
        File.writeTo(evidenceDirectory + "/event-" + serial[0].toString() + ".ack", [97u8, 99u8, 107u8])
        if (event.text == "q") { app.stop() }
        if (event.text == "e") { throw Exception("terminal fixture exception sentinel") }
    }.run()
    return 0
}
