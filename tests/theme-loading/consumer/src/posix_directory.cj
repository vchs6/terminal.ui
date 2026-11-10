package theme_loading_contract
foreign {func chdir(path:CString):Int32}
func changeDirectory(path:String):Unit {
    let text=unsafe{LibC.mallocCString(path)}
    let result=unsafe{chdir(text)}
    unsafe{LibC.free(text)}
    if(result!=0){throw Exception("test chdir failed")}
}
