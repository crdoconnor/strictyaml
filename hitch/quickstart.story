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
            YAML(OrderedDict([('name', 'Ford Prefect'), ('age', '42'), ('possessions', ['Towel'])]))
          in interpreter: yes

    All data is string, list or OrderedDict:
      fails on python 2: yes
      steps:
      - Run:
          code: |
            load(yaml_snippet).data
          will output: |-
            OrderedDict([('name', 'Ford Prefect'), ('age', '42'), ('possessions', ['Towel'])])
          in interpreter: yes
    
Quickstart with schema:
  based on: simple example
  given:
    yaml_snippet: |
      # All about the character
      name: Ford Prefect
      age: 42
      possessions:
      - Towel
    setup: |
      from strictyaml import load, Map, Str, Int, Seq, YAMLError
      
      schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})
  variations:
    Using a schema:
      steps:
      - Run:
          in interpreter: yes
          code: |
            person = load(yaml_snippet, schema)
            
            # 42 is now an int
            person.data == {"name": "Ford Prefect", "age": 42, "possessions": ["Towel", ]}
          will output: True

A YAMLError will be raised if there are syntactic problems, violations of your schema or use of disallowed YAML features:
  based on: quickstart with schema
  given:
    yaml_snippet: |
      # All about the character
      name: Ford Prefect
      age: 42
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
  based on: Quickstart with schema
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
            print(person['possessions'][0].start_line)
          will output: 5
