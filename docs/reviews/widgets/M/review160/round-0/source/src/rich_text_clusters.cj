package cjtui

import std.collection.ArrayList

// Segment the concatenated document once. Byte ranges only choose the patch of
// the first scalar; a span boundary can never split a Unicode grapheme.
func richTextClusters(value: RichText): Array<TextSpan> {
    let spans = value.spans
    let clusters = graphemeClusters(value.toPlainText())
    var spanIndex: Int64 = 0
    var consumed: Int64 = 0
    var boundary: Int64 = if (spans.isEmpty()) {
        0
    } else {
        spans[0].text.size
    }
    let result = ArrayList<TextSpan>()
    for (cluster in clusters) {
        while (consumed >= boundary && spanIndex + 1 < spans.size) {
            spanIndex++
            boundary += spans[spanIndex].text.size
        }
        result.add(TextSpan(cluster, style: spans[spanIndex].style))
        consumed += cluster.size
    }
    result.toArray()
}
