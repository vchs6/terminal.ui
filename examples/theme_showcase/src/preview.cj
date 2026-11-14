package cjtui_theme_showcase
import cjtui.*

class Preview <: Component {
    let commands: Commands
    var actionRef: ?NodeRef = None
    init(commands: Commands) { this.commands = commands; finishConstruction() }
    public override func build(): Unit {
        Column {
            Text("Preview")
            Text("Theme sample")
            Text("e\u{301} 中 👩\u{200d}💻")
            Text("Select action")
            Text("")
            Text("")
            Button("Actions", {=> commands.popup(actionRef.getOrThrow())}).onMount({ref => actionRef = Some(ref); {=> actionRef = None} })
        }.alignItems(Alignment.Stretch).onKey({event => commands.modalKey(event)})
    }
}
