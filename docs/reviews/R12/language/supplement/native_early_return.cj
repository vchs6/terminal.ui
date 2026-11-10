class Early {
    let value: Int64
    init(early: Bool) {
        value = 1
        if (early) { return }
    }
}
main(): Unit { let early = Early(true) }
