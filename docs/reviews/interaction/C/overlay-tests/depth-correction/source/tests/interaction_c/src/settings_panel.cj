package interaction_c

import cjtui.*

// The SAME public custom type is used in a normal collector and as a new layer
// instance. No private kind, compositor, or overlay-specific build exists.
class SettingsPanel <: Component {
    let model: Observable<String>
    var builds: Int64 = 0
    init(model: Observable<String>) {
        this.model = model
        finishConstruction()
    }
    public override func build(): Unit {
        builds++
        Text({=> model.get()})
    }
}
