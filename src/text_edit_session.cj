package cjtui

import std.collection.ArrayList
import cjtui.text.graphemeIterator

class TextEditSession {
    let ref: NodeRef
    let source: Observable<String>
    let limits: TextEditLimits
    let multiline: Bool
    let onChange: (String) -> Unit
    let onSubmit: (String) -> Unit
    let onIssue: (TextEditIssue) -> Unit
    let identity = uniqueRuntimeId()
    let signal = Observable<Int64>(0)
    var text: String
    var sourceVersion: Int64
    var selection = TextSelection(0, 0)
    var revision: UInt64 = 0
    var selectionRevision: UInt64 = 0
    var notifying = false
    var preferredColumn: ?Int64 = None
    let undoStack = ArrayList<TextEditRecord>()
    let redoStack = ArrayList<TextEditRecord>()
    init(ref: NodeRef, source: Observable<String>, limits: TextEditLimits, multiline: Bool, onChange: (String) -> Unit,
        onSubmit: (String) -> Unit, onIssue: (TextEditIssue) -> Unit) {
        this.ref = ref
        this.source = source
        this.limits = limits
        this.multiline = multiline
        this.onChange = onChange
        this.onSubmit = onSubmit
        this.onIssue = onIssue
        let (initial, version) = source.editingSnapshot()
        text = initial
        sourceVersion = version
        validate(initial)
    }
    func validate(value: String): Unit {
        if (value.size > limits.maxTextBytes) {
            throw IllegalArgumentException("text too large")
        }
        for (r in value.runes()) {
            let c = UInt32(r)
            if (c == 13 || (c == 10 && !multiline) || (c < 32 && c != 10) || (c >= 127 && c < 160)) {
                throw IllegalArgumentException("invalid editing text")
            }
        }
    }
    func snapshot(): TextEditSnapshot {
        signal.get();
        source.get()
        TextEditSnapshot(text, selection, revision, selectionRevision, !undoStack.isEmpty(), !redoStack.isEmpty(),
            identity, sourceVersion)
    }
    func changed(): Unit {
        signal.set(signal.get() + 1)
        ref.notify(ChangeKind.Layout)
        var x: Int64 = 0;
        var y: Int64 = 0
        let iterator = graphemeIterator(text)
        var index: Int64 = 0
        while (index < selection.caret) {
            match (iterator.next()) {
                case None => break
                case Some(item) =>
                    let cluster = item.toString()
                    if (cluster == "\n") {
                        x = 0
                        y++
                    } else {
                        x += displayWidth(cluster)
                    }
                    index++
            }
        }
        if (ref.isVisible()) {
            ref.ensureEditingCaret(Rect(x, y, 1, 1))
        }
    }
    func applySelection(next: TextSelection, count: Int64): Unit {
        if (next.anchor > count || next.caret > count) {
            throw IllegalArgumentException("selection beyond text")
        }
        preferredColumn = None
        if (next != selection) {
            if (selectionRevision == UInt64.Max) {
                throw UIException("CapacityExceeded", "selection revision exhausted")
            }
            selection = next
            selectionRevision++
            changed()
        }
    }
    func select(next: TextSelection): Unit {
        sync()
        applySelection(next, editingClusterCount(text))
    }
    func selectAll(): Unit {
        sync()
        let count = editingClusterCount(text)
        applySelection(TextSelection(0, count), count)
    }
    func issue(value: TextEditIssue): Unit {
        notifying = true
        try {
            onIssue(value)
        } finally {
            notifying = false
        }
    }
    func sync(): Unit {
        let (latest, version) = source.editingSnapshot()
        if (version == sourceVersion) {
            return
        }
        validate(latest)
        if (revision == UInt64.Max) {
            throw UIException("CapacityExceeded", "text revision exhausted")
        }
        let count = editingClusterCount(latest)
        let next = TextSelection(lesser(selection.anchor, count), lesser(selection.caret, count))
        if (next != selection && selectionRevision == UInt64.Max) {
            throw UIException("CapacityExceeded", "selection revision exhausted")
        }
        text = latest
        sourceVersion = version
        revision++
        if (next != selection) {
            selection = next
            selectionRevision++
        }
        undoStack.clear();
        redoStack.clear()
    }
    // Every ordinary concurrent-value issue originates from this failed
    // expected-version commit, following an atomic source snapshot.
    func commit(next: String, reportConflict: Bool): ?Int64 {
        let result = source.editingCommit(sourceVersion, next)
        if (result.isNone() && reportConflict) {
            sync()
            issue(TextEditIssue.ConcurrentValueChanged)
        }
        result
    }
    func replace(input: String, guard: ?TextEditSnapshot, range!: ?TextSelection = None): Bool {
        let (_, version) = source.editingSnapshot()
        if (let Some(saved) <- guard) {
            if (saved.identity != identity || saved.sourceVersion != version || saved.revision != revision ||
                saved.selectionRevision != selectionRevision) {
                return false
            }
        }
        if (version != sourceVersion) {
            sync()
        }
        let normalized = input.replace("\r\n", "\n").replace("\r", "\n")
        validate(normalized)
        let selectedRange = range ?? selection
        let start = lesser(selectedRange.anchor, selectedRange.caret)
        let end = greater(selectedRange.anchor, selectedRange.caret)
        let before = StringBuilder();
        let after = StringBuilder()
        let iterator = graphemeIterator(text)
        var index: Int64 = 0
        while (true) {
            match (iterator.next()) {
                case None => break
                case Some(item) =>
                    if (index < start) {
                        before.append(item.toString())
                    } else if (index >= end) {
                        after.append(item.toString())
                    }
                    index++
            }
        }
        let prefix = before.toString() + normalized
        let next = prefix + after.toString()
        validate(next)
        var bytes: Int64 = 0;
        var caret: Int64 = 0
        let nextIterator = graphemeIterator(next)
        var nextCount: Int64 = 0
        while (true) {
            match (nextIterator.next()) {
                case None => break
                case Some(item) =>
                    if (bytes < prefix.size) {
                        bytes += item.toString().size
                        caret++
                    }
                    nextCount++
            }
        }
        let nextSelection = TextSelection(caret, caret)
        if (next == text) {
            applySelection(nextSelection, nextCount);
            return false
        }
        if (revision == UInt64.Max || (nextSelection != selection && selectionRevision == UInt64.Max)) {
            throw UIException("CapacityExceeded", "editing revision exhausted")
        }
        let old = text;
        let oldSelection = selection
        let committed = commit(next, guard.isNone())
        if (committed.isNone()) {
            return false
        }
        preferredColumn = None
        text = next
        sourceVersion = committed.getOrThrow()
        revision++
        if (nextSelection != selection) {
            selection = nextSelection
            selectionRevision++
        }
        redoStack.clear();
        undoStack.add(TextEditRecord(old, next, oldSelection, nextSelection))
        var total: Int64 = 0
        for (record in undoStack) {
            total += record.bytes()
        }
        while (undoStack.size > limits.maxUndoEntries || total > limits.maxUndoBytes) {
            total -= undoStack.remove(at: 0).bytes()
        }
        changed();
        notifying = true
        try {
            onChange(text)
        } finally {
            notifying = false
        }
        true
    }
    func selectedByteCount(): Int64 {
        if (selection.anchor == selection.caret) {
            return 0
        }
        let low = lesser(selection.anchor, selection.caret)
        let high = greater(selection.anchor, selection.caret)
        var result: Int64 = 0
        let iterator = graphemeIterator(text)
        var index: Int64 = 0
        while (index < high) {
            match (iterator.next()) {
                case None => break
                case Some(item) =>
                    if (index >= low) {
                        result += item.toString().size
                    }
                    index++
            }
        }
        result
    }
    func keyboardInput(input: String): Unit {
        var invalidControl = false
        for (r in input.runes()) {
            let c = UInt32(r)
            if ((c < 32 && c != 10 && c != 13) || (c >= 127 && c < 160)) {
                invalidControl = true
            }
        }
        if (!multiline && (input.contains("\n") || input.contains("\r"))) {
            issue(TextEditIssue.MultilinePasteRejected);
            return
        }
        if (invalidControl) {
            issue(TextEditIssue.ControlCharacterRejected);
            return
        }
        let normalized = input.replace("\r\n", "\n").replace("\r", "\n")
        let removed = selectedByteCount()
        if (normalized.size > limits.maxTextBytes - (text.size - removed)) {
            issue(TextEditIssue.InputTooLarge);
            return
        }
        replace(normalized, Option<TextEditSnapshot>.None)
    }
    func handle(event: UIKeyEvent): Unit {
        sync()
        let key = event.key
        if (key.code == "text" && !key.ctrl && !key.alt || key.code == "paste") {
            keyboardInput(key.text)
            event.preventDefault();
            return
        }
        if (key.alt) {
            return
        }
        if (key.code == "enter" && key.ctrl) {
            return
        }
        if (key.code == "enter") {
            if (multiline) {
                keyboardInput("\n")
            } else {
                notifying = true
                try {
                    onSubmit(text)
                } finally {
                    notifying = false
                }
            }
            event.preventDefault();
            return
        }
        if (key.ctrl && key.code == "a") {
            selectAll();
            event.preventDefault();
            return
        }
        if (key.ctrl && key.code == "z") {
            undo();
            event.preventDefault();
            return
        }
        if (key.ctrl && key.code == "y") {
            redo();
            event.preventDefault();
            return
        }
        if ((key.ctrl && key.code == "v") || (key.shift && key.code == "insert")) {
            issue(TextEditIssue.PasteFromTerminalRequired);
            event.preventDefault();
            return
        }
        if (key.code == "interrupt" || (key.ctrl && key.code == "insert")) {
            if (selection.anchor != selection.caret) {
                copy(false);
                event.preventDefault()
            } else if (key.code != "interrupt") {
                event.preventDefault()
            }
            return
        }
        if ((key.ctrl && key.code == "x") || (key.shift && key.code == "delete")) {
            copy(true);
            event.preventDefault();
            return
        }
        if (key.ctrl && key.code != "home" && key.code != "end") {
            return
        }
        if (!multiline && (key.code == "up" || key.code == "down" || key.code == "pageup" || key.code == "pagedown")) {
            return
        }
        let iterator = graphemeIterator(text)
        var count: Int64 = 0;
        var row: Int64 = 0;
        var rows: Int64 = 1
        var lineStart: Int64 = 0;
        var lineEnd: ?Int64 = None;
        var column: Int64 = 0
        while (true) {
            match (iterator.next()) {
                case None => break
                case Some(item) =>
                    let cluster = item.toString()
                    if (cluster == "\n") {
                        rows++
                        if (count < selection.caret) {
                            row++;
                            lineStart = count + 1
                            column = 0
                        } else if (lineEnd.isNone()) {
                            lineEnd = Some(count)
                        }
                    } else if (count < selection.caret) {
                        column += displayWidth(cluster)
                    }
                    count++
            }
        }
        if (key.code == "backspace" || key.code == "delete") {
            var deletion = selection
            if (selection.anchor == selection.caret) {
                let other = if (key.code == "backspace") {
                    greater(0, selection.caret - 1)
                } else {
                    lesser(count, selection.caret + 1)
                }
                deletion = TextSelection(selection.caret, other)
            }
            replace("", Option<TextEditSnapshot>.None, range: Some(deletion))
            event.preventDefault();
            return
        }
        var position = selection.caret
        if (multiline && (key.code == "up" || key.code == "down" || key.code == "pageup" || key.code == "pagedown")) {
            let desired = preferredColumn ?? column
            let delta: Int64 = if (key.code == "up" || key.code == "pageup") {
                -1
            } else {
                1
            }
            let steps = if (key.code == "pageup" || key.code == "pagedown") {
                greater(1, ref.viewportSnapshot().height - 1)
            } else {
                1
            }
            let targetRow = lesser(rows - 1, greater(0, row + delta * steps))
            let scan = graphemeIterator(text)
            var scanRow: Int64 = 0;
            var i: Int64 = 0;
            var cursor: Int64 = 0;
            var col: Int64 = 0;
            var frozen = false
            while (true) {
                match (scan.next()) {
                    case None => break
                    case Some(item) =>
                        let cluster = item.toString()
                        if (cluster == "\n") {
                            if (scanRow == targetRow) {
                                break
                            }
                            scanRow++;
                            cursor = i + 1
                        } else if (scanRow == targetRow && !frozen) {
                            let width = displayWidth(cluster)
                            if (desired - col <= col + width - desired) {
                                frozen = true
                            } else {
                                col += width
                                cursor = i + 1
                            }
                        }
                        i++
                }
            }
            select(TextSelection(if (key.shift) {
                selection.anchor
            } else {
                cursor
            }, cursor))
            preferredColumn = Some(desired)
            event.preventDefault();
            return
        }
        preferredColumn = None
        if (key.code == "left") {
            position = if (!key.shift && selection.anchor != selection.caret) {
                lesser(selection.anchor, selection.caret)
            } else {
                greater(0, position - 1)
            }
        } else if (key.code == "right") {
            position = if (!key.shift && selection.anchor != selection.caret) {
                greater(selection.anchor, selection.caret)
            } else {
                lesser(count, position + 1)
            }
        } else if (key.code == "home") {
            position = if (key.ctrl) {
                0
            } else {
                lineStart
            }
        } else if (key.code == "end") {
            position = if (key.ctrl) {
                count
            } else {
                lineEnd ?? count
            }
        } else {
            return
        }
        select(TextSelection(if (key.shift) {
            selection.anchor
        } else {
            position
        }, position))
        event.preventDefault()
    }
    func history(backward: Bool): Bool {
        sync()
        let from = if (backward) {
            undoStack
        } else {
            redoStack
        }
        let to = if (backward) {
            redoStack
        } else {
            undoStack
        }
        if (from.isEmpty()) {
            return false
        }
        let record = from[from.size - 1]
        let next = if (backward) {
            record.before
        } else {
            record.after
        }
        let nextSelection = if (backward) {
            record.beforeSelection
        } else {
            record.afterSelection
        }
        if (revision == UInt64.Max || (nextSelection != selection && selectionRevision == UInt64.Max)) {
            throw UIException("CapacityExceeded", "editing revision exhausted")
        }
        let committed = commit(next, true)
        if (committed.isNone()) {
            return false
        }
        from.remove(at: from.size - 1);
        to.add(record)
        sourceVersion = committed.getOrThrow()
        text = next
        revision++
        if (nextSelection != selection) {
            selection = nextSelection
            selectionRevision++
        }
        changed();
        notifying = true
        try {
            onChange(text)
        } finally {
            notifying = false
        }
        true
    }
    func undo(): Bool {
        history(true)
    }
    func redo(): Bool {
        history(false)
    }
    func copy(cut: Bool): ?SessionResult {
        sync()
        let start = lesser(selection.anchor, selection.caret);
        let end = greater(selection.anchor, selection.caret)
        if (start == end) {
            return None
        }
        let selected = StringBuilder()
        let iterator = graphemeIterator(text)
        var index: Int64 = 0
        while (index < end) {
            match (iterator.next()) {
                case None => break
                case Some(item) =>
                    if (index >= start) {
                        selected.append(item.toString())
                    }
                    index++
            }
        }
        let guard = snapshot()
        let result = ref.application().copyLocalText(selected.toString())
        if (cut) {
            if (result.status == SessionStatus.Applied) {
                let isCopy = match (result.operation) {
                    case SessionOperation.CopyLocalText => true;
                    case _ => false
                }
                var committed = false
                if (isCopy) {
                    if (ref.isValid()) {
                        if (result.sessionId == ref.resolve().session.id) {
                            committed = replace("", Some(guard))
                        }
                    }
                }
                if (!committed) {
                    issue(TextEditIssue.CutStale)
                }
            } else if (result.status == SessionStatus.SentUnconfirmed) {
                issue(TextEditIssue.CutUnconfirmed)
            } else {
                issue(TextEditIssue.ClipboardUnavailable)
            }
        } else if (result.status != SessionStatus.Applied && result.status != SessionStatus.SentUnconfirmed) {
            issue(TextEditIssue.ClipboardUnavailable)
        }
        Some(result)
    }
}
