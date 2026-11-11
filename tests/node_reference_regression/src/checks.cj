package node_reference_regression
import cjtui.*
func check(value:Bool,message:String):Unit {if(!value){throw Exception("FAIL: "+message)}}
func expectCode(expected:String,action:()->Unit,label:String):Unit {
    var actual="NO_EXCEPTION"
    try{action()}catch(error:UIException){actual=error.code}
    check(actual==expected,"${label}: expected=${expected}, actual=${actual}")
}
