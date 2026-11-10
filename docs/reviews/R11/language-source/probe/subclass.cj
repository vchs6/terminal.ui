import audit_macros.*
import auditbase.*

@AutoComponent
class CustomCounter {
    @BoxState var count: Int64 = 7
    public var builds: Int64 = 0
    public func build(): String { builds++; "count=${count}" }
}

main(): Int64 {
    let custom = CustomCounter()
    if (attachedCount() != 1 || custom.builds != 0 || custom.count != 7) { return 1 }
    let result = buildFirst()
    custom.count = 9
    let binding = @Bind(custom.count)
    if (result != "count=7" || custom.builds != 1 || binding() != 9) { return 2 }
    println("PASS macro adds cross-package open-base inheritance/build override and derived no-arg init; protected finishConstruction attaches after super; build deferred")
    println("PASS macro state field backed by generic AuditState<T> getter/setter; binding reads current value")
    return 0
}
