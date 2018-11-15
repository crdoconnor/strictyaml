Revalidate an already validated document:
  docs: howto/revalidation
  based on: strictyaml
  description: |
    When parsing a YAML document you may wish to do more than one validation
    pass over a document.

    This is needed when:
    
    * It simplifies your code to apply validation in stages.
    * You want to validate recursively.
    * One part of the document validation depends upon another (this is the example given below).
  given:
    setup: |
      from strictyaml import Str, Int, Map, Seq, Any, load
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
    Reparse mapping:
      steps:
      - Run:
          code: |
            Ensure(parsed.data['capitals']['UK']).equals("1")
            parsed['capitals'].revalidate(Map({capital: Int() for capital in parsed.data['countries']}))
            Ensure(parsed.data['capitals']['UK']).equals(1)

    Reparse scalar:
      steps:
      - Run:
          code: |
            Ensure(parsed.data['capitals']['UK']).equals("1")
            parsed['capitals']['UK'].revalidate(Int())
            
            Ensure(parsed.data['capitals']['UK']).equals(1)
            Ensure(parsed['capitals']['UK'].data).is_an(int)

    Parse error:
      given:
        yaml_snippet: |
          capitals:
            UK: 1
            Germany: 2
            France: 3
          countries:
            - Germany
            - UK
      steps:
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
