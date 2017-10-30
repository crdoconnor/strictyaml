Deferred validation:
  based on: strictyaml
  description: |
    When parsing a YAML document you may wish to validate part of the
    document and then later on validate other sections within it.

    This may be required for several reasons, including that one part
    of the document validation depends upon another.
  preconditions:
    setup: |
      from strictyaml import Str, Int, Map, Seq, Defer, Any, load
      from ensure import Ensure

      overall_schema = Map({"capitals": Any(), "countries": Seq(Str())})
      parsed = load(yaml_snippet, overall_schema)

    yaml_snippet: |
      capitals:
        UK: 1
        Germany: 2
      countries:
        - Germany
        - UK
  variations:
    Parse correctly:
      scenario:
      - Run:
          code: |
            Ensure(parsed.data['capitals']['UK']).equals("1")
            parsed['capitals'].revalidate(Map({capital: Int() for capital in parsed.data['countries']}))

            Ensure(parsed.data['capitals']['UK']).equals(1)

    Parse error on revalidation:
      preconditions:
        yaml_snippet: |
          capitals:
            UK: 1
            Germany: 2
            France: 3
          countries:
            - Germany
            - UK
      scenario:
      - Run:
          code: |
            parsed['capitals'].revalidate(Map({capital: Int() for capital in parsed.data['countries']}))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              unexpected key not in schema 'France'
                in "<unicode string>", line 4, column 1:
                    France: '3'
                  ^ (line: 4)
