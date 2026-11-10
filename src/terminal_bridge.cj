package cjtui

foreign {
    func cjt_open(): Int32

    func cjt_close(): Int32

    func cjt_size(axis: Int32): Int32

    func cjt_read(timeout: Int32): Int32

    func cjt_buffer_clear(): Unit

    func cjt_buffer_add(value: Int32): Int32

    func cjt_buffer_write(): Int32

    func cjt_capabilities_detect(): Int64
}

func readByte(timeout: Int32): Int32 {
    unsafe { cjt_read(timeout) }
}

func writeScreen(value: String): Unit {
    unsafe {
        cjt_buffer_clear()
        for (b in value.toArray()) {
            if (cjt_buffer_add(Int32(b)) != 0) {
                throw Exception("terminal output allocation failed")
            }
        }
        if (cjt_buffer_write() != 0) {
            throw Exception("terminal write failed; display synchronization lost")
        }
    }
}
