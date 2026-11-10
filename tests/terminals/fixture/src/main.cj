package terminal_auto_fixture

import cjtui.*
import std.env.*
import std.fs.*

// This normal consumer deliberately has no color override or capability branch.
// The onKey diagnostic is evidence only; device adaptation remains Application's job.
main(): Int64 {
    let evidenceDirectory = getVariable("CJTUI_TERMINAL_EVIDENCE").getOrThrow()
    let marker = [Text("EVENT-FENCE")]
    let root = Column {
        Text("AUTO RGB 1,128,254").foreground(Color.Rgb(1, 128, 254)).background(Color.Rgb(250, 0, 0))
            .bold().dim().italic().underline().inverse().strikethrough()
        Text("Unicode: 中文 e\u{301} 👩‍💻")
        marker[0]
        Text("Resize edge: 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    }
    let app = Application(root)
    let serial = [0]
    app.onKey { event =>
        serial[0]++
        match (app.terminalCapabilities()) {
            case Some(profile) =>
                File.writeTo(evidenceDirectory + "/capabilities-" + serial[0].toString() + ".txt", (
                    "colorMode=${profile.colorMode};colorKnown=${profile.colorKnown};terminfoKnown=${profile.terminfoKnown};" +
                    "bold=${profile.supportsBold};dim=${profile.supportsDim};italic=${profile.supportsItalic};" +
                    "underline=${profile.supportsUnderline};inverse=${profile.supportsInverse};strike=${profile.supportsStrikethrough};" +
                    "ncv=${profile.noColorVideo};source=${profile.source};reason=${profile.reason};event=${event.text}\n").toArray())
            case None => throw Exception("terminal capabilities unavailable after successful session open")
        }
        marker[0].bold(serial[0] % 2 == 1)
        File.writeTo(evidenceDirectory + "/event-" + serial[0].toString() + ".ack", [97u8, 99u8, 107u8])
        if (event.text == "q") { app.stop() }
        if (event.text == "e") { throw Exception("terminal fixture exception sentinel") }
    }.run()
    return 0
}
