package session_example

import cjtui.{Application, Observable, SessionResult, SessionStatus, Text}

func describe(result: SessionResult): String {
    match (result.status) {
        case SessionStatus.SentUnconfirmed => "Sent; the terminal may reject it."
        case SessionStatus.Unsupported => "Unavailable on this session."
        case SessionStatus.Unknown => "No safe restoration is available."
        case SessionStatus.Failed => "Request failed."
        case SessionStatus.Applied => "Confirmed by an adapter."
    }
}

main(): Unit {
    let message = Observable<String>("c: copy  t: title  r: restore  q: quit")
    let app = Application(Text({=> message.get()}))
    app.onKey {
        key => match (key.text) {
            case "c" => message.set(describe(app.copyLocalText("Hello from cjtui")))
            case "t" => message.set(describe(app.setHostTitle("cjtui session example")))
            case "r" => message.set(describe(app.restoreHostTitle()))
            case "q" => app.stop()
            case _ => ()
        }
    }
    app.run()
}
