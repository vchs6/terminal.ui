package interaction_c

import cjtui.*

func entryValidation(): Unit {
    let ordinary = Box<?Component>(None)
    let stranger = Box<?Component>(None)
    let root = Column {
        ordinary.value = Some(Text("owner"))
        stranger.value = Some(Column {Text("not ancestor")}.overlayHost(true))
    }.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    app.batch(
        {
            =>
                illegal(
                    {
                        =>
                            node(root).openOverlay(Text("x"),
                                options: OverlayOptions(mode: OverlayMode.Modal, takeFocus: false));
                            ()
                    },
                    "E01 modal cannot opt out of focus"
                )
                illegal(
                    {
                        =>
                            node(root).openOverlay(Text("x"), options: OverlayOptions(mode: OverlayMode.Passive));
                            ()
                    },
                    "E02 passive rejects default takeFocus true conflict"
                )
                illegal(
                    {
                        =>
                            node(root).openOverlay(Text("x"),
                                options: OverlayOptions(mode: OverlayMode.Modal,
                                    anchor: Some(node(ordinary.value.getOrThrow()))));
                            ()
                    },
                    "E03 modal rejects anchor"
                )
                illegal(
                    {
                        =>
                            node(root).openOverlay(Text("x"),
                                options: OverlayOptions(placement: OverlayPlacement.BelowStart));
                            ()
                    },
                    "E04 directional placement requires anchor"
                )
                code(
                    "InvalidOverlayHost",
                    {
                        =>
                            node(ordinary.value.getOrThrow()).openOverlay(Text("x"),
                                options: OverlayOptions(host: Some(node(stranger.value.getOrThrow()))));
                            ()
                    },
                    "E05 host must be owner or logical ancestor"
                )
                code(
                    "InvalidOverlayHost",
                    {
                        =>
                            node(ordinary.value.getOrThrow()).openOverlay(Text("x"),
                                options: OverlayOptions(host: Some(node(ordinary.value.getOrThrow()))));
                            ()
                    },
                    "E06 explicit host requires capability"
                )
                code(
                    "InvalidOverlayAnchor",
                    {
                        =>
                            node(ordinary.value.getOrThrow()).openOverlay(Text("x"),
                                options: OverlayOptions(anchor: Some(node(stranger.value.getOrThrow())),
                                    placement: OverlayPlacement.BelowStart));
                            ()
                    },
                    "E07 anchor must be owner or logical descendant"
                )
                code(
                    "AlreadyMounted",
                    {
                        =>
                            node(root).openOverlay(ordinary.value.getOrThrow());
                            ()
                    },
                    "E08 mounted content cannot be reused as a layer"
                )
        }
    )
    check(node(ordinary.value.getOrThrow()).isValid(), "E08 rejected duplicate leaves original generation valid")
    let stale = node(ordinary.value.getOrThrow())
    app.batch({=> node(root).remove(stale)})
    code("StaleReference", {
        => app.batch(
            {
                =>
                    stale.openOverlay(Text("x"));
                    ()
            }
        )
    }, "E09 stale owner rejects before opening")
    app.dispose()
}

func foreignAndOldHandles(): Unit {
    let root = Column {Text("one")}.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let handle = Box<?OverlayHandle>(None)
    app.batch({=> handle.value = Some(node(root).openOverlay(Text("layer"), options: OverlayOptions(takeFocus: false)))})
    app.dispose()
    let old = handle.value.getOrThrow()
    check(!old.isOpen() && old.content().isNone(), "E10 terminal old handle remains readable in original UI domain")
    app.startHeadless()
    app.batch(
        {
            =>
                code(
                    "WrongUIContext",
                    {
                        =>
                            old.isOpen();
                            ()
                    },
                    "E11 old handle query in new active session rejected"
                )
                code("WrongUIContext", {=> old.close()}, "E11 closed no-op does not bypass session check")
        }
    )
    app.dispose()
    let otherRoot = Column {Text("two")}.viewport(ScrollAxes.Off)
    let second = Application(otherRoot)
    app.startHeadless()
    second.startHeadless()
    let foreignHost = node(otherRoot)
    app.batch({
        => code(
            "WrongUIContext",
            {
                =>
                    node(root).openOverlay(Text("foreign"), options: OverlayOptions(host: Some(foreignHost)));
                    ()
            },
            "E12 foreign-session host rejected"
        )
    })
    app.dispose()
    second.dispose()
}
