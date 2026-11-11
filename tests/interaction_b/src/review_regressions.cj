package interaction_b
func reviewRegression(name:String):Int64 {
    match(name){
        case "I01"=>reviewHorizontalWeights()
        case "I02"=>reviewMixedBarrier()
        case "I03"=>reviewLocalViewportResize()
        case "I04"=>reviewMountedViewportExport()
        case "I05"=>reviewGrowingExtentEnsure()
        case "I06"=>reviewFiniteNonScrollConstraint()
        case "I07"=>reviewCandidateAfterInvalidation()
        case "I05-stable"=>reviewStableDirtyExtentEnsure()
        case "I08"=>reviewIntermediateMeasureDependency()
        case _=>throw Exception("unknown B review case ${name}")
    }
    println("PASS B review ${name}");0
}
