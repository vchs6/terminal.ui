package cjtui

public func TextInput(value: Observable<String>, controller!: ?TextEditController = None,
    limits!: TextEditLimits = TextEditLimits(), onChange!: (String) -> Unit = {_ =>},
    onSubmit!: (String) -> Unit = {_ =>}, onIssue!: (TextEditIssue) -> Unit = {_ =>}): Component {
    editingFactory(value, controller, limits, false, onChange, onSubmit, onIssue)
}
