package widgets_composite_missing

import cjtui.*

// Deliberately isolated absent targets; all unrelated public shapes are tested
// by ../prerequisite. No local declarations replace missing product symbols.
main(): Int64 {
    MenuEntry("a", "A")
    HorizontalMenu([], { _: String => () })
    PopupMenu([], { _: String => () })
    StatusBar({ => () })
    SplitPane(body: { => () })
    SplitAxis.Horizontal
    0
}
