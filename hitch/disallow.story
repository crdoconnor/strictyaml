Overly complex YAML disallowed:
  based on: strictyaml
  description: |
    StrictYAML is an opinionated subset of the YAML
    specification which refuses to parse features which
    are otherwise valid in standard YAML.
    
    For extra details on *why* these features are stripped
    out of StrictYAML, see the FAQ, although for the
    most part the answer is "because they're overcomplicated
    and features that inhibit markup readability".
  scenario:
    - Code: |
        from strictyaml import Map, Int, Any, load
        from strictyaml import TagTokenDisallowed, FlowMappingDisallowed, AnchorTokenDisallowed

        schema = Map({"x": Map({"a": Any(), "b": Any(), "c": Any()})})

    - Variable:
        name: tag_tokens
        value: |
          x:
            a: !!str yes
            b: !!str 3.5
            c: !!str yes

    - Raises Exception:
        command: load(tag_tokens, schema)
        exception: |
          While scanning
            in "<unicode string>", line 2, column 11:
                a: !!str yes
                        ^ (line: 2)
          Found disallowed tag tokens (do not specify types in markup)
            in "<unicode string>", line 2, column 6:
                a: !!str yes
                   ^ (line: 2)

    - Variable:
        name: flow_style_sequence
        value: |
          [a, b]: [x, y]

    - Raises Exception:
        command: load(flow_style_sequence)
        exception: |
          While scanning
            in "<unicode string>", line 1, column 1:
              [a, b]: [x, y]
              ^ (line: 1)
          Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
            in "<unicode string>", line 1, column 2:
              [a, b]: [x, y]
               ^ (line: 1)

    - Variable:
        name: jinja2
        value: |
          x: '{{ value }}'

    - Returns True:
        why: Using quotation marks, you can parse a string starting or ending with { or }
        command: 'load(jinja2) == {"x": "{{ value }}"}'

    - Variable:
        name: flow_style
        value: |
          x: { a: 1, b: 2, c: 3 }

    - Raises Exception:
        command: load(flow_style, schema)
        exception: |
          While scanning
            in "<unicode string>", line 1, column 4:
              x: { a: 1, b: 2, c: 3 }
                 ^ (line: 1)
          Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
            in "<unicode string>", line 1, column 5:
              x: { a: 1, b: 2, c: 3 }
                  ^ (line: 1)

    - Raises Exception:
        command: load(flow_style, schema)
        exception: |
          While scanning
            in "<unicode string>", line 1, column 4:
              x: { a: 1, b: 2, c: 3 }
                 ^ (line: 1)
          Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
            in "<unicode string>", line 1, column 5:
              x: { a: 1, b: 2, c: 3 }
                  ^ (line: 1)

    - Variable:
        name: node_anchors_and_references
        value: |
          x: 
            a: &node1 3.5
            b: 1
            c: *node1

    - Raises Exception:
        command: load(node_anchors_and_references, schema)
        exception: |
          While scanning
            in "<unicode string>", line 2, column 6:
                a: &node1 3.5
                   ^ (line: 2)
          Found confusing disallowed anchor token (surround with ' and ' to make text appear literally)
            in "<unicode string>", line 2, column 12:
                a: &node1 3.5
                         ^ (line: 2)
