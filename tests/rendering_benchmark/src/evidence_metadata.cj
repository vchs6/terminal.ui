package rendering_benchmark_tests

import std.collection.ArrayList

func externalColumns(): Array<String> {
    ["source_sha","artifact_sha256","elf_sha256","workload_sha256","dependency_sha256","sdk_version","sdk_sha256",
        "native_sha256","environment_id","os","cpu","cpu_policy","locale","terminal","terminal_version",
        "capability_source","gc_config","optimization"]
}

// Artifact/Git/SDK/environment identities are external facts. A normal benchmark
// binary in an unpacked source package need not discover Git or author paths.
func attachMetadata(samples: CsvTable, metadata: CsvTable): CsvTable {
    samples.requireColumns(["run_id"]); metadata.requireColumns(["run_id"])
    metadata.requireColumns(externalColumns())
    let headings = ArrayList<String>()
    headings.add(all:samples.columns)
    for (name in externalColumns()) { if (!samples.hasColumn(name)) { headings.add(name) } }
    let rows = ArrayList<Array<String>>()
    for (sample in samples.rows) {
        let runId = samples.at(sample,"run_id")
        var found: Int64 = 0
        var picked: Array<String> = []
        for (entry in metadata.rows) {
            if (metadata.at(entry,"run_id") == runId) { found++; picked = entry }
        }
        demand(found == 1, "missing/ambiguous actual run metadata ${runId}")
        let fields = ArrayList<String>()
        fields.add(all:sample)
        for (name in externalColumns()) {
            let actual = metadata.at(picked,name)
            if (samples.hasColumn(name)) {
                demand(samples.at(sample,name) == actual, "runtime/external metadata disagree ${runId}/${name}")
            } else { fields.add(actual) }
        }
        rows.add(fields.toArray())
    }
    CsvTable(headings.toArray(),rows.toArray())
}
