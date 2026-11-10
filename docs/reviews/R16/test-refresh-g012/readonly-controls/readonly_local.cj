package readonly_control
struct ReadonlyField {
    public let flag: Bool = false
}
func write(value: ReadonlyField): Unit { var local = value; local.flag = true }
