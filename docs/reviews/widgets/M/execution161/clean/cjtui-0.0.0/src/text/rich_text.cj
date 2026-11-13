package cjtui.text

import std.collection.ArrayList

public class RichText <: Equatable<RichText> {
    private let content: Array<TextSpan>
    private let plain: String
    public init(value: String) {
        this([TextSpan(value)])
    }
    public init(spans: Array<TextSpan>) {
        let normalized = ArrayList<TextSpan>()
        let text = StringBuilder()
        for (span in spans) {
            text.append(span.text)
            if (span.text.isEmpty()) {
                continue
            }
            if (!normalized.isEmpty() && normalized[normalized.size - 1].style == span.style) {
                let previous = normalized[normalized.size - 1]
                normalized[normalized.size - 1] = TextSpan(previous.text + span.text, style: span.style)
            } else {
                normalized.add(span)
            }
        }
        plain = text.toString()
        validatePlainText(plain)
        content = normalized.toArray()
    }
    public prop spans: Array<TextSpan> {
        get() {
            content.clone()
        }
    }
    public func toPlainText(): String {
        plain
    }
    public operator func ==(other: RichText): Bool {
        if (content.size != other.content.size) {
            return false
        }
        for (i in 0..content.size) {
            if (content[i] != other.content[i]) {
                return false
            }
        }
        true
    }
}
