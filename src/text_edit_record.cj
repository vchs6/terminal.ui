package cjtui

class TextEditRecord {
    let before: String
    let after: String
    let beforeSelection: TextSelection
    let afterSelection: TextSelection
    init(before: String, after: String, beforeSelection: TextSelection, afterSelection: TextSelection) {
        this.before = before
        this.after = after
        this.beforeSelection = beforeSelection
        this.afterSelection = afterSelection
    }
    func bytes(): Int64 {
        before.size + after.size
    }
}
