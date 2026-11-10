package dynamic_contract

import cjtui.*
import std.collection.*

class SlotFixture {
    let items: Observable<Array<String>>
    let rows: ArrayList<Component>
    let root: Component
    let app: Application

    init() {
        let data = Observable<Array<String>>(["A", "B", "C"])
        let built = ArrayList<Component>()
        items = data
        rows = built
        root = Column({ =>
            ForEach<String>({ => data.get() }, { value => value }, { item =>
                let row = Text({ => item.value })
                built.add(row)
            })
        })
        app = Application(root)
        app.startHeadless()
    }

    func manualX(): Component {
        let x = Text("X")
        app.batch({ => ref(root).insertBefore(ref(rows[1]), x) })
        x
    }
}
