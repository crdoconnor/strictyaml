op Boolean validation:
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
      f: Y

      u: n
      v: False
      w: 0
      x: Off
      y: FALSE
      z: no
  variations:
    Parse to YAML object:
      preconditions:
        code: load(yaml_snippet, schema)
      scenario:
      - Should be equal to: |
          {
              "a": True, "b": True, "c": True, "d": True, "e": True, "f": True,
              "u": False, "v": False, "w": False, "x": False, "y": False, "z": False,
          }

    YAML object should resolve to True or False:
      preconditions:
        code: load(yaml_snippet, schema)["w"]
      scenario:
      - Should be equal to: 'False'

    Using .value you can get the actual boolean value parsed:
      preconditions:
        code: load(yaml_snippet, schema)["a"].value is True
      scenario:
      - Should be equal to: 'True'

    .text returns the text of the:
      preconditions:
        code: load(yaml_snippet, schema)["y"].text
      scenario:
      - Should be equal to: |
          "FALSE"

    Update boolean value:
      preconditions:
        modified_yaml_snippet: |
          b: true
          c: on
          d: 1
          e: True
          f: Y

          u: n
          v: False
          w: 0
          x: Off
          y: FALSE
          z: no
          a: no
        setup: |
          from strictyaml import Bool, Str, MapPattern, YAMLValidationError, load

          schema = MapPattern(Str(), Bool())

          yaml = load(yaml_snippet, schema)
          yaml['a'] = 'no'
        code: |
          yaml.as_yaml()
      scenario:
      - Should be equal to: modified_yaml_snippet

    Cannot cast to string:
      preconditions:
        code: str(load(yaml_snippet, schema)["y"])
      scenario:
      - Raises exception:
          message: |-
            Cannot cast 'YAML(False)' to str.
            Use str(yamlobj.value) or str(yamlobj.text) instead.

    Invalid string:
      preconditions:
        yaml_snippet: 'a: yâs'
        code: load(yaml_snippet, schema)
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a boolean value (one of "yes", "true", "on", "1", "y", "no", "false", "off", "0", "n")
            found non-boolean
              in "<unicode string>", line 1, column 1:
                a: "y\xE2s"
                 ^ (line: 1)
