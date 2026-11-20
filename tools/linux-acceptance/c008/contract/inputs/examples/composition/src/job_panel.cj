package cjtui_composition
import cjtui.*

class JobPanel <: Component {
    let data: JobData
    let commands: Commands
    let modal: Bool
    let editor = TextEditController()
    init(data: JobData, commands: Commands, modal!: Bool = false) {
        this.data = data
        this.commands = commands
        this.modal = modal
        finishConstruction()
    }
    public override func build(): Unit {
        Column {
            Text("Job 01 Parse").bold()
            Text({=> data.jobPhase()}).foreground(Color.Cyan)
            Text("Notes")
            TextArea(data.notes, controller: Some(editor)).height(3)
            Button("Actions", {=> openActions()}).onMount({ref =>
                action = Some(ref)
                {=> action = None}
            })
        }.alignItems(Alignment.Stretch).layoutWeight(1).onKey({event => if (modal) { commands.modalKey(event) }})
    }
    var action: ?NodeRef = None
    func openActions(): Unit {
        let popupRef = Array<?NodeRef>(1, repeat: Option<NodeRef>.None)
        let popupHandle = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
        let popup = PopupMenu([MenuEntry("inspect", "Inspect"), MenuEntry("delete", "Delete", enabled: false),
            MenuEntry("confirm", "Confirm")], {key =>
                if (key == "confirm") {
                    let confirmation = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
                    let content = Column {
                        Text("Confirm?")
                        Button("Acknowledge", {=>
                            data.acknowledged.set(true)
                            confirmation[0].getOrThrow().close()
                            popupHandle[0].getOrThrow().close()
                        })
                    }.width(24).height(4).border(BorderStyle.Rounded).onKey({event => commands.modalKey(event)})
                    confirmation[0] = Some(popupRef[0].getOrThrow().openOverlay(content,
                        options: OverlayOptions(mode: OverlayMode.Modal)))
                } else { popupHandle[0].getOrThrow().close() }
            }).onMount({ref => popupRef[0] = Some(ref); {=> popupRef[0] = Option<NodeRef>.None} })
            .onKey({event => commands.modalKey(event)})
        popupHandle[0] = Some(action.getOrThrow().openOverlay(popup))
    }
}
