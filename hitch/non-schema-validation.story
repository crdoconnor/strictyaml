Non-schema validation:
  based on: strictyaml
  description: |
    When using strictyaml you do not have to specify a schema. If
    you do this, the validator "Any" is used which will accept any
    mapping and any list and any scalar values (which will always be
    interpreted as a string, unlike regular YAML).

    This is the recommended approach when rapidly prototyping and the
    desired schema is fluid.

    When your prototype code is parsing YAML that has a more fixed
    structure, we recommend that you 'lock it down' with a schema.

    The Any validator can be used inside fixed structures as well.
  preconditions:
    setup: |
      from strictyaml import Any, MapPattern, load
    yaml_snippet: |
      a:
        x: 9
        y: 8
      b: 2
      c: 3
  variations:
    Parse without validator:
      preconditions:
        code: load(yaml_snippet)
      scenario:
        - Should be equal to: '{"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}'
        
    Parse with any validator - equivalent:
      preconditions:
        code: load(yaml_snippet, Any())
      scenario:
        - Should be equal to: '{"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}'
        
    Fix higher levels of schema:
      preconditions:
        code: load(yaml_snippet, MapPattern(Any(), Any()))
      scenario:
        - Should be equal to: '{"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}'
