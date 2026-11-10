package cjtui

foreign {
    func cjt_open(): Int32

    func cjt_close(): Int32

    func cjt_size_snapshot(): Int64

    func cjt_read(timeout: Int32): Int32

    func cjt_buffer_clear(): Unit

    func cjt_buffer_add(value: Int32): Int32

    func cjt_buffer_write(): Int32

    func cjt_buffer_emitted(): Int64

    func cjt_output_unsafe(): Int32

    func cjt_capabilities_detect(): Int64
}

func readTerminalSize(): (Int64, Int64) {
    let size = unsafe { cjt_size_snapshot() }
    if (size < 0) {
        return (-1, -1)
    }
    let dimensionBase: Int64 = 4294967296
    (size / dimensionBase, size % dimensionBase)
}

func readByte(timeout: Int32): Int32 {
    unsafe { cjt_read(timeout) }
}

// Both screen frames and optional operations use this same native buffer/writer.
func writeTerminal(value: String, session: RuntimeSession, checkCancel: Bool): SessionWriteResult {
    unsafe {
        if (cjt_output_unsafe() != 0) {
            return SessionWriteResult(0, SessionIssue.ParserUnsynchronized, false)
        }
        cjt_buffer_clear()
        for (b in value.toArray()) {
            if (cjt_buffer_add(Int32(b)) != 0) {
                return SessionWriteResult(0, SessionIssue.AllocationFailed, false)
            }
        }
        // Serialize requestStop's state change with the first native write.
        // Once committed to a logical sequence, stop cannot split its bytes.
        session.lock.lock()
        try {
            if (checkCancel && session.stopping) {
                return SessionWriteResult(0, SessionIssue.Cancelled, false)
            }
            if (cjt_buffer_write() != 0) {
                return SessionWriteResult(cjt_buffer_emitted(), SessionIssue.WriteFailed, true)
            }
            return SessionWriteResult(cjt_buffer_emitted(), SessionIssue.NoIssue, true)
        } finally {
            session.lock.unlock()
        }
    }
}

// Reserve the shared native buffer before the first save+set transaction byte.
func prepareTerminalSequence(value: String): Bool {
    unsafe {
        cjt_buffer_clear()
        for (byte in value.toArray()) {
            if (cjt_buffer_add(Int32(byte)) != 0) {
                cjt_buffer_clear();
                return false
            }
        }
        cjt_buffer_clear()
    }
    true
}
