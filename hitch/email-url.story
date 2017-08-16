Email and URL validators:
  based on: strictyaml
  description: |
    StrictYAML can validate emails (using a simplified regex) and
    URLs.
  preconditions:
    setup: |
      from strictyaml import Email, Url, Map, load

      schema = Map({"a": Email(), "b": Url()})
    code: |
      load(yaml_snippet, schema)
  variations:
    Valid:
      preconditions:
        yaml_snippet: |
          a: billg@microsoft.com
          b: http://www.google.com/
      scenario:
        - Should be equal to: |
            {"a": "billg@microsoft.com", "b": "http://www.google.com/"}

    Invalid:
      preconditions:
        yaml_snippet: |
          a: notanemail
          b: notaurl
      scenario:
        - Raises exception: non-matching
        
    #- Variable:
        #name: invalid
        #value: |
          #a: notanemail
          #b: notaurl

    #- Raises Exception:
        #command: load(invalid, schema)
        #exception: non-matching
