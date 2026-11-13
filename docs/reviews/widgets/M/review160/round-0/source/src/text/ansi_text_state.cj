package cjtui.text

enum AnsiTextState <: Equatable<AnsiTextState> {
    Text | Escape | Csi | ControlString // cjlint-ignore !G.ENU.01 Internal state and public Text constructor are distinct.

    public operator func ==(other: AnsiTextState): Bool {
        match ((this, other)) {
            case (Text, Text) | (Escape, Escape) | (Csi, Csi) | (ControlString, ControlString) => true
            case _ => false
        }
    }
}
