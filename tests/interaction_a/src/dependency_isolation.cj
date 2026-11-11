package interaction_a_contract
import cjtui.*
func dependencyIsolation(): Unit {
    let width=Observable<Int64>(2); let ink=Observable<String>("a"); let choose=Observable<Bool>(true)
    let old=Observable<String>("b"); let next=Observable<String>("c")
    let measured=Box<Int64>(0)
    let c=Canvas({ bounds => measured.value++; bounds.constrain(Size(width.get(),1)) },{ p =>
        p.put(0,0,ink.get()); p.put(1,0,if(choose.get()){old.get()}else{next.get()})
    })
    let a=Application(c,theme:plainTheme()); a.startHeadless(); a.snapshot(2,1)
    check(a.stats().subscriptions == 4,"M width plus P ink/choose/branch; no accidental measure subscriptions")
    ink.set("z"); check(a.snapshot(2,1).toPlainText()=="zb","paint-only state repaint")
    // M1 is allowed to remeasure. No assertion that measure count stays fixed.
    choose.set(false); a.snapshot(2,1); check(a.stats().subscriptions==4,"P rerun replaces branch dependency")
    let paints=a.stats().paints; old.set("unused"); a.snapshot(2,1)
    check(a.stats().paints==paints,"retired paint branch no longer invalidates")
    let before=measured.value; let f=render(c,2,1)
    check(measured.value>before && f.toPlainText()=="zc","global mounted render is full M1")
    width.set(1); a.snapshot(2,1)
    a.dispose(); empty(a)
    effectiveMeasureDependencies()
}

// A.1/A.2: every still-used constraint result must retain its M dependencies.
func effectiveMeasureDependencies(): Unit {
    let width=Observable<Int64>(1)
    let root=Row {
        Canvas({b=>if(b.maxWidth.isNone()){Size(width.get(),1)}else{b.constrain(Size(1,1))}},{p=>p.put(0,0,"C")})
        Text("B")
    }
    let app=Application(root,theme:plainTheme());app.startHeadless()
    try {
        check(app.snapshot(5,1).toPlainText()=="CB   ","I01 initial constrained Row")
        width.set(3)
        let actual=app.snapshot(5,1);let full=render(root,5,1)
        check(full.toPlainText()=="C  B ","I01 manual full-layout control")
        check(actual.toPlainText()=="C  B ","I01 effective multi-constraint M dependency refresh")
        sameFrame(actual,full,5,1)
    } finally {app.dispose()}
    empty(app)
}
