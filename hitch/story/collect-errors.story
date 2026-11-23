Collecting parser and schema errors:
  docs: parsing/collect-errors
  based on: strictyaml
  description: |
    load(text, schema, collect_errors=True) validates independent siblings
    before raising YAMLValidationErrors. Its errors tuple contains the usual
    located exception objects, and str(error) formats them together. A valid
    document returns the same YAML object behavior as an ordinary load.

    Collection includes disallowed flow containers, explicit tags, anchors,
    aliases, duplicate keys, inconsistent mapping indentation, and schema
    violations. For diagnostics, tags are ignored without calling tagged
    constructors; aliases are never expanded and their placeholder values
    are not schema checked. Duplicate keys are each reported, and only the
    first value is used for subsequent schema checks. No invalid document is
    returned. Parser errors precede schema errors in the result.

    Unrecoverable YAML syntax ends parsing and reports earlier restrictions
    together with the syntax error; no incomplete tree is schema checked.
    Wrong container shapes or invalid mapping keys stop that branch, while
    independent siblings continue. If every Or alternative fails, both sets
    of errors are reported; a successful alternative discards speculative
    failures. Arbitrary exceptions from custom validators still propagate.

    Custom compound validators can put each independent child operation in
    with child.validation_scope(), and call child.validate(validator). These
    scopes retain normal fail-fast behavior outside a collecting load.
    Collection is disabled again before returning a valid document, including
    for later assignment and revalidation. dirty_load also accepts the option
    and continues to honor allow_flow_style. Defaults remain unchanged.
  given:
    setup: |
      from strictyaml import Map, Int, Seq, Str, load, YAMLValidationErrors
      from strictyaml.exceptions import FlowMappingDisallowed, YAMLValidationError
  variations:
    Independent fields:
      steps:
      - Run: |
          try:
              load("first: bad\nsecond: nope", Map({"first": Int(), "second": Int()}),
                   collect_errors=True)
          except YAMLValidationErrors as error:
              assert len(error.errors) == 2
              assert all(isinstance(item, YAMLValidationError) for item in error.errors)
          else:
              raise AssertionError("invalid document accepted")
    Mixed parser and schema errors:
      steps:
      - Run: |
          try:
              load("items: [bad, nope]", Map({"items": Seq(Int())}), collect_errors=True)
          except YAMLValidationErrors as error:
              assert len(error.errors) == 3
              assert isinstance(error.errors[0], FlowMappingDisallowed)
          else:
              raise AssertionError("invalid document accepted")
    Successful alternatives discard errors:
      steps:
      - Run: |
          assert load("text", Int() | Str(), collect_errors=True).data == "text"
    Valid document:
      steps:
      - Run: |
          parsed = load("number: 2 # count\n", Map({"number": Int()}), collect_errors=True)
          assert parsed.data == {"number": 2}
          assert parsed.as_yaml() == "number: 2 # count\n"
