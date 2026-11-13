package widgets_small_contract

import cjtui.{Application, Button, Column, KeyEvent, Label, Observable, RuntimeStats}

func noResources(stats: RuntimeStats, name: String): Unit {
    assertLifetime(stats.mountedNodes == 0 && stats.activeBindings == 0 && stats.subscriptions == 0 &&
        stats.pendingPosts == 0, name)
}

func remountAndWorkerPosts(): Unit {
    let model = Observable<Int64>(7)
    let cleanup = [0]
    let root = Column {
        Button({=> "${model.get()}"}, {=> model.set(model.get() + 1)}).onMount({_ => {=> cleanup[0]++}})
    }
    let app = Application(root)
    app.startHeadless()
    equal(app.snapshot(2, 1).toPlainText(), "7 ", "first mount uses business state")
    let parent = root.reference().getOrThrow()
    let old = parent.children()[0]
    let staleRan = [false]
    app.batch(
        {
            =>
                parent.remove(old)
                // Join is the handshake: the owner-scoped action is definitely queued
                // while old is still committed; removal commits at this batch boundary.
                let accepted = spawn {=> app.post(old, {=> staleRan[0] = true})}
                assertLifetime(accepted.get(), "old owner post accepted before removal commits")
        }
    )
    assertLifetime(!old.isValid() && cleanup[0] == 1 && model.get() == 7,
        "unmount revokes generation, preserves model, cleans once")
    app.snapshot(2, 1)
    assertLifetime(!staleRan[0], "queued action for removed generation is discarded")
    let fresh = Button({=> "${model.get()}"}, {=> model.set(model.get() + 1)}).onMount({_ => {=> cleanup[0]++}})
    parent.append(fresh)
    equal(app.snapshot(2, 1).toPlainText(), "7 ", "new instance remount retains model")
    let current = fresh.reference().getOrThrow()
    assertLifetime(!old.isValid() && !old.sameNode(current), "same model new generation never revives old ref")
    let posted = spawn {=> app.post(current, {=> model.set(9)})}
    assertLifetime(posted.get(), "live owner worker post accepted")
    equal(app.snapshot(2, 1).toPlainText(), "9 ", "worker post updates public model on UI turn")
    assertLifetime(!app.post(old, {=> staleRan[0] = true}), "stale owner post rejected")
    app.batch({=> current.requestFocus()})
    assertLifetime(current.isFocused(), "remounted control focused before positive activation")
    app.dispatch(current, KeyEvent("enter"))
    assertLifetime(model.get() == 10, "remounted callback updates model once")
    app.dispose();
    app.dispose()
    assertLifetime(cleanup[0] == 2 && !current.isValid() && !old.isValid(), "each generation cleanup exactly once")
    noResources(app.stats(), "remount session resources zero")

    let failureModel = Observable<String>("ok")
    let failuresCleaned = [0]
    let text = Label(
        {
            =>
                if (failureModel.get() == "bad") {
                    throw Exception("S_GETTER_GENERATION_SENTINEL")
                }
                failureModel.get()
        }
    ).onMount({_ => {=> failuresCleaned[0]++}})
    let getterApp = Application(text)
    getterApp.startHeadless()
    getterApp.snapshot(3, 1)
    let getterOld = text.reference().getOrThrow()
    failureModel.set("bad")
    var caught = false
    try {
        getterApp.snapshot(3, 1)
    } catch (error: Exception) {
        caught = error.message.contains("S_GETTER_GENERATION_SENTINEL")
    }
    assertLifetime(caught && failuresCleaned[0] == 1 && !getterOld.isValid(), "getter failure revokes and cleans once")
    noResources(getterApp.stats(), "getter failure resources zero")
    getterApp.dispose()
    assertLifetime(failuresCleaned[0] == 1 && failureModel.get() == "bad",
        "getter cleanup idempotent and model retained")
}
