package rich_text_contract

import cjtui.*

func unsupportedContract(): Unit {
    for (sequence in ["\u{1b}[2J", "\u{1b}[3;4H", "\u{1b}[2K", "\u{1b}[?25h", "\u{1b}[6n", "\u{1b}(B",
        "\u{1b}7", "\u{1b}[1$m", "\u{1b}[1:2m"]) {
        ansiCase("A" + sequence + "B", RichText("AB"), [(AnsiTextIssue.UnsupportedSequence, 1)],
            "unknown control stripped without terminal action")
    }
    for (sequence in ["\u{1b}[1 2m", "\u{1b}[1\tm", "\u{1b}[1\u{18}2m", "\u{1b}(\u{1}B"]) {
        ansiCase("A" + sequence + "B", RichText("AB"), [(AnsiTextIssue.MalformedSequence, 1)],
            "malformed control drained to final")
    }
    ansiCase("A\u{1b}[12\u{1b}[31mB", RichText([TextSpan("A"),
        TextSpan("B", style: TextStylePatch(foreground: Some(Color.Red)))]),
        [(AnsiTextIssue.MalformedSequence, 1)], "new ESC cancels non-string residual then starts sequence")
    ansiCase("A\u{1b}[1234\u{1b}[31mB", RichText([TextSpan("A"),
        TextSpan("B", style: TextStylePatch(foreground: Some(Color.Red)))]),
        [(AnsiTextIssue.SequenceTooLong, 1)], "new ESC does not duplicate existing first fault")
    ansiCase("A\u{1b}[1 2\u{1b}[31mB", RichText([TextSpan("A"),
        TextSpan("B", style: TextStylePatch(foreground: Some(Color.Red)))]),
        [(AnsiTextIssue.MalformedSequence, 1)], "new ESC does not duplicate prior syntax fault")
    ansiCase("A\u{1b}[1 2", RichText("A"),
        [(AnsiTextIssue.MalformedSequence, 1), (AnsiTextIssue.IncompleteSequence, 1)],
        "finish adds incomplete after first syntax fault")
    for (residual in ["\u{1b}", "\u{1b}(", "\u{1b}[", "\u{1b}[31", "\u{9b}31"]) {
        ansiCase("A" + residual, RichText("A"), [(AnsiTextIssue.IncompleteSequence, 1)],
            "finish consumes residual and closes")
    }
    ansiCase("A\r", RichText("A"), [(AnsiTextIssue.UnsupportedSequence, 1)], "finish discards lone CR")
    println("PASS: unknown and malformed escape framing and finish")
}
