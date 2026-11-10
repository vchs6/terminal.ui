package readonly_control
struct MutableField {
    public var flag: Bool = false
}
func write(value: MutableField): Unit { var local = value; local.flag = true }
