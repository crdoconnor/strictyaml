Updating document with a schema:
  docs: compound/update
  based on: strictyaml
  description: |
    When StrictYAML loads a document with a schema, it checks that future
    updates to that document follow the original schema.
  given:
    setup: |
      import strictyaml as s
      from ensure import Ensure
  variations:
    GitHub \#72:
      steps:
      - Run: |-
          doc = s.load('a: 9', s.Map({
            'a': s.Str(),
            s.Optional('b'): s.Int(),
          }))
          doc['b'] = 9
          assert doc['b'] == 9

    Can assign from string:
      steps:
      - Run: |-
          doc = s.load('a: 9', s.Map({
            'a': s.Str(),
            s.Optional('b'): s.Int(),
          }))
          doc['b'] = '9'
          assert doc['b'] == 9

