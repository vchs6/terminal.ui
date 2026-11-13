package widgets_small_negative_radio_bool

import cjtui.Radio

// Run only after the ordinary factory consumer builds: missing factory is NOT
// evidence that the intentionally forbidden Bool overload was rejected.
main(): Int64 {
    Radio(true, { => () })
    0
}
