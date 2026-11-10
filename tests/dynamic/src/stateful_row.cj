package dynamic_contract

import cjtui.*

class StatefulRow <: Component {
    let item: ListItem<RowData>
    let local = Observable<Int64>(0)
    let log: FixtureLog

    init(item: ListItem<RowData>, log: FixtureLog) {
        super()
        this.item = item
        this.log = log
        finishConstruction()
    }

    public override func build(): Unit {
        log.builds++
        Text({ => "${item.value.label}:${local.get()}" })
    }
}
