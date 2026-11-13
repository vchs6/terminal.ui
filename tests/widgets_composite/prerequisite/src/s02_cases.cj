package widgets_composite_prerequisite

import cjtui.*

func acceptedS02(): Unit {
    let calls = [0]
    let controls = [Button("B", { => calls[0]++ }), Checkbox({ => false }, {_ => calls[0]++}), Radio({ => false }, { => calls[0]++ })]
    for (control in controls) {
        let app = Application(control)
        app.startHeadless()
        try {
            let ref = control.reference().getOrThrow()
            app.batch({ => ref.requestFocus() })
            check(ref.isFocused(), "S02 fixture commits focus before dispatch")
            for (mask in 1..8) {
                app.dispatch(ref, KeyEvent("enter", ctrl: (mask % 2 == 1), alt: (mask / 2 % 2 == 1), shift: (mask / 4 == 1)))
                app.dispatch(ref, KeyEvent("text", text: " ", ctrl: (mask % 2 == 1), alt: (mask / 2 % 2 == 1), shift: (mask / 4 == 1)))
            }
            check(calls[0] == 0, "S02 shared complete modifier exclusions")
        } finally { app.dispose() }
    }
}
