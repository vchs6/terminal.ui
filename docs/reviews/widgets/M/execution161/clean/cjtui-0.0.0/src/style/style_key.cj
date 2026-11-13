package cjtui.style
public class StyleKey<T> {
    public let name: String
    let read: (StyleRuleData, Int64) -> StyleValue<T>
    let write: (StyleRuleData, Int64, StyleValue<T>) -> Unit
    let validate: (StyleValue<T>) -> Unit
    internal init(name: String, read: (StyleRuleData, Int64) -> StyleValue<T>,
        write: (StyleRuleData, Int64, StyleValue<T>) -> Unit, validate: (StyleValue<T>) -> Unit) {
        this.name = name; this.read = read; this.write = write; this.validate = validate
    }
}
