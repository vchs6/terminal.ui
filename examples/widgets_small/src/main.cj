package cjtui_widgets_small

import cjtui.*

main(): Int64 {
    let checked = Observable(false)
    let selected = Observable(false)
    let app = Application(
        Column {
            Label("Small widgets")
            Button("Continue", {=> checked.set(!checked.get())})
            Checkbox({=> checked.get()}, {value => checked.set(value)}, label: "Ready")
            Radio({=> selected.get()}, {=> selected.set(true)}, label: "Choice")
            Progress({
                => if (checked.get()) {
                1.0
            } else {
                0.5
            }
            })
        }
    )
    app.onKey {
        event => if (event.text == "q") {
        app.stop()
    }
    }.run()
    return 0
}
