package theme_loading_contract
class TestEnvironment {
    let root:String
    init(root:String){this.root=root}
    func path(name:String):String {root+"/"+name}
    func sync(name:String):Unit {
        print("SYNC ${name}\n",flush:true)
        if(readln()!="OK ${name}"){throw Exception("test-process barrier failed ${name}")}
    }
    func entered(name:String,sequence!:Int64=1):Unit {sync("entered:"+name+":"+sequence.toString())}
    func release(name:String,sequence!:Int64=1):Unit {sync("release:"+name+":"+sequence.toString())}
    func write(name:String,fixture:String):Unit {sync("write:"+name+":"+fixture)}
}
