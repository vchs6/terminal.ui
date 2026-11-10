import auditnames.*
import auditnames.macros.*
import auditnames

@Component
class Custom {
    @State var number: Int64 = 3
    public func build(): String { "number=${number}" }
}

main(): Int64 {
    let custom = Custom()
    let component: Component = custom
    if (component.build() != "number=3") { return 1 }
    custom.number = 8
    if (component.build() != "number=8") { return 2 }
    let ordinary = Component()
    if (ordinary.build() != "library-base") { return 3 }
    println("PASS wildcard type Component + macro Component imports: @Component, explicit Component type and Component() constructor coexist")
    return 0
}
