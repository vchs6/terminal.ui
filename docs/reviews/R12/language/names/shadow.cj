import auditnames.*
import auditnames.macros.*
import auditnames

class Component {}
class Observable<T> { init() {} }

@Component
class Custom {
    @State var number: Int64 = 3
    public func build(): String { "number=${number}" }
}

main(): Int64 {
    let localComponent: Component = Component()
    let localObservable = Observable<Int64>()
    let custom = Custom()
    let component: auditnames.Component = custom
    custom.number = 9
    if (component.build() != "number=9") { return 1 }
    println("PASS consumer Observable/Component shadows do not capture generated auditnames.Observable<T>/auditnames.Component; @Component remains macro")
    return 0
}
