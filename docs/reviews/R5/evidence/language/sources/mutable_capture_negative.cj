func Keep(action: () -> Unit): () -> Unit { action }
main() {
    var count = 0
    let action = Keep { count++ }
    action()
}
