Scalar strings:
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object, not
    the value directly to give you more flexibility
    and control over what you can do with the YAML.
    
    This is what that can object can do - in most
    cases if parsed as a string, it will behave in
    the same way.
  preconditions:
    setup: |
      from strictyaml import Str, Map, load

      schema = Map({"a": Str(), "b": Str(), "c": Str(), "d": Str()})
      
      parsed = load(yaml_snippet, schema)
    yaml_snippet: |
      a: 1
      b: yes
      c: â string
      d: |
        multiline string
  variations:
    Parses correctly:
      preconditions:
        code: parsed
      scenario:
        - Should be equal to: |
            {"a": "1", "b": "yes", "c": u"â string", "d": "multiline string\n"}
    Dict lookup cast to string:
      preconditions:
        code: str(parsed["a"])
      scenario:
        - Should be equal to: |
            "1"
    Dict lookup cast to int:
      preconditions:
        code: int(parsed["a"])
      scenario:
        - Should be equal to: |
            1
    Dict lookup cast to bool impossible:
      preconditions:
        code: bool(parsed["a"])
      scenario:
        - Raises exception: Cannot cast
          

    #- Returns True: ' == '

    #- Returns True: str(load(yaml_snippet, schema)["a"]) == "1"

    #- Returns True: int(load(yaml_snippet, schema)["a"]) == 1

    #- Raises Exception:
        #command: bool(load(yaml_snippet, schema)["a"])
        #exception: Cannot cast

