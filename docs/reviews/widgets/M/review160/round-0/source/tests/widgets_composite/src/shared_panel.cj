package widgets_composite

import cjtui.*

// A business component, reused without a second Application or private kind.
class SharedPanel <: Component {
    let model: Observable<String>
    init(model: Observable<String>) { this.model = model; finishConstruction() }
    public override func build(): Unit {
        HorizontalMenu([MenuEntry("a", "A")], { _ => model.set("latest") })
        ScrollView { Text({ => model.get() }) }.height(1)
        StatusBar { Text({ => model.get() }) }
    }
}
