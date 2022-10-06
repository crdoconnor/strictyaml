Email and URL validators:
  based on: strictyaml
  docs: scalar/email-and-url
  description: |
    StrictYAML can validate emails (using a simplified regex) and
    URLs.
  given:
    setup: |
      from strictyaml import Email, Url, Map, load
      from ensure import Ensure

      schema = Map({"a": Email(), "b": Url()})
  variations:
    Parsed:
      given:
        yaml_snippet: |
          a: billg@microsoft.com
          b: https://user:pass@example.com:443/path?k=v#frag
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema)).equals({"a": "billg@microsoft.com", "b": "https://user:pass@example.com:443/path?k=v#frag"})

    Exception:
      given:
        yaml_snippet: |
          a: notanemail
          b: notaurl
      steps:
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
