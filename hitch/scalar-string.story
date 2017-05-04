String scalars:
  based on: strictyaml
  preconditions:
    files:
      valid_sequence.yaml: |
        a: 1
        b: yes
        c: â string
        d: |
          multiline string
  scenario:
    - Run command: |
        from strictyaml import Str, Map, YAMLValidationError, load

        schema = Map({"a": Str(), "b": Str(), "c": Str(), "d": Str()})

    - Assert True: 'load(valid_sequence, schema) == {"a": "1", "b": "yes", "c": u"â string", "d": "multiline string\n"}'

    - Assert True: str(load(valid_sequence, schema)["a"]) == "1"

    - Assert True: int(load(valid_sequence, schema)["a"]) == 1

    - Assert Exception:
        command: bool(load(valid_sequence, schema)["a"])
        exception: Cannot cast

