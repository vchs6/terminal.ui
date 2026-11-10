package rich_text_contract

import cjtui.*

// Exception streams deliberately assert only code and fail-close. Prefix batches
// already delivered before the failure may differ with chunk boundaries by contract.
func invalidSplits(bytes: Array<UInt8>, name: String): Unit {
    for (cut in 0..(bytes.size + 1)) {
        let decoder = AnsiTextDecoder()
        let actual = ["no exception"]
        try {
            decoder.feed(bytes.slice(0, cut))
            decoder.feed(bytes.slice(cut, bytes.size - cut))
            decoder.finish()
        } catch (error: AnsiTextException) { actual[0] = error.code }
        check(actual[0] == "InvalidUtf8", "${name}: same error code at split ${cut}")
        ansiError("DecoderClosed", { => decoder.feed("safe".toArray()); () }, "invalid UTF8 permanently closes feed")
        ansiError("DecoderClosed", { => decoder.finish(); () }, "invalid UTF8 permanently closes finish")
    }
}

func invalidUtf8Contract(): Unit {
    let invalid: Array<Array<UInt8>> = [[UInt8(0xff)], [UInt8(0xc0), UInt8(0xaf)], [UInt8(0xc1), UInt8(0xbf)], [UInt8(0xe0), UInt8(0x80), UInt8(0x80)],
        [UInt8(0xed), UInt8(0xa0), UInt8(0x80)], [UInt8(0xf0), UInt8(0x80), UInt8(0x80), UInt8(0x80)], [UInt8(0xf4), UInt8(0x90), UInt8(0x80), UInt8(0x80)],
        [UInt8(0xf5), UInt8(0x80), UInt8(0x80), UInt8(0x80)], [UInt8(0xe2), UInt8(0x28), UInt8(0xa1)], [UInt8(0xd2), UInt8(0x41)], [UInt8(0xa0)], [UInt8(0xbf)]]
    for (bytes in invalid) {
        invalidSplits(bytes, "invalid scalar")
        invalidSplits([UInt8(0x41)].concat(bytes), "valid prefix then invalid scalar")
        invalidSplits([UInt8(0x1b), UInt8(0x5d), UInt8(0x78)].concat(bytes).concat([UInt8(0x07)]), "invalid UTF8 in OSC")
        invalidSplits([UInt8(0x1b), UInt8(0x50), UInt8(0x78)].concat(bytes).concat([UInt8(0x1b), UInt8(0x5c)]), "invalid UTF8 in DCS")
    }
    for (pending in [[UInt8(0xc2)], [UInt8(0xe2), UInt8(0x82)], [UInt8(0xf0), UInt8(0x9f), UInt8(0x92)]]) {
        invalidSplits(pending, "finish rejects truncated UTF8")
        invalidSplits([UInt8(0x1b), UInt8(0x5d)].concat(pending), "finish rejects truncated UTF8 in control string")
    }
    println("PASS: InvalidUtf8 error codes and permanent closure for every split")
}
