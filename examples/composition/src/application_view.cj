package cjtui_composition
import cjtui.*

class ApplicationView <: Component {
    let data: JobData
    let commands: Commands
    init(data: JobData, commands: Commands) { this.data = data; this.commands = commands; finishConstruction() }
    public override func build(): Unit {
        Column {
            HorizontalMenu([
                MenuEntry("tasks", "Tasks "), MenuEntry("logs", "Logs "), MenuEntry("theme", "Theme "),
                MenuEntry("details", "Details "), MenuEntry("disabled", "Disabled ", enabled: false),
                MenuEntry("quit", "Quit")
            ], {key =>
                match (key) {
                    case "tasks" => commands.scene(false)
                    case "logs" => commands.scene(true)
                    case "theme" => commands.toggleTheme()
                    case "details" => commands.openDetails()
                    case "quit" => commands.quit()
                    case _ => ()
                }
            })
            TasksScene(data, commands).alignItems(Alignment.Stretch).layoutWeight(1).visible({=> !data.logsScene.get()})
            LogsScene(data, commands).alignItems(Alignment.Stretch).layoutWeight(1).visible({=> data.logsScene.get()})
            StatusBar { Text({=> data.status()}) }
        }.viewport(ScrollAxes.Off).alignItems(Alignment.Stretch).layoutWeight(1).onMount({ref => commands.owner = Some(ref); {=> commands.owner = None} })
    }
}
