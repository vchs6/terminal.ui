package keyboard_contract
import cjtui.*

// Expected events/offsets are handwritten; split transport never derives them.
func allSplits(test: GoldenCase, limits!: KeyboardLimits = KeyboardLimits()): Unit {
    for (split in 0..(test.bytes.size + 1)) {
        let decoder = KeyboardDecoder(limits: limits)
        let seen = Observed()
        seen.add(decoder.feed(test.bytes.slice(0, split)))
        seen.add(decoder.feed(test.bytes.slice(split, test.bytes.size - split)))
        seen.add(decoder.finish())
        seen.expect(test.events, test.issues, "${test.name} split ${split}")
    }
    let decoder = KeyboardDecoder(limits: limits)
    let seen = Observed()
    for (byte in test.bytes) { seen.add(decoder.feed([byte])) }
    seen.add(decoder.finish())
    seen.expect(test.events, test.issues, "${test.name} bytewise")
}

func asciiCase(name: String, bytes: String, event: KeyEvent): Unit {
    allSplits(GoldenCase(name, bytes.toArray(), [event]))
}
