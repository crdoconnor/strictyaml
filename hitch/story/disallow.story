Disallowed YAML:
  docs: restrictions/disallowed-yaml
  based on: strictyaml
  description: |
    StrictYAML parses an opinionated subset of the YAML
    specification which refuses to parse features which
    are otherwise valid in standard YAML.

    For an explanation as to why these features are stripped
    out of StrictYAML, see the FAQ.

    Disallowed YAML features raise Disallowed exceptions
    while syntactically invalid YAML raises ScannerError
    or ComposerError.

    Every error inherits from YAMLError.
  given:
    setup: |
      from strictyaml import Map, Int, Any, load
      from strictyaml import TagTokenDisallowed, FlowMappingDisallowed, AnchorTokenDisallowed

      schema = Map({"x": Map({"a": Any(), "b": Any(), "c": Any()})})
  variations:
    Tag tokens:
      given:
        yaml_snippet: |
          x:
            a: !!str yes
            b: !!str 3.5
            c: !!str yes
      steps:
      - Run:
          code: load(yaml_snippet, schema, label="disallowed")
          raises:
            type: strictyaml.exceptions.TagTokenDisallowed
            message: |-
              While scanning
                in "disallowed", line 2, column 11:
                    a: !!str yes
                            ^ (line: 2)
              Found disallowed tag tokens (do not specify types in markup)
                in "disallowed", line 2, column 6:
                    a: !!str yes
                       ^ (line: 2)

    Flow style sequence:
      given:
        yaml_snippet: |
          [a, b]: [x, y]
      steps:
      - Run:
          code: load(yaml_snippet, schema, label="disallowed")
          raises:
            type: strictyaml.exceptions.FlowMappingDisallowed
            message: |-
              While scanning
                in "disallowed", line 1, column 1:
                  [a, b]: [x, y]
                  ^ (line: 1)
              Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
                in "disallowed", line 1, column 2:
                  [a, b]: [x, y]
                   ^ (line: 1)

    Flow style mapping:
      description: |
        To use literally, surround with quotes, e.g. x: '{ a: 1, b: 2, c: 3 }'
      given:
        yaml_snippet: |
          x: { a: 1, b: 2, c: 3 }
      steps:
      - Run:
          code: load(yaml_snippet, schema, label="disallowed")
          raises:
            type: strictyaml.exceptions.FlowMappingDisallowed
            message: |-
              While scanning
                in "disallowed", line 1, column 4:
                  x: { a: 1, b: 2, c: 3 }
                     ^ (line: 1)
              Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
                in "disallowed", line 1, column 5:
                  x: { a: 1, b: 2, c: 3 }
                      ^ (line: 1)

    Node anchors and references:
      description: |
        To use literally, surround with quotes, e.g. x: '{ a: 1, b: 2, c: 3 }'
      given:
        yaml_snippet: |
          x: 
            a: &node1 3.5
            b: 1
            c: *node1
      steps:
      - Run:
          code: load(yaml_snippet, schema, label="disallowed")
          raises:
            type: strictyaml.exceptions.AnchorTokenDisallowed
            message: |-
              While scanning
                in "disallowed", line 2, column 6:
                    a: &node1 3.5
                       ^ (line: 2)
              Found confusing disallowed anchor token (surround with ' and ' to make text appear literally)
                in "disallowed", line 2, column 12:
                    a: &node1 3.5
                             ^ (line: 2)


    Syntactically invalid YAML:
      description: |
        To use literally, surround with quotes, e.g. x: '{ a: 1, b: 2, c: 3 }'
      given:
        yaml_snippet: |
          - invalid
          string
      steps:
      - Run:
          code: load(yaml_snippet, schema, label="disallowed")
          raises:
            type: strictyaml.ruamel.scanner.ScannerError
            message: |-
              while scanning a simple key
                in "disallowed", line 2, column 1:
                  string
                  ^ (line: 2)
              could not find expected ':'
                in "disallowed", line 3, column 1:
                  
                  ^ (line: 3)

    Mixed space indentation:
      description: |
        You must use consistent spacing
      given:
        yaml_snippet: |
          item:
            two space indent: 2
          item two:
              four space indent: 2
      steps:
      - Run:
          code: load(yaml_snippet, label="disallowed")
          raises:
            type: strictyaml.exceptions.InconsistentIndentationDisallowed
            message: "While parsing\n  in \"disallowed\", line 4, column 5:\n    \
              \    four space indent: 2\n        ^ (line: 4)\nFound mapping with indentation\
              \ inconsistent with previous mapping\n  in \"disallowed\", line 5, column\
              \ 1:\n    \n    ^ (line: 5)"
