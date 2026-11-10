package text_contract_probe

func Text(value: String): String { "plain:" + value }
func Text(value: RichText): String { "rich:" + value.value }
func Text(value: () -> String): String { "plain-binding:" + value() }
func Text(value: () -> RichText): String { "rich-binding:" + value().value }

func checkTextOverloads(): Unit {
    println(Text("A"))
    println(Text(RichText("B")))
    let getPlain: () -> String = { => "C" }
    let getRich: () -> RichText = { => RichText("D") }
    println(Text(getPlain))
    println(Text(getRich))
    println(Text({ => "E" }))
    println(Text({ => RichText("F") }))
}
