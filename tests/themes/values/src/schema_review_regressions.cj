package theme_values_contract

func schemaReviewPriorities(): Unit {
    var failed: Int64=0
    if(!schemaCase("review-version-before-variables-type",{=>schemaExpectedError("schema_version=2\nname=\"x\"\nvariables=1\n","UnsupportedVersion","schema_version","review-version-before-variables-type")})) { failed++ }
    if(!schemaCase("review-required-version-before-variables-type",{=>schemaExpectedError("name=\"x\"\nvariables=1\n","MissingRequired","schema_version","review-required-version-before-variables-type")})) { failed++ }
    if(!schemaCase("review-required-name-before-variables-type",{=>schemaExpectedError("schema_version=1\nvariables=1\n","MissingRequired","name","review-required-name-before-variables-type")})) { failed++ }
    check(failed==0,"review root priority: ${failed} failed")
}
func schemaReviewVariableOrder(): Unit {
    var failed: Int64=0
    if(!schemaCase("review-variable-value-before-extra",{=>schemaExpectedError("schema_version=1\nname=\"x\"\n[variables.v]\ntype=\"bool\"\nvalue=\"bad\"\nextra=true\n","InvalidType","variables.v.value","review-variable-value-before-extra",marker:"bad")})) { failed++ }
    if(!schemaCase("review-variable-extra-before-value",{=>schemaExpectedError("schema_version=1\nname=\"x\"\n[variables.v]\ntype=\"bool\"\nextra=true\nvalue=\"bad\"\n","UnknownKey","variables.v.extra","review-variable-extra-before-value",marker:"true")})) { failed++ }
    check(failed==0,"review variable source order: ${failed} failed")
}
