Python enum classes (Enum):
  docs: scalar/python-enum
  based on: strictyaml
  description: |
    Pass a Python enum.Enum subclass to Enum to parse member names into
    enum members. Serializing requires a member of that exact enum type and
    writes its canonical name. Aliases are accepted on input. The original
    spelling and comments are preserved when an existing document is loaded.

    Enum([values], item_validator) continues to validate a set of scalar
    values. item_validator is not accepted with a Python enum class, whose
    YAML representation is always a member name. Unnamed Flag combinations
    cannot be serialized as member names.
  given:
    setup: |
      import enum
      from strictyaml import Enum, Map, load, as_document

      class Color(enum.Enum):
          RED = 1
          CRIMSON = 1
          BLUE = 2

      schema = Map({"color": Enum(Color)})
  variations:
    Parse a member:
      steps:
      - Run: |
          assert load("color: RED", schema).data == {"color": Color.RED}
    Accept aliases:
      steps:
      - Run: |
          assert load("color: CRIMSON", schema).data == {"color": Color.RED}
    Serialize a member:
      steps:
      - Run:
          code: |
            print(as_document({"color": Color.BLUE}, schema).as_yaml())
          will output: "color: BLUE"
    Update a parsed member:
      steps:
      - Run:
          code: |
            parsed = load("color: RED", schema)
            parsed["color"] = Color.BLUE
            print(parsed.as_yaml())
          will output: "color: BLUE"
