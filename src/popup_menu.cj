package cjtui

public func PopupMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component {
    let copy = Array<MenuEntry>(items.size, {i => items[i]})
    PopupMenu({=> copy}, onChoose)
}

public func PopupMenu(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit): Component {
    let refs = MenuRefs()
    Column({=> menuEntries(items, onChoose, refs)})
        .themeRole(ThemeRole.PopupMenu)
        .surface(SurfaceMode.Opaque)
        .defaultAction({event => menuNavigate(event, refs, false)}, phase: DefaultActionPhase.Ancestor)
}
