package theme_integration_contract
import cjtui.*
func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}
func theme(body: String): Theme { Theme.parse("schema_version=1\nname=\"Integration\"\n" + body) }
func picture(root: Component, value: Theme, width: Int64, height: Int64): Frame {
    let app = Application(root, theme: value)
    app.startHeadless()
    try { return app.snapshot(width, height) } finally { app.dispose() }
}
func classic(root: Component, width: Int64, height: Int64): Frame {
    picture(root, Theme.preset(ThemePreset.Classic), width, height)
}
func grid(root: Component, width: Int64, height: Int64, expected: String, name: String): Unit {
    let frame = classic(root, width, height)
    check(frame.toPlainText() == expected, "${name}: got [${frame.toPlainText()}], expected [${expected}]")
}
func styleAt(frame: Frame, x: Int64, y: Int64, expected: Style, name: String): Unit {
    check(frame.cellAt(x,y).style == expected, name)
}
func invalidNode(build: () -> Component, value: Theme, name: String): Unit {
    var rejected = false
    try { picture(build(), value, 5, 3) }
    catch (e: UIException) { rejected = e.code == "InvalidProperty" }
    check(rejected, name)
}
