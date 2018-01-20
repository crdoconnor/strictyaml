Boolean (Bool):
  based on: strictyaml
  docs: scalar/boolean
  description: |
    Boolean values can be parsed using a Bool validator.

    It case-insensitively interprets "yes", "true", "1", "on" as "True", "y"
    and their opposites as False.

    Different values will trigger a validation error.

    When updating boolean values on a YAML object with True or False, the roundtripped
    string version is set to "yes" and "no".

    To have your boolean values updated to a different yes/no string, update
    with a string instead - e.g. "on" or "off".
  given:
    setup: |
      from strictyaml import Bool, Str, MapPattern, load
      from ensure import Ensure

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
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({
                "a": True, "b": True, "c": True, "d": True, "e": True, "f": True,
                "u": False, "v": False, "w": False, "x": False, "y": False, "z": False,
            })

    YAML object should resolve to True or False:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["w"]).equals(False)

    Using .data you can get the actual boolean value parsed:
      steps:
      - Run:
          code: |
            assert load(yaml_snippet, schema)["a"].data is True

    .text returns the text of the boolean YAML:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["y"].text).equals("FALSE")

    Update boolean values with string and bool type:
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            yaml['a'] = 'no'
            yaml['b'] = False
            yaml['c'] = True
            print(yaml.as_yaml())
          will output: |-
            a: no
            b: no
            c: yes
            d: 1
            e: True
            f: Y

            u: n
            v: False
            w: 0
            x: Off
            y: FALSE
            z: no

    Cannot cast boolean to string:
      steps:
      - Run:
          code: str(load(yaml_snippet, schema)["y"])
          raises:
            type:
              in python 2: exceptions.TypeError
              in python 3: builtins.TypeError
            message: |-
              Cannot cast 'YAML(False)' to str.
              Use str(yamlobj.data) or str(yamlobj.text) instead.

    Different uninterpretable values raise validation error:
      steps:
      - Run:
          code: |
            load('a: yâs', schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a boolean value (one of "yes", "true", "on", "1", "y", "no", "false", "off", "0", "n")
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: "y\xE2s"
                   ^ (line: 1)
