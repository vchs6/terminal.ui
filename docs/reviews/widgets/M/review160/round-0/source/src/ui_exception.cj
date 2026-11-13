package cjtui

public class UIException <: Exception {
    public let code: String
    public init(code: String, message: String) {
        super(message)
        this.code = code
    }
}
