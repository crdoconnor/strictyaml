Simple example:
  based on: strictyaml
  given:
    yaml_snippet: |
      # All about the character
      name: Ford Prefect
      age: 42
      possessions:
      - Towel
    setup: |
      from strictyaml import load, Map, Str, Int, Seq, YAMLError
  variations:
    Default parse result:
      fails on python 2: yes
      steps:
      - Run:
          code: |
            load(yaml_snippet)
          will output: |-
            YAML({'name': 'Ford Prefect', 'age': '42', 'possessions': ['Towel']})
          in interpreter: yes

    All data is string, list or OrderedDict:
      fails on python 2: yes
      steps:
      - Run:
          code: |
            load(yaml_snippet).data
          will output: |-
            {'name': 'Ford Prefect', 'age': '42', 'possessions': ['Towel']}
          in interpreter: yes

Quickstart with schema:
  based on: simple example
  given:
    setup: |
      from strictyaml import load, Map, Str, Int, Seq, YAMLError

      schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})
  variations:
    42 is now parsed as an integer:
      steps:
      - Run:
          in interpreter: yes
          code: |
            person = load(yaml_snippet, schema)
            person.data
          will output: |-
            {'name': 'Ford Prefect', 'age': 42, 'possessions': ['Towel']}

A YAMLError will be raised if there are syntactic problems, violations of your schema or use of disallowed YAML features:
  based on: quickstart with schema
  given:
    yaml_snippet: |
      # All about the character
      name: Ford Prefect
      age: 42
  variations:
    For example, a schema violation:
      steps:
      - Run:
          code: |
            try:
                person = load(yaml_snippet, schema)
            except YAMLError as error:
                print(error)
          will output: |-
            while parsing a mapping
              in "<unicode string>", line 1, column 1:
                # All about the character
                 ^ (line: 1)
            required key(s) 'possessions' not found
              in "<unicode string>", line 3, column 1:
                age: '42'
                ^ (line: 3)

If parsed correctly:
  based on: simple example
  given:
    setup: |
      from strictyaml import load, Map, Str, Int, Seq, YAMLError, as_document

      schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})
  variations:
    You can modify values and write out the YAML with comments preserved:
      steps:
      - Run:
          code: |
            person = load(yaml_snippet, schema)
            person['age'] = 43
            print(person.as_yaml())
          will output: |-
            # All about the character
            name: Ford Prefect
            age: 43
            possessions:
            - Towel


    As well as look up line numbers:
      steps:
      - Run:
          in interpreter: yes
          code: |
            person = load(yaml_snippet, schema)
            person['possessions'][0].start_line
          will output: 5

    And construct YAML documents from dicts or lists:
      steps:
      - Run:
          in interpreter: no
          code: |
            print(as_document({"x": 1}).as_yaml())
          will output: |-
            x: 1
