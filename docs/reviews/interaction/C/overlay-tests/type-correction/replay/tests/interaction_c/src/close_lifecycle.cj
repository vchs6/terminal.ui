package interaction_c

import cjtui.*

func dependentClosure(): Unit {
    let owner = Box<?Component>(Option<Component>.None)
    let root = Column {
        owner.value = Some(Text("owner").focusable(true))
        Text("sibling").focusable(true)
    }.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let trace = Box<String>("")
    let watched = Observable<String>("A")
    let inner = Box<?NodeRef>(Option<NodeRef>.None)
    let outerRef = Box<?NodeRef>(Option<NodeRef>.None)
    let outer = Column {Text({=> watched.get()})}.onMount(
        {
            reference =>
                outerRef.value = Some(reference)
                {
                    =>
                        check(!outerRef.value.getOrThrow().isValid() && !inner.value.getOrThrow().isValid(),
                            "L01 complete dependent closure invalid before any parent cleanup")
                        check(app.stats().subscriptions == 0 && app.stats().pendingPosts == 0,
                            "L01 closed subscriptions and owner work revoked before cleanup")
                        trace.value += "O;"
                }
        }
    )
    let child = Text("child").onMount(
        {
            reference =>
                inner.value = Some(reference)
                {
                    =>
                        check(!outerRef.value.getOrThrow().isValid() && !inner.value.getOrThrow().isValid(),
                            "L01 all dependent tokens revoked before deepest cleanup")
                        trace.value += "I;"
                }
        }
    )
    let first = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let nested = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let sibling = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({
        => first.value = Some(
            node(owner.value.getOrThrow()).openOverlay(outer, options: OverlayOptions(takeFocus: false)))
    })
    app.batch({
        => nested.value = Some(node(outer).openOverlay(child, options: OverlayOptions(takeFocus: false)))
    })
    let unrelated = Text("unrelated").focusable(true)
    app.batch({=> sibling.value = Some(node(root).openOverlay(unrelated))})
    let siblingRef = node(unrelated)
    app.batch({=> owner.value.getOrThrow().enabled(false)})
    check(node(outer).isEnabled() && first.value.getOrThrow().isOpen(),
        "L02 owner disabled neither closes layer nor crosses ownership enabled boundary")
    app.batch(
        {
            =>
                check(app.post(inner.value.getOrThrow(), {=> trace.value += "BAD;"}),
                    "L01 dependent work accepted within the closing turn")
                owner.value.getOrThrow().visible(false)
        }
    )
    check(reason(first.value.getOrThrow()) == "OwnerHidden" && !nested.value.getOrThrow().isOpen(),
        "L03 owner hidden closes complete dependent closure")
    check(trace.value == "I;O;", "L03 dependent deepest layer cleans before parent exactly once")
    check(sibling.value.getOrThrow().isOpen() && siblingRef.isValid(),
        "L04 higher unrelated sibling survives non-top close")
    focused(app, siblingRef, "L04 background closure never steals current sibling focus")
    app.snapshot(10, 3)
    check(trace.value == "I;O;", "L03 cancelled owner work never runs after close")
    app.dispose()
    check(trace.value == "I;O;", "L03 closed cleanups not repeated by session dispose")
}

func savedFocusFallback(): Unit {
    let first = Box<?Component>(Option<Component>.None)
    let next = Box<?Component>(Option<Component>.None)
    let previous = Box<?Component>(Option<Component>.None)
    let root = Column {
        previous.value = Some(Text("previous").focusable(true))
        first.value = Some(Text("saved").focusable(true))
        next.value = Some(Text("next").focusable(true))
    }.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    app.batch({=> node(first.value.getOrThrow()).requestFocus()})
    let layer = Text("modal").focusable(true)
    let handle = Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({
        => handle.value = Some(
            node(first.value.getOrThrow()).openOverlay(layer, options: OverlayOptions(mode: OverlayMode.Modal)))
    })
    app.batch({=> first.value.getOrThrow().enabled(false)})
    check(node(layer).isEnabled(), "F08 disabled saved trigger leaves modal eligible")
    app.batch({=> handle.value.getOrThrow().close()})
    // C.4 nearest surviving owner ancestor (root) has first eligible = previous.
    // This precedence intentionally comes before A's old physical successor.
    focused(app, node(previous.value.getOrThrow()),
        "F09 disabled saved ref falls back to nearest owner ancestor first eligible")
    app.dispose()
}

func cleanupAggregation(): Unit {
    let root = Column {Text("base")}.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let trace = Box<String>("")
    let parentError = Exception("OVERLAY_PARENT_CLEANUP")
    let childError = Exception("OVERLAY_CHILD_CLEANUP")
    let parent = Text("parent").onMount({
        _ => {
            =>
                trace.value += "P;"
                throw parentError
        }
    })
    let child = Text("child").onMount({
        _ => {
            =>
                trace.value += "C;"
                throw childError
        }
    })
    app.batch(
        {
            =>
                node(root).openOverlay(parent, options: OverlayOptions(takeFocus: false));
                ()
        }
    )
    app.batch(
        {
            =>
                node(parent).openOverlay(child, options: OverlayOptions(takeFocus: false));
                ()
        }
    )
    var caught = false
    try {
        app.dispose()
    } catch (error: UICleanupException) {
        caught = true
        check(
            refEq(error.primary, childError) && error.cleanupFailures.size == 1 && refEq(error.cleanupFailures[0],
                parentError), "L05 aggregate preserves deepest first error objects and order")
    }
    check(caught && trace.value == "C;P;", "L05 every dependent cleanup attempted once despite exceptions")
    released(app, "L05 exception shutdown releases all resources")
    app.dispose()
    check(trace.value == "C;P;", "L05 second dispose repeats no throwing cleanup")
}
