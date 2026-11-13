package widgets_small_red_progress

import cjtui.{Progress, render}

main(): Int64 {
    let root = Progress(0.5)
    render(root, 20, 1)
    0
}
