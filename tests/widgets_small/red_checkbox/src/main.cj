package widgets_small_red_checkbox

import cjtui.{Checkbox, render}

main(): Int64 {
    let root = Checkbox({ => false }, { _: Bool => () })
    render(root, 20, 1)
    0
}
