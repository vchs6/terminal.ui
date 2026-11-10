import auditnames.*
import auditnames.namespacemacros.*

@Component
class Custom {
    public func build(): String { "custom" }
}

main(): Int64 {
    let component: Component = Custom()
    if (component.build() != "custom" || Component().build() != "library-base") { return 1 }
    println("PASS exact dual wildcard imports distinguish @Component macro, Component type and Component() class constructor")
    return 0
}
