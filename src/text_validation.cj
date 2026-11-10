package cjtui

func validateText(text: String): Unit {
    for (cluster in graphemeClusters(text)) {
        if (cluster == "\n" || cluster == "\r\n") {
            continue
        }
        for (r in cluster.runes()) {
            let n = UInt32(r)
            if (n < 32 || (n >= 127 && n < 160)) {
                throw IllegalArgumentException("control character in text")
            }
        }
    }
}
