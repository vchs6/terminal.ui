package interaction_a_contract
func reviewRegression(name:String):Int64 {
    match(name){
        case "I01"=>effectiveMeasureDependencies()
        case "I02-focus"=>behaviorStateGeometry("focus")
        case "I02-constant"=>behaviorStateGeometry("constant")
        case "I02-getter"=>behaviorStateGeometry("getter")
        case "I03-focus-focus"=>focusCommandCapacity("focus-focus")
        case "I03-append-focus"=>focusCommandCapacity("append-focus")
        case "I03-focus-append"=>focusCommandCapacity("focus-append")
        case "I04"=>enabledVisibilityIndependence()
        case "I06-node"=>cancelUnmountedFocus(false)
        case "I06-ancestor"=>cancelUnmountedFocus(true)
        case "I07-root"=>canvasLeafStructure(false)
        case "I07-nested"=>canvasLeafStructure(true)
        case _=>throw Exception("unknown focused regression ${name}")
    }
    println("PASS focused regression ${name}");0
}
