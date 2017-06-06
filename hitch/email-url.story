Email, URL validators:
  based on: strictyaml
  description: |
    StrictYAML can validate emails (using a simplified regex) and
    URLs.
  scenario:
    - Code: |
        from strictyaml import Email, Url, Map, load

        schema = Map({"a": Email(), "b": Url()})

    - Variable:
        name: valid
        value: |
          a: billg@microsoft.com
          b: http://www.google.com/

    - Returns True: 'load(valid, schema) == {"a": "billg@microsoft.com", "b": "http://www.google.com/"}'

    - Variable:
        name: invalid
        value: |
          a: notanemail
          b: notaurl

    - Raises Exception:
        command: load(invalid, schema)
        exception: invalid
