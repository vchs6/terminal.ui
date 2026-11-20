package cjtui_composition
import cjtui.*

class LogsScene <: Component {
    let data: JobData
    let commands: Commands
    init(data: JobData, commands: Commands) { this.data = data; this.commands = commands; finishConstruction() }
    public override func build(): Unit {
        Column {
            Text("Logs").bold()
            Text("Find:")
            TextInput(data.logQuery, controller: Some(commands.logEditor)).height(1).onMount({ref =>
                commands.logFocus = Some(ref)
                {=> commands.logFocus = None}
            })
            Checkbox({=> data.errorsOnly.get()}, {value => data.errorsOnly.set(value)}, label: "Errors only")
            Radio({=> !data.newest.get()}, {=> data.newest.set(false)}, label: "Oldest")
            Radio({=> data.newest.get()}, {=> data.newest.set(true)}, label: "Newest")
            ScrollView {
                ForEach<String>({=> data.logRows()}, {value => value[0..3]}, {row => Text({=> row.value})})
            }.layoutWeight(1)
        }.alignItems(Alignment.Stretch).layoutWeight(1)
    }
}
