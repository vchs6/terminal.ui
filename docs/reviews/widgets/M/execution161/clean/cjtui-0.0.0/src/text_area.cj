package cjtui

public func TextArea(value: Observable<String>, controller!: ?TextEditController = None,
    limits!: TextEditLimits = TextEditLimits(), onChange!: (String) -> Unit = {_ =>},
    onIssue!: (TextEditIssue) -> Unit = {_ =>}): Component {
    editingFactory(value, controller, limits, true, onChange, {_ =>}, onIssue)
}
