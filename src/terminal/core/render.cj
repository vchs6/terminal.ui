package acnl.terminal.core

public interface Render <: Updatable {
    prop col: Int64    //当前光标所在的列号
    prop row: Int64    //当前光标所在的行号
    prop width: Int64
    prop height: Int64
    mut prop autoWrap: Bool     //是否自动换行

    func getConsole(): Option<AnsiConsole>          //连接控制台
    func resize(cols: Int64, rows: Int64): Unit     //重置渲染器的列数和行数
    func setPostion(col: Int64, row: Int64): Unit   //设置光标位置
    func setForeground(color: AnsiColor): Unit      //设置前景色
    func setBackground(color: AnsiColor): Unit      //设置背景色
    func setTextStyles(styles: Array<AnsiTextStyle>): Unit      //设置文本样式
    func write(text: String): Unit      //渲染输出文本
    func write(col: Int64, row: Int64, text: String): Unit
    func flush(): Unit                  //将渲染结果输出到指定的控制台
    func clear(rect!: TRect): Unit      //清除指定区域的内容
    func clear(): Unit                  //清除整个渲染区域

    /*
     * 在指定位置以给定的样式渲染文本
     */
    func writeAt(pos: TPoint, text: String, fg: ?AnsiColor, bg: ?AnsiColor, styles: Array<AnsiTextStyle>) {
        if (let Some(color) <- fg) {setForeground(color)}
        if (let Some(color) <- bg) { setBackground(color)}
        setTextStyles(styles)
        write(pos.col, pos.row, text)
    }

}