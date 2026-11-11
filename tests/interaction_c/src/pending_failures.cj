package interaction_c
import cjtui.*
import std.ref.*
import std.runtime.*
import std.sync.*

func duplicateReservation():Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let mounts=Box<Int64>(0);let content=Text("one").onMount({_=>mounts.value++;{=>}})
    let first=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    app.batch({=>first.value=Some(node(root).openOverlay(content));code("AlreadyMounted",{=>node(root).openOverlay(content);()},"P03 duplicate pending reservation")})
    check(first.value.getOrThrow().isOpen() && mounts.value==1,"P03 only first reservation mounts")
    app.dispose()
}

func pendingFailure(mount:Bool):Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let failure=Exception("P04 original ${mount}");let cleaned=Box<Int64>(0)
    let parent=Text("old").onMount({_=>{=>cleaned.value++}})
    app.batch({=>node(root).openOverlay(parent,options:OverlayOptions(takeFocus:false));()})
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let bad:Component=if(mount){Text("bad").onMount({_=>throw failure})}else{BrokenPanel(failure)}
    var caught=false
    try{app.batch({=>handle.value=Some(node(root).openOverlay(bad))})}catch(e:Exception){caught=refEq(e,failure)}
    check(caught && cleaned.value==1,"P04 build/mount primary preserved and existing cleanup once")
    check(!handle.value.getOrThrow().isOpen() && handle.value.getOrThrow().content().isNone(),"P04 no pending publication after failure")
    released(app,"P04 session failure releases resources");app.dispose()
}

// EAGER collection is explicitly not guaranteed by SDK. P05 is an observation,
// never a deterministic leak PASS merely because this observer was cleared.
func releasedOwnerObservation():Unit {
    let weak=Box<?WeakRef<Application>>(Option<WeakRef<Application>>.None);let retained=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    makeReleasedOwner(weak,retained)
    let before=getGCCount();gc(heavy:true)
    for(_ in 0..5000){if(getGCCount()>before){break};sleep(Duration.millisecond)}
    check(!retained.value.getOrThrow().isOpen() && retained.value.getOrThrow().content().isNone(),"P05 retained terminal handle publishes no owner nodes")
    println("OBSERVATION_ONLY P05 gcProgress=${getGCCount()>before} weakOwnerCleared=${weak.value.getOrThrow().value.isNone()}; weak retention requires source review, no GC leak PASS")
}
func makeReleasedOwner(weak:Box<?WeakRef<Application>>,retained:Box<?OverlayHandle>):Unit {
    let root=Column{}.viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    app.batch({=>retained.value=Some(node(root).openOverlay(Text("old")))})
    app.dispose();released(app,"P05 disposed owner resources0")
    weak.value=Some(WeakRef<Application>(app,CleanupPolicy.EAGER))
}
