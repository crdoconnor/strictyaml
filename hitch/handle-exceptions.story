Handle exceptions:
  description: |
    When raising exceptions, you can add a label that will replace
    <unicode string> with whatever you want.
  based on: strictyaml
  scenario:
    - Run command: |
        from strictyaml import Map, Int, load, YAMLValidationError
        
    - Variable:
        name: invalid
        value: |
          a: 1
          b:
            - 1
            - 2

    - Raises Exception:
        command: |
          load(invalid, Map({"a": Int(), "b": Map({"x": Int(), "y": Int()})}), label="myfilename")
        exception: |
          in "myfilename", line 2, column 1
