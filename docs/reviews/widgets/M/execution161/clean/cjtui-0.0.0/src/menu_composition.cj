package cjtui

import std.collection.ArrayList

func menuEntries(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit, refs: MenuRefs): Unit {
    ForEach<MenuEntry>(items, {entry => entry.key}, {
        item => Text({=> widgetCaption(item.value.label)})
            .themeRole(ThemeRole.MenuItem)
            .focusable(true)
            .enabled({=> item.value.enabled})
            .onMount(
                {
                    ref =>
                        refs.add(ref);
                        {=> refs.remove(ref)}
                }
            )
            .defaultAction({
                event => if (widgetActivation(event)) {
                    event.preventDefault();
                    onChoose(item.key)
                }
            })
    })
}

func menuNavigate(event: UIKeyEvent, refs: MenuRefs, horizontal: Bool): Unit {
    if (!refs.contains(event.target)) {
        return
    }
    if (!event.target.isFocused()) {
        return
    }
    let code = event.key.code
    let previous = if (horizontal) {
        "left"
    } else {
        "up"
    }
    let next = if (horizontal) {
        "right"
    } else {
        "down"
    }
    if (code != previous && code != next && code != "home" && code != "end") {
        return
    }
    let eligible = ArrayList<NodeRef>()
    for (child in event.currentTarget.children()) {
        if (!refs.contains(child) || !child.isValid()) {
            continue
        }
        if (!child.isEnabled()) {
            continue
        }
        if (child.isVisible()) {
            eligible.add(child)
        }
    }
    if (eligible.isEmpty()) {
        return
    }
    var current: Int64 = -1
    for (i in 0..eligible.size) {
        if (eligible[i].sameNode(event.target)) {
            current = i
            break
        }
    }
    if (current < 0) {
        return
    }
    var target = current
    if (code == "home") {
        target = 0
    } else if (code == "end") {
        target = eligible.size - 1
    } else if (code == next) {
        target = (current + 1) % eligible.size
    } else {
        target = (current + eligible.size - 1) % eligible.size
    }
    event.preventDefault()
    if (target != current) {
        eligible[target].requestFocus()
    }
}
