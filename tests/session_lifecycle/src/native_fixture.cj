package session_lifecycle

foreign {
    func cjt_lifecycle_owner(): Int32
    func cjt_lifecycle_eof(buffered: Int32): Int32
}
