package theme_loading_gate_probe
import std.fs.*
foreign {func chdir(path:CString):Int32}
func sync(name:String):Unit {
    print("SYNC ${name}\n",flush:true)
    if(readln()!="OK ${name}"){throw Exception("infrastructure barrier reply mismatch")}
}
main(args:Array<String>):Int64 {
    let root=args[1]
    let worker=spawn{String.fromUtf8(File.readFrom(root+"/gate-probe.toml"))}
    sync("entered:gate-probe.toml:1")
    sync("release:gate-probe.toml:1")
    if(worker.get(Duration.second*5)!="schema_version=1\nname=\"Probe\"\n"){throw Exception("test interposer changed real file bytes")}
    let path=unsafe{LibC.mallocCString(root+"/other")}
    let changed=unsafe{chdir(path)}
    unsafe{LibC.free(path)}
    if(changed!=0 || String.fromUtf8(File.readFrom("marker"))!="cwd-ok"){throw Exception("real cwd infrastructure failed")}
    println("PASS CASE infrastructure")
    0
}
