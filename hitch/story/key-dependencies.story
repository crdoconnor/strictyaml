Keys required unless another key is present:
  docs: compound/key-dependencies
  based on: strictyaml
  description: |
    Optional("diameter", required_unless=["wall"]) makes diameter required
    when wall is absent. With several alternatives, any one makes the key
    optional. Both the conditional key and the alternatives may be present.
    This is a presence rule: zero, false and empty values count as present,
    and each present value still has to satisfy its own validator.

    References must be other keys declared in the same Map or MapCombined.
    Parent, child and arbitrary extra keys are not dependency references.
    Defaults count as present, including defaults omitted when serializing,
    so loading, serializing and revalidating apply the same condition.
    required_unless accepts a nonempty iterable of keys, not a single string.
    As with required keys, direct deletion needs a later revalidate call.
  given:
    setup: |
      from strictyaml import Map, Optional, Str, Int, load, as_document
      from strictyaml.exceptions import YAMLValidationError, YAMLSerializationError

      schema = Map({
          "name": Str(),
          Optional("wall"): Int(),
          Optional("diameter", required_unless=["wall"]): Int(),
      })
  variations:
    Wall makes diameter optional:
      steps:
      - Run: |
          assert load("name: pipe\nwall: 2", schema).data == {"name": "pipe", "wall": 2}
    Diameter is present without wall:
      steps:
      - Run: |
          assert load("name: pipe\ndiameter: 10", schema).data["diameter"] == 10
    Neither alternative is present:
      steps:
      - Run: |
          try:
              load("name: pipe", schema)
          except YAMLValidationError as error:
              assert "'diameter' is required" in str(error)
          else:
              raise AssertionError("missing diameter was accepted")
    Serialization applies the same rule:
      steps:
      - Run: |
          try:
              as_document({"name": "pipe"}, schema)
          except YAMLSerializationError as error:
              assert "'diameter' is required" in str(error)
          else:
              raise AssertionError("missing diameter was serialized")
    Defaults satisfy presence:
      steps:
      - Run: |
          schema = Map({
              "name": Str(),
              Optional("wall", default=2): Int(),
              Optional("diameter", required_unless=["wall"]): Int(),
          })
          parsed = load("name: pipe", schema)
          assert parsed.data == {"name": "pipe", "wall": 2}
          assert as_document(parsed.data, schema).as_yaml() == "name: pipe\n"
