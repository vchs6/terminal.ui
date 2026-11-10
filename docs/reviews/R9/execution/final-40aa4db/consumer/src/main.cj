package layout_package_consumer
import cjtui.*
main(): Int64 {
    let panel = Column {
        Text("Bundle panel").foreground(Color.Cyan).bold()
        Row {
            Text("中文").layoutWeight(1)
            Text("OK").layoutWeight(1).textAlign(Alignment.End)
        }.gap(1)
    }.width(22).height(6).padding(1).border(BorderStyle.Rounded)
        .borderColor(Color.Cyan).background(Color.Blue)
        .shadow(style: Style(foreground: Color.Red))
    let frame = render(panel, 26, 8)
    println("PLAIN_BEGIN")
    println(frame.toPlainText())
    println("PLAIN_END")
    println("ANSI_BEGIN")
    print(frame.toAnsi())
    println("\nANSI_END")
    return 0
}
