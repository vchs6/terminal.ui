package widgets_small_negative_checkbox_bool

import cjtui.Checkbox

// Run only after the ordinary factory consumer builds: missing factory is NOT
// evidence that the intentionally forbidden Bool overload was rejected.
main(): Int64 {
    Checkbox(true, { _: Bool => () })
    0
}
