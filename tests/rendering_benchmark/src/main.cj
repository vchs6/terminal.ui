package rendering_benchmark_tests

main(args: Array<String>): Int64 {
    try {
        demand(args.size > 0, "usage: validator samples|cells|carets|compare-cells|compare-carets|process|output ...")
        let mode = args[0]
        if (mode == "samples") {
            demand(args.size == 10, "samples CSV COLUMNS RUN_METADATA RUN_ID SCENARIO MODE WIDTH HEIGHT REPETITION")
            validateSamples(args[1],args[2],args[3],args[4],args[5],args[6],natural(args[7],"width"),natural(args[8],"height"),natural(args[9],"repetition"))
        } else if (mode == "cells" || mode == "carets") {
            demand(args.size == 7, "cells|carets CSV SCENARIO WIDTH HEIGHT PERIOD diagnostic|compat")
            oneOf(args[6],["diagnostic","compat"],"project")
            let width = natural(args[3],"width"); let height = natural(args[4],"height")
            let period = natural(args[5],"period")
            if (mode == "cells") { validateCells(args[1],args[2],width,height,period,args[6] == "compat") }
            else { validateCarets(args[1],args[2],width,height,period,args[6] == "compat") }
        } else if (mode == "compare-cells" || mode == "compare-carets") {
            demand(args.size == 7, "compare-cells|compare-carets OLD NEW SCENARIO WIDTH HEIGHT PERIOD")
            let width = natural(args[4],"width"); let height = natural(args[5],"height")
            let period = natural(args[6],"period")
            if (mode == "compare-cells") { compareCells(args[1],args[2],args[3],width,height,period) }
            else { compareCarets(args[1],args[2],args[3],width,height,period) }
        } else if (mode == "process") {
            demand(args.size == 3,"process CSV EXPECTED_RUN_ID"); validateProcess(args[1],args[2])
        } else if (mode == "output") {
            demand(args.size == 2,"output CSV"); validateOutput(args[1])
        } else if (mode == "selftest") {
            demand(args.size == 2,"selftest FIXTURE_DIR"); validatorSelftest(args[1])
        } else { throw Exception("unknown validator mode ${mode}") }
        println("VALID ${mode}"); 0
    } catch (error: Exception) {
        println("INVALID ${error.message}"); 1
    }
}
