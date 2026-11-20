package cjtui_composition
import cjtui.*
import std.unicode.*
import std.collection.ArrayList

class JobData {
    let notes = Observable<String>("Check input")
    let stage = Observable<Int64>(0)
    let firstResult = Observable<Int64>(0)
    let secondResult = Observable<Int64>(0)
    let acknowledged = Observable<Bool>(false)
    let query = Observable<String>("")
    let hideDone = Observable<Bool>(false)
    let nameOrder = Observable<Bool>(false)
    let logQuery = Observable<String>("")
    let errorsOnly = Observable<Bool>(false)
    let newest = Observable<Bool>(false)
    let logsScene = Observable<Bool>(false)
    let light = Observable<Bool>(false)

    func themeName(): String { if (light.get()) { "Light" } else { "Classic" } }
    func phase(): String {
        match (stage.get()) {
            case 0 => "Idle"
            case 1 => "Waiting for review: Parse complete"
            case _ => "Done"
        }
    }
    func jobPhase(): String { if (stage.get() == 0) { "Ready" } else { "Done ${firstResult.get()}" } }
    func status(): String {
        if (logsScene.get()) { "Logs | ${logRows().size}/24 | ${themeName()}" }
        else {
            let text = match (stage.get()) { case 0 => "Ready 0/2"; case 1 => "Review 1/2"; case _ => "Done 2/2" }
            "Tasks | ${text} | ${themeName()}"
        }
    }
    func taskRows(): Array<String> {
        let rows = ArrayList<String>()
        let order = if (nameOrder.get()) { [2, 0, 1] } else { [0, 1, 2] }
        let names = ["Parse", "Render", "Export"]
        for (i in order) {
            let done = i == 2 || (i == 0 && stage.get() >= 1) || (i == 1 && stage.get() >= 2)
            if ((!hideDone.get() || !done) && names[i].toLower().contains(query.get().toLower())) {
                let suffix = if (i == 0 && stage.get() >= 1) { " ${firstResult.get()}" } else if (i == 1 && stage.get() >= 2) { " ${secondResult.get()}" } else { "" }
                let state = if (done) { "Done" } else { "Ready" }
                rows.add("0${i + 1} ${state} ${names[i]}${suffix}")
            }
        }
        rows.toArray()
    }
    func logRows(): Array<String> {
        let rows = ArrayList<String>()
        for (index in 1..25) {
            let i = if (newest.get()) { 25 - index } else { index }
            let num = if (i < 10) { "0${i}" } else { "${i}" }
            let severity = if (i % 3 == 0) { "ERROR" } else { "INFO" }
            let row = "0${num} ${severity} record ${num}"
            if ((!errorsOnly.get() || i % 3 == 0) && row.toLower().contains(logQuery.get().toLower())) { rows.add(row) }
        }
        rows.toArray()
    }
}
