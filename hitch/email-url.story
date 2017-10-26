Email and URL validators:
  based on: strictyaml
  description: |
    StrictYAML can validate emails (using a simplified regex) and
    URLs.
  preconditions:
    setup: |
      from strictyaml import Email, Url, Map, load
      from ensure import Ensure

      schema = Map({"a": Email(), "b": Url()})
  variations:
    Valid 1:
      preconditions:
        yaml_snippet: |
          a: billg@microsoft.com
          b: http://www.google.com/
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "billg@microsoft.com", "b": "http://www.google.com/"})

    Invalid:
      preconditions:
        yaml_snippet: |
          a: notanemail
          b: notaurl
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an email address
              found non-matching string
                in "<unicode string>", line 1, column 1:
                  a: notanemail
                   ^ (line: 1)
