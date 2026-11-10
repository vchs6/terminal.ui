package cjtui.text

enum AnsiTextState <: Equatable<AnsiTextState> {
    Text | Escape | Csi | ControlString

    public operator func ==(other: AnsiTextState): Bool {
        match ((this, other)) {
            case (Text, Text) | (Escape, Escape) | (Csi, Csi) | (ControlString, ControlString) => true
            case _ => false
        }
    }
}
