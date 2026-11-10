package runtime_contract

import cjtui.*

func exportWithoutEffects(): Unit {
    let value = Observable<String>("one")
    let mounts = Box<Int64>(0)
    let cleanups = Box<Int64>(0)
    let root = Text({ => value.get() }).onMount({ _ => mounts.value++; { => cleanups.value++ } })
    picture(render(root, 4, 1), "one ", "detached render uses current typed getter")
    value.set("two")
    picture(render(root, 4, 1), "two ", "detached render rereads latest observable")
    check(mounts.value == 0 && cleanups.value == 0 && root.reference().isNone(), "temporary render publishes no ref or lifecycle effects")
    let app = Application(root)
    app.startHeadless()
    check(mounts.value == 1, "persistent session runs real lifecycle effects")
    let before = app.stats().frames
    let published = ref(root)
    picture(render(root, 4, 1), "two ", "owner render is full M1 reference generator")
    picture(render(root, 4, 1), "two ", "owner reference render repeats complete generation")
    check(app.stats().frames == before + 2 && published.isValid(), "render always generates a target while preserving session")
    app.dispose()
    check(cleanups.value == 1, "persistent effect cleanup remains exactly once")
}
