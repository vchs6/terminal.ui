package theme_loading_contract
import std.sync.{Condition,Mutex}
class Gate {
    let lock=Mutex()
    var condition:Condition
    var opened=false
    init(){synchronized(lock){condition=lock.condition()}}
    func release():Unit {synchronized(lock){opened=true;condition.notifyAll()}}
    func awaitOpen():Unit {synchronized(lock){if(!condition.waitUntil({=>opened},timeout:Duration.second*5)){throw Exception("background handshake timed out")}}}
}
