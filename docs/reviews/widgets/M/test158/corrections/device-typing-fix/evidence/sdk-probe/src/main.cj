package native_typing_probe

func call(choose: (String) -> Unit): Unit { choose("a") }

main(): Int64 {
    let chosen = [""]
    call({ key => chosen[0] += "h:" + key + ";" })
    let inspect = { =>
        let value: ?Int64 = Some(1)
        if (let Some(current) <- value) { chosen[0] += "${current};" }
    }
    inspect()
    if (chosen[0] != "h:a;1;") { throw IllegalStateException(chosen[0]) }
    0
}
