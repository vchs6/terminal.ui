package cjtui_widgets_composition

import cjtui.*

main(): Int64 {
    let status = Observable("Ready")
    let trigger = Array<?NodeRef>(1, repeat: Option<NodeRef>.None)
    let app = Application(
        Column {
            HorizontalMenu([MenuEntry("open", "Open"), MenuEntry("save", "Save")],
                {key => status.set("Selected: " + key)})
            Button(
                "Options",
                {
                    =>
                        let handle = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
                        let popup = PopupMenu(
                            [MenuEntry("close", "Close")],
                            {
                                key =>
                                    status.set("Selected: " + key)
                                    handle[0].getOrThrow().close()
                            }
                        )
                        handle[0] = Some(trigger[0].getOrThrow().openOverlay(popup))
                }
            ).onMount(
                {
                    ref =>
                        trigger[0] = Some(ref)
                        {=> trigger[0] = Option<NodeRef>.None}
                }
            )
            SplitPane(axis: SplitAxis.Horizontal) {
                Text("First pane").layoutWeight(1)
                Text("Second pane").layoutWeight(1)
            }.layoutWeight(1)
            StatusBar {Text({=> status.get()})}
        }
    )
    app.onKey({
        event => if (event.text == "q") {
            app.stop()
        }
    }).run()
    0
}
