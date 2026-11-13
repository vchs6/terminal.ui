package cjtui

func widgetCaption(value: String): String {
    validatePlainText(value)
    for (r in value.runes()) {
        let code = UInt32(r)
        if (code == 10 || code == 13 || code == 0x2028 || code == 0x2029) {
            throw IllegalArgumentException("caption must be a single logical line")
        }
    }
    value
}

func widgetMarkedCaption(marker: String, label: String): String {
    let caption = widgetCaption(label)
    if (caption.isEmpty()) {
        marker
    } else {
        "${marker} ${caption}"
    }
}
