Non-schema validation:
  based on: strictyaml
  description: |
    When using strictyaml you do not have to specify a schema. If
    you do this, the validator "Any" is used which will accept any
    mapping and any list and any value (which will always be interpreted
    as a string).

    This is recommended when rapidly prototyping and the schema is
    still fluid. When your prototype code is parsing YAML
    that has a more fixed structure, we recommend that you lock it
    down with a schema.

    The Any validator can be used inside fixed structures as well.
  preconditions:
    files:
      valid_sequence.yaml: |
        a:
          x: 9
          y: 8
        b: 2
        c: 3
  scenario:
    - Code: |
        from strictyaml import Any, MapPattern, load

    - Returns True: |
        load(valid_sequence) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}

    - Returns True:
        why: This is equivalent to the above statement
        command: |
          load(valid_sequence, Any()) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}

    - Returns True:
        why: You can fix the schema of higher levels of the YAML and not lower levels
        command: |
          load(valid_sequence, MapPattern(Any(), Any())) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}
