package cjtui

class UIThreadIdentity {
    let nonce: Int64 = uniqueRuntimeId()
}

let currentUIThread = ThreadLocal<UIThreadIdentity>()

func uiThreadIdentity(): UIThreadIdentity {
    if (let Some(identity) <- currentUIThread.get()) { return identity }
    let identity = UIThreadIdentity()
    currentUIThread.set(Some(identity))
    identity
}
