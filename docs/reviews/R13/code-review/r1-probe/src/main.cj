package dynamic_review_probe

import cjtui.*
import std.collection.ArrayList

func manualInvalidSubtree(): Bool {
    let observed = ArrayList<String>()
    let parent = RefBox()
    let root = Column {
        Text("old").onMount { _ => { =>
            let rr = parent.value.getOrThrow()
            if (rr.isValid()) {
                observed.add("old-cleanup:active-parent,children=${rr.children().size}")
            } else {
                observed.add("old-cleanup:session-stopped")
            }
        } }
    }
    let app = Application(root)
    app.startHeadless()
    parent.value = root.reference()
    let rr = parent.value.getOrThrow()
    let old = rr.children()[0]
    let invalid = Column {
        ForEach<String>({ => ["dup", "dup"] }, { value => value }, { item => Text(item.value) })
    }
    try {
        app.batch {
            => rr.append(invalid)
            rr.remove(old)
        }
    } catch (error: UIException) {
        println("manual:error=${error.code}")
    }
    println("manual:${observed[0]}")
    app.dispose()
    observed[0] == "old-cleanup:session-stopped"
}

func replacementInvalidSubtree(): Bool {
    let observed = ArrayList<String>()
    let data = Observable<Array<String>>(["old"])
    let parent = RefBox()
    let root = Column {
        ForEach<String>({ => data.get() }, { value => value }, { item =>
            Column {
                if (item.key == "new") {
                    ForEach<String>({ => ["dup", "dup"] }, { value => value }, { inner => Text(inner.value) })
                } else {
                    Text("old")
                }
            }.onMount { _ => { =>
                let rr = parent.value.getOrThrow()
                if (rr.isValid()) {
                    observed.add("old-cleanup:active-parent,children=${rr.children().size}")
                } else {
                    observed.add("old-cleanup:session-stopped")
                }
            } }
        })
    }
    let app = Application(root)
    app.startHeadless()
    parent.value = root.reference()
    data.set(["new"])
    try { app.snapshot(10, 4) } catch (error: UIException) {
        println("replacement:error=${error.code}")
    }
    println("replacement:${observed[0]}")
    app.dispose()
    observed[0] == "old-cleanup:session-stopped"
}

main(): Int64 {
    let first = manualInvalidSubtree()
    let second = replacementInvalidSubtree()
    if (first && second) { 0 } else { 1 }
}
