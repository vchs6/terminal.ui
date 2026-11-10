package rich_text_contract

import cjtui.*
import std.collection.ArrayList

// Test accumulator only: no parsing, style resolution, width or escape logic.
class DecodedStream {
    let spans = ArrayList<TextSpan>()
    let issues = ArrayList<AnsiTextDiagnostic>()

    func append(batch: AnsiTextBatch): Unit {
        for (span in batch.spans) { spans.add(span) }
        for (issue in batch.diagnostics) { issues.add(issue) }
    }

    func verify(expected: RichText, expectedIssues: Array<(AnsiTextIssue, Int64)>, name: String): Unit {
        check(RichText(spans.toArray()) == expected, "${name}: normalized literal spans")
        check(issues.size == expectedIssues.size, "${name}: issue count ${issues.size}/${expectedIssues.size}")
        for (i in 0..expectedIssues.size) {
            check(issues[i].kind == expectedIssues[i][0] && issues[i].offset == expectedIssues[i][1],
                "${name}: diagnostic ${i} kind and absolute byte offset")
        }
    }
}
