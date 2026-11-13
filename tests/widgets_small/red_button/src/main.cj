package widgets_small_red_button

import cjtui.{Button, render}

main(): Int64 {
    let root = Button("go", { => () })
    render(root, 20, 1)
    0
}
