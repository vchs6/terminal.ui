package ordinary_slice_consumer
import cjtui.*
main(): Int64 {
    println("CLUSTERS=${graphemeClusters("中文e\u{301}👩‍💻").size}, COLUMNS=${displayWidth("中文e\u{301}👩‍💻")}")
    let root = Column {
        Text("Source package").foreground(Color.Cyan)
        Row { Text("中文 "); Text("👩‍💻") }
    }
    let frame = render(root, 16, 3)
    println("PLAIN_BEGIN")
    println(frame.toPlainText())
    println("PLAIN_END")
    println("ANSI_BEGIN")
    println(frame.toAnsi())
    println("ANSI_END")
    return 0
}
