package overlay_example
import cjtui.*

class SettingsPanel <: Component {
    let model: Observable<String>
    init(model: Observable<String>) { this.model = model; finishConstruction() }
    public override func build(): Unit { Text({=> model.get()}) }
}
