package cjtui.text

import std.collection.ArrayList
import cjtui.style.{Color, TextStylePatch}
import ansies.core.parseCSIParams

public class AnsiTextDecoder {
    private let limits: AnsiTextLimits
    private var closed = false
    private var offset: Int64 = 0
    private var state = AnsiTextState.Text
    private var patch = TextStylePatch()
    private var sequenceOffset: Int64 = 0
    private var sequenceBytes: Int64 = 0
    private var fault = false
    private var intermediate = false
    private var whitelist = true
    private var parameters: Int64 = 1
    private var digits: Int64 = 0
    private let csi = ArrayList<UInt8>()
    private var osc = false
    private var stringEscape = false
    private let utf8 = ArrayList<UInt8>()
    private var utf8Length: Int64 = 0
    private var utf8Offset: Int64 = 0
    private var carriageReturn: ?Int64 = None
    private var carriageStyle = TextStylePatch()

    public init(limits!: AnsiTextLimits = AnsiTextLimits()) {
        this.limits = limits
    }

    private func requireOpen(): Unit {
        if (closed) {
            throw AnsiTextException("DecoderClosed", "ANSI text decoder is closed")
        }
    }
    private func fail(code: String): Nothing {
        closed = true
        csi.clear()
        utf8.clear()
        throw AnsiTextException(code, "ANSI text decoding failed: " + code)
    }
    private func issue(output: AnsiTextOutput, kind: AnsiTextIssue): Unit {
        if (!fault) {
            output.diagnostics.add(AnsiTextDiagnostic(kind, sequenceOffset))
            fault = true
            csi.clear()
        }
    }
    private func begin(state: AnsiTextState, start: Int64, bytes: Int64, output: AnsiTextOutput): Unit {
        this.state = state
        sequenceOffset = start
        sequenceBytes = bytes
        fault = false
        intermediate = false
        whitelist = true
        parameters = 1
        digits = 0
        csi.clear()
        stringEscape = false
        if (sequenceBytes > limits.maxSequenceBytes) {
            issue(output, AnsiTextIssue.SequenceTooLong)
        }
    }
    private func countByte(output: AnsiTextOutput): Unit {
        // Saturate after crossing the budget, including during indefinite quarantine.
        if (sequenceBytes <= limits.maxSequenceBytes) {
            sequenceBytes++
        }
        if (sequenceBytes > limits.maxSequenceBytes) {
            issue(output, AnsiTextIssue.SequenceTooLong)
        }
    }
    public func feed(chunk: Array<UInt8>): AnsiTextBatch {
        requireOpen()
        let output = AnsiTextOutput()
        for (byte in chunk) {
            if (offset == Int64.Max) {
                fail("InputTooLarge")
            }
            let start = offset
            offset++
            if (state != AnsiTextState.Text) {
                countByte(output)
            }
            if (!utf8.isEmpty()) {
                if (byte < 0x80 || byte > 0xbf) {
                    fail("InvalidUtf8")
                }
                utf8.add(byte)
                if (utf8.size == utf8Length) {
                    var text = ""
                    try {
                        text = String.fromUtf8(utf8.toArray())
                    } catch (_: IllegalArgumentException) {
                        fail("InvalidUtf8")
                    }
                    let n = UInt32(text.runes().next().getOrThrow())
                    utf8.clear()
                    scalar(n, text, utf8Offset, utf8Length, output)
                }
            } else if (byte < 0xa0) {
                scalar(UInt32(byte), if (byte < 0x80) {
                    String(Rune(UInt32(byte)))
                } else {
                    ""
                }, start, 1, output)
            } else if (byte >= 0xc2 && byte <= 0xf4) {
                // CSI framing is ASCII, so this lead is already a syntax fault.
                // Keep validating the scalar while draining; countByte above
                // preserves resource priority only for a fault on this same byte.
                if (state == AnsiTextState.Csi) {
                    issue(output, AnsiTextIssue.MalformedSequence)
                }
                utf8.add(byte)
                utf8Offset = start
                utf8Length = if (byte < 0xe0) {
                    2
                } else if (byte < 0xf0) {
                    3
                } else {
                    4
                }
            } else {
                fail("InvalidUtf8")
            }
        }
        output.batch()
    }
    private func scalar(n: UInt32, text: String, start: Int64, bytes: Int64, output: AnsiTextOutput): Unit {
        if (state == AnsiTextState.ControlString) {
            if (n == 0x9c || (stringEscape && n == 0x5c) || (osc && n == 7)) {
                issue(output, AnsiTextIssue.UnsupportedSequence)
                state = AnsiTextState.Text
            } else {
                stringEscape = n == 0x1b
            }
            return
        }
        if (let Some(cr) <- carriageReturn) {
            carriageReturn = None
            if (n == 10) {
                output.append("\r\n", carriageStyle);
                return
            }
            output.diagnostics.add(AnsiTextDiagnostic(AnsiTextIssue.UnsupportedSequence, cr))
        }
        if (n == 0x1b) {
            if (state != AnsiTextState.Text) {
                issue(output, AnsiTextIssue.MalformedSequence)
            }
            begin(AnsiTextState.Escape, start, bytes, output)
            return
        }
        if (state == AnsiTextState.Escape) {
            escape(n, output);
            return
        }
        if (state == AnsiTextState.Csi) {
            controlSequence(n, output);
            return
        }
        if (n == 0x9b) {
            begin(AnsiTextState.Csi, start, bytes, output);
            return
        }
        if (n == 0x90 || n == 0x98 || n == 0x9d || n == 0x9e || n == 0x9f) {
            begin(AnsiTextState.ControlString, start, bytes, output)
            osc = n == 0x9d
            return
        }
        if (n == 13) {
            carriageReturn = Some(start)
            carriageStyle = patch
            return
        }
        if (n == 10) {
            output.append(text, patch);
            return
        }
        if (n < 32 || (n >= 127 && n < 160)) {
            output.diagnostics.add(AnsiTextDiagnostic(AnsiTextIssue.UnsupportedSequence, start))
        } else {
            output.append(text, patch)
        }
    }
    private func escape(n: UInt32, output: AnsiTextOutput): Unit {
        // Even an over-budget introducer must enter the proper quarantine.
        if (!intermediate && n == 0x5b) {
            state = AnsiTextState.Csi
            return
        }
        if (!intermediate && (n == 0x5d || n == 0x50 || n == 0x58 || n == 0x5e || n == 0x5f)) {
            state = AnsiTextState.ControlString
            osc = n == 0x5d
            return
        }
        if (n >= 0x20 && n <= 0x2f) {
            intermediate = true
        } else if (n >= 0x30 && n <= 0x7e) {
            issue(output, AnsiTextIssue.UnsupportedSequence)
            state = AnsiTextState.Text
        } else {
            issue(output, AnsiTextIssue.MalformedSequence)
        }
    }
    private func controlSequence(n: UInt32, output: AnsiTextOutput): Unit {
        if (n >= 0x30 && n <= 0x39) {
            if (digits <= 3) {
                digits++
            }
            if (digits > 3) {
                issue(output, AnsiTextIssue.SequenceTooLong)
            }
        } else {
            digits = 0
        }
        if (n == 0x3b) {
            if (parameters <= limits.maxParameters) {
                parameters++
            }
            if (parameters > limits.maxParameters) {
                issue(output, AnsiTextIssue.SequenceTooLong)
            }
        }
        if (n >= 0x40 && n <= 0x7e) {
            if (!fault) {
                if (n != 0x6d || !whitelist) {
                    issue(output, AnsiTextIssue.UnsupportedSequence)
                } else {
                    let raw = "\u{1b}[" + String.fromUtf8(csi.toArray()) + "m"
                    if (let Some(kind) <- applySgr(raw)) {
                        issue(output, kind)
                    }
                }
            }
            csi.clear()
            state = AnsiTextState.Text
        } else if (n >= 0x30 && n <= 0x3f) {
            if (intermediate) {
                issue(output, AnsiTextIssue.MalformedSequence)
            }
            if (!((n >= 0x30 && n <= 0x39) || n == 0x3b)) {
                whitelist = false
            }
            if (!fault && whitelist) {
                csi.add(UInt8(n))
            }
        } else if (n >= 0x20 && n <= 0x2f) {
            intermediate = true
            whitelist = false
        } else {
            issue(output, AnsiTextIssue.MalformedSequence)
        }
    }
    private func applySgr(raw: String): ?AnsiTextIssue {
        let parts = parseCSIParams(raw, terms: "m").getOrThrow()
        var fg = patch.foreground
        var bg = patch.background
        var bold = patch.bold
        var dim = patch.dim
        var italic = patch.italic
        var underline = patch.underline
        var inverse = patch.inverse
        var strike = patch.strikethrough
        var i: Int64 = 0
        // ansies returns an empty array for ESC[m: its one implicit field is zero.
        while (i < parts.size || (i == 0 && parts.isEmpty())) {
            let code = if (parts.isEmpty() || parts[i].isEmpty()) {
                0
            } else {
                decimal(parts[i])
            }
            if (code == 0) {
                fg = Some(Color.Default)
                bg = Some(Color.Default)
                bold = Some(false)
                dim = Some(false)
                italic = Some(false)
                underline = Some(false)
                inverse = Some(false)
                strike = Some(false)
            } else if (code == 1) {
                bold = Some(true)
            } else if (code == 2) {
                dim = Some(true)
            } else if (code == 3) {
                italic = Some(true)
            } else if (code == 4) {
                underline = Some(true)
            } else if (code == 7) {
                inverse = Some(true)
            } else if (code == 9) {
                strike = Some(true)
            } else if (code == 22) {
                bold = Some(false)
                dim = Some(false)
            } else if (code == 23) {
                italic = Some(false)
            } else if (code == 24) {
                underline = Some(false)
            } else if (code == 27) {
                inverse = Some(false)
            } else if (code == 29) {
                strike = Some(false)
            } else if (code == 39) {
                fg = Some(Color.Default)
            } else if (code == 49) {
                bg = Some(Color.Default)
            } else if ((code >= 30 && code <= 37) || (code >= 90 && code <= 97)) {
                fg = Some(namedColor(if (code < 90) {
                    code - 30
                } else {
                    code - 90 + 8
                }))
            } else if ((code >= 40 && code <= 47) || (code >= 100 && code <= 107)) {
                bg = Some(namedColor(if (code < 100) {
                    code - 40
                } else {
                    code - 100 + 8
                }))
            } else if (code == 38 || code == 48) {
                if (i + 1 >= parts.size || parts[i + 1].isEmpty()) {
                    return Some(AnsiTextIssue.MalformedSequence)
                }
                let mode = decimal(parts[i + 1])
                if (mode != 2 && mode != 5) {
                    return Some(AnsiTextIssue.UnsupportedSequence)
                }
                let count = if (mode == 2) {
                    3
                } else {
                    1
                }
                if (i + 1 + count >= parts.size) {
                    return Some(AnsiTextIssue.MalformedSequence)
                }
                for (j in 0..count) {
                    if (parts[i + 2 + j].isEmpty() || decimal(parts[i + 2 + j]) > 255) {
                        return Some(AnsiTextIssue.MalformedSequence)
                    }
                }
                let color = if (mode == 5) {
                    Color.Indexed(UInt8(decimal(parts[i + 2])))
                } else {
                    Color.Rgb(UInt8(decimal(parts[i + 2])), UInt8(decimal(parts[i + 3])), UInt8(decimal(parts[i + 4])))
                }
                if (code == 38) {
                    fg = Some(color)
                } else {
                    bg = Some(color)
                }
                i += 1 + count
            } else {
                return Some(AnsiTextIssue.UnsupportedSequence)
            }
            i++
        }
        patch = TextStylePatch(foreground: fg, background: bg, bold: bold, dim: dim, italic: italic,
            underline: underline, inverse: inverse, strikethrough: strike)
        None
    }
    public func finish(): AnsiTextBatch {
        requireOpen()
        if (!utf8.isEmpty()) {
            fail("InvalidUtf8")
        }
        let output = AnsiTextOutput()
        if (let Some(cr) <- carriageReturn) {
            output.diagnostics.add(AnsiTextDiagnostic(AnsiTextIssue.UnsupportedSequence, cr))
        }
        if (state != AnsiTextState.Text) {
            output.diagnostics.add(AnsiTextDiagnostic(AnsiTextIssue.IncompleteSequence, sequenceOffset))
        }
        closed = true
        carriageReturn = None
        csi.clear()
        output.batch()
    }
}

private func decimal(value: String): Int64 {
    var result: Int64 = 0
    for (byte in value.toArray()) {
        result = result * 10 + Int64(byte - 0x30)
    }
    result
}

private func namedColor(index: Int64): Color {
    [Color.Black, Color.Red, Color.Green, Color.Yellow, Color.Blue, Color.Magenta, Color.Cyan, Color.White,
        Color.BrightBlack, Color.BrightRed, Color.BrightGreen, Color.BrightYellow, Color.BrightBlue, Color.BrightMagenta,
        Color.BrightCyan, Color.BrightWhite][index]
}
