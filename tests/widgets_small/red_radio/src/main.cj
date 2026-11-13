package widgets_small_red_radio

import cjtui.{Radio, render}

main(): Int64 {
    let root = Radio({ => false }, { => () })
    render(root, 20, 1)
    0
}
