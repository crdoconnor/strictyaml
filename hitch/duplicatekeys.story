Duplicate keys:
  docs: restrictions/duplicate-keys
  based on: strictyaml
  description: |
    Duplicate keys are allowed in regular YAML - as parsed by pyyaml, ruamel.yaml and poyo:

    Not only is it unclear whether x should be "cow" or "bull" (the parser will decide 'bull', but did you know that?),
    if there are 200 lines between x: cow and x: bull, a user might very likely change the *first* x and erroneously believe
    that the resulting value of x has been changed - when it has not.

    In order to avoid all possible confusion, StrictYAML will simply refuse to parse this and will only accept associative
    arrays where all of the keys are unique. It will throw a DuplicateKeysDisallowed exception.
  given:
    setup: |
      from strictyaml import load, DuplicateKeysDisallowed
    yaml_snippet: |
      a: cow
      a: bull
  variations:
    Nameless exception:
      steps:
      - Run:
          code: load(yaml_snippet)
          raises:
            type: strictyaml.exceptions.DuplicateKeysDisallowed
            message: |-
              While parsing
                in "<unicode string>", line 2, column 1:
                  a: bull
                  ^ (line: 2)
              Duplicate key 'a' found
                in "<unicode string>", line 2, column 2:
                  a: bull
                   ^ (line: 2)


    Named exception:
      steps:
      - Run:
          code: load(yaml_snippet, label="mylabel")
          raises:
            type: strictyaml.exceptions.DuplicateKeysDisallowed
            message: |-
              While parsing
                in "mylabel", line 2, column 1:
                  a: bull
                  ^ (line: 2)
              Duplicate key 'a' found
                in "mylabel", line 2, column 2:
                  a: bull
                   ^ (line: 2)
