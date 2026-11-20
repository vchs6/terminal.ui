package cjtui_theme_showcase
import cjtui.*

class GalleryView <: Component {
    let data: GalleryData
    let commands: Commands
    init(data: GalleryData, commands: Commands) { this.data = data; this.commands = commands; finishConstruction() }
    public override func build(): Unit {
        Column {
            HorizontalMenu([MenuEntry("classic", "Classic "), MenuEntry("dark", "Dark "), MenuEntry("light", "Light "),
                MenuEntry("contrast", "Contrast "), MenuEntry("file", "File "), MenuEntry("reload", "Reload "),
                MenuEntry("preview", "Preview "), MenuEntry("disabled", "Disabled ", enabled: false), MenuEntry("quit", "Quit")],
                {key => commands.action(key)})
            SplitPane(axis: SplitAxis.Horizontal) {
                Column {
                    Text("Gallery").styles([StyleUse.Named("title")])
                    Label("Label e\u{301} 中 👩\u{200d}💻")
                    Text("Find:")
                    TextInput(data.query, controller: Some(commands.editor)).height(1).onMount({ref =>
                        ref.application().post(ref, {=> ref.requestFocus()}); {=> ()}
                    })
                    Checkbox({=> data.pin.get()}, {value => data.pin.set(value)}, label: "Pin")
                    Radio({=> !data.byName.get()}, {=> data.byName.set(false)}, label: "ID")
                    Radio({=> data.byName.get()}, {=> data.byName.set(true)}, label: "Name")
                    Button("Run", {=> data.pending.set(true)})
                    Progress({=> Float64(data.progress()) / 2.0}).width(20)
                    ScrollView {
                        for (i in 1..25) {
                            let num = if (i < 10) { "0${i}" } else { "${i}" }
                            Text("0${num} INFO record ${num}")
                        }
                    }.layoutWeight(1).onMount({ref => commands.log = Some(ref); {=> commands.log = None} })
                }.layoutWeight(1)
                Column {
                    Text("Notes").styles([StyleUse.Named("title")])
                    Text(RichText([TextSpan("Ready • "), TextSpan("accent", style: TextStylePatch(underline: Some(true)))]))
                        .styles([StyleUse.Named("accent")])
                    Text("Edit:")
                    TextArea(data.notes, controller: Some(commands.notesEditor)).height(2)
                    Button("Actions", {=> commands.popup(commands.actions.getOrThrow())}).onMount({ref =>
                        commands.actions = Some(ref); {=> commands.actions = None}
                    })
                    Button("Disabled", {=> ()}).enabled(false)
                    Text("Selected")
                    Text({=> commands.phase()})
                }.layoutWeight(1)
            }.alignItems(Alignment.Stretch).layoutWeight(1)
            StatusBar { Text({=> commands.status()}) }
        }.viewport(ScrollAxes.Off).alignItems(Alignment.Stretch).onMount({ref => commands.owner = Some(ref); {=> commands.owner = None} })
    }
}
