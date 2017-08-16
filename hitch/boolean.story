Boolean validation:
  based on: strictyaml
  description: |
    Boolean values can be parsed using a Bool
    validator. It case-insensitively interprets
    "yes", "true", "1", "on" as True and their
    opposites as False.

    Any values that are not one of those will
    will cause a validation error.
  preconditions:
    setup: |
      from strictyaml import Bool, Str, MapPattern, YAMLValidationError, load

      schema = MapPattern(Str(), Bool())
      
    yaml_snippet: |
        a: yes
        b: true
        c: on
        d: 1
        e: True
        v: False
        w: 0
        x: Off
        y: FALSE
        z: no
  variations:
    Valid:
      preconditions:
        code: load(yaml_snippet, schema)
      scenario:
        - Should be equal to: |
            {"a": True, "b": True, "c": True, "d": True, "e": True, "v": False, "w": False, "x": False, "y": False, "z": False,}

    YAML object should resolve to True or False:
      preconditions:
        code: load(yaml_snippet, schema)["w"]
      scenario:
        - Should be equal to: False
    
    Using .value you can get the actual boolean value parsed:
      preconditions:
        code: load(yaml_snippet, schema)["a"].value is True
      scenario:
        - Should be equal to: True
    
    .text returns the text of the:
      preconditions:
        code: load(yaml_snippet, schema)["y"].text
      scenario:
        - Should be equal to: |
            "FALSE"

    Cannot cast to string:
      preconditions:
        code: str(load(yaml_snippet, schema)["y"])
      scenario:
        - Raises exception: Cannot cast

    Invalid string:
      preconditions:
        yaml_snippet: 'a: yâs'
        code: load(yaml_snippet, schema)
      scenario:
        - Raises exception: |
            when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
            found non-boolean
              in "<unicode string>", line 1, column 1:
                a: "y\xE2s"
                 ^ (line: 1)
