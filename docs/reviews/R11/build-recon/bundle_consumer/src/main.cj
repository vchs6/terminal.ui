package macro_consumer
import macro_lib.*
import macro_lib.macros.*
main(): Unit { println("answer=${answer()}; macro=${@Twice(21)}") }
