package readonly_control
struct MutableField {
    public var flag: Bool = false
}
func write(value: MutableField): Unit { value.flag = true }
