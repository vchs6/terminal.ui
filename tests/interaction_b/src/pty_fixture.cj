package interaction_b

import cjtui.*

// No focusable children: A must route actual device input to activeTarget.
// Snapshot/resize/terminal settings are never faked by this fixture.
func ptyFixture(): Int64 {
    let app = Application(Column({ => hundredRows() }))
    app.onKeyEvent({ e => if (e.key.text == "q") { app.stop(); e.preventDefault() } })
    app.run()
    return 0
}
