package cjtui_composition
import cjtui.*

class TasksScene <: Component {
    let data: JobData
    let commands: Commands
    init(data: JobData, commands: Commands) { this.data = data; this.commands = commands; finishConstruction() }
    public override func build(): Unit {
        SplitPane(axis: SplitAxis.Horizontal) {
            Column {
                Text("Tasks").bold()
                Text("Find:")
                TextInput(data.query, controller: Some(commands.taskEditor)).height(1).onMount({ref =>
                    commands.taskFocus = Some(ref)
                    ref.application().post(ref, {=> ref.requestFocus()})
                    {=> commands.taskFocus = None}
                })
                Checkbox({=> data.hideDone.get()}, {value => data.hideDone.set(value)}, label: "Hide done")
                Radio({=> !data.nameOrder.get()}, {=> data.nameOrder.set(false)}, label: "ID")
                Radio({=> data.nameOrder.get()}, {=> data.nameOrder.set(true)}, label: "Name")
                Button("Run jobs", {=> commands.start()}).enabled({=> data.stage.get() == 0 && !commands.running.get()})
                Progress({=> Float64(data.stage.get()) / 2.0}).width(20).foreground(Color.Cyan)
                Text({=> data.phase()}).foreground({=> if (data.stage.get() == 2 && data.acknowledged.get()) { Color.Green } else { Color.Yellow }})
                ScrollView {
                    ForEach<String>({=> data.taskRows()}, {value => value[0..2]}, {row => Text({=> row.value})})
                }.layoutWeight(1)
            }.layoutWeight(1)
            JobPanel(data, commands).alignItems(Alignment.Stretch).layoutWeight(1)
        }.alignItems(Alignment.Stretch).layoutWeight(1)
    }
}
