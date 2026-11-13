package cjtui

public func HorizontalMenu(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component {
    let copy = Array<MenuEntry>(items.size, {i => items[i]})
    HorizontalMenu({=> copy}, onChoose)
}

public func HorizontalMenu(items: () -> Array<MenuEntry>, onChoose: (String) -> Unit): Component {
    let refs = MenuRefs()
    Row({=> menuEntries(items, onChoose, refs)})
        .themeRole(ThemeRole.HorizontalMenu)
        .defaultAction({event => menuNavigate(event, refs, true)}, phase: DefaultActionPhase.Ancestor)
}
