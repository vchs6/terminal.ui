package cjtui.text

import std.collection.ArrayList
import cjtui.style.TextStylePatch

// One call's output only: the decoder never retains delivered spans or issues.
class AnsiTextOutput {
    let spans = ArrayList<TextSpan>()
    let diagnostics = ArrayList<AnsiTextDiagnostic>()
    private var run = StringBuilder()
    private var style = TextStylePatch()
    func append(text: String, patch: TextStylePatch): Unit {
        if (style != patch) {
            flush();
            style = patch
        }
        run.append(text)
    }
    private func flush(): Unit {
        let text = run.toString()
        if (!text.isEmpty()) {
            spans.add(TextSpan(text, style: style))
        }
        run = StringBuilder()
    }
    func batch(): AnsiTextBatch {
        flush()
        AnsiTextBatch(spans.toArray(), diagnostics.toArray())
    }
}
