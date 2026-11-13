package interaction_c

import cjtui.*

func pendingCancellation(): Unit {
    let root = Column {Text("base")}.viewport(ScrollAxes.Off)
    let app = Application(root)
    let mounts = Box<Int64>(0)
    let cleanups = Box<Int64>(0)
    let saved = Box<?OverlayHandle>(None)
    app.startHeadless()
    app.batch(
        {
            =>
                let content = Text("never").onMount(
                    {
                        _ =>
                            mounts.value++
                            {=> cleanups.value++}
                    }
                )
                let handle = node(root).openOverlay(content)
                saved.value = Some(handle)
                check(handle.isOpen() && handle.content().isNone() && reason(handle) == "None",
                    "P01 accepted pending is open but unpublished")
                handle.close()
        }
    )
    let handle = saved.value.getOrThrow()
    check(!handle.isOpen() && handle.content().isNone() && reason(handle) == "Requested",
        "P01 pending cancellation has immutable terminal reason")
    check(mounts.value == 0 && cleanups.value == 0, "P01 cancelled content never mounts or cleans")
    app.batch({=> handle.close()})
    check(reason(handle) == "Requested", "P02 close is idempotent in original UI domain")
    app.dispose()
    check(!handle.isOpen() && reason(handle) == "Requested" && handle.content().isNone(),
        "P02 original-thread terminal query survives dispose")
    released(app, "P02 no retained mounted resources")
}

func sharedTypeAndIdentity(): Unit {
    let model = Observable<String>("A")
    let ordinary = Box<?SettingsPanel>(None)
    let root = Column {
        let panel = SettingsPanel(model)
        panel.width(3).height(1)
        ordinary.value = Some(panel)
        Text("tailtail")
    }.viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    let owner = node(root)
    let before = owner.children()
    let normal = ordinary.value.getOrThrow()
    let normalRef = node(normal)
    let layer = SettingsPanel(model)
    layer.width(3).height(1)
    let handle = Box<?OverlayHandle>(None)
    app.batch({
        => handle.value = Some(
            owner.openOverlay(layer, options: OverlayOptions(mode: OverlayMode.NonModal, takeFocus: false)))
    })
    let mounted = handle.value.getOrThrow().content().getOrThrow()
    check(mounted.sameNode(node(layer)), "N01 handle publishes the actual custom-component mount")
    let after = owner.children()
    check(after.size == before.size && after[0].sameNode(before[0]) && after[1].sameNode(before[1]),
        "N01 overlay never enters ordinary child sequence")
    picture(app.snapshot(8, 3), "A       \ntaAltail\n        ",
        "N02 same SettingsPanel type in normal and layer positions")
    model.set("BC")
    picture(app.snapshot(8, 3), "BC      \ntaBCtail\n        ", "N02 one business model updates both real instances")
    app.snapshot(10, 5)
    check(
        mounted.sameNode(handle.value.getOrThrow().content().getOrThrow()) && normalRef.sameNode(node(normal)) &&
            normal.builds == 1 && layer.builds == 1,
        "N03 host resize repositions without rebuilding or changing identities")
    app.batch({=> handle.value.getOrThrow().close()})
    check(!mounted.isValid() && normalRef.isValid(), "N03 layer close revokes only layer generation")
    app.dispose()
}
