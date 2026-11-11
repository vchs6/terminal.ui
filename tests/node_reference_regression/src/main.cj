package node_reference_regression
import std.env.getCommandLine
main():Int64 {
    if(getCommandLine().contains("controls")){return if(lifetimeControls()){0}else{2}}
    getterGuardAcrossCollection();0
}
