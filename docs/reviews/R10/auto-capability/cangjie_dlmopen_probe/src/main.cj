package cangjie_dlmopen_probe

foreign {
    func cangjie_dlmopen_probe(): Int64
}

main(): Int64 {
    let packed = unsafe { cangjie_dlmopen_probe() }
    println("dlmopen_packed=${packed}")
    if (packed != 4295033088) {
        return 1
    }
    return 0
}
