Single value:
  based on: strictyaml
  description: |
     The minimal YAML document that is parsed by StrictYAML is
     a string of characters which parses by default to a string
     unless a scalar validator is used.
     
     Where standard YAML implicitly converts certain strings
     to other types, StrictYAML will only parse to strings
     unless otherwise directed.
  preconditions:
    setup: |
      from strictyaml import Str, Int, load
      
Single value - raise exception on None:
  based on: Single value
  preconditions:
    code: load(None, Str())
  scenario:
    - Raises Exception: 'StrictYAML can only read a string of valid YAML.'

Single value - string of 1:
  based on: Single value
  preconditions:
    code: load("1", Str())
  scenario:
    - Should be equal to: str("1")
    
Single value - int of 1:
  based on: Single value
  preconditions:
    code: load("1", Int())
  scenario:
    - Should be equal to: int(1)

Single value - empty value parsed as blank string by default:
  based on: Single value
  preconditions:
    code: load("x:")
  scenario:
    - Should be equal to: '{"x": ""}'

Single value - empty document parsed as blank string by default:
  based on: Single value
  preconditions:
    code: load("", Str())
  scenario:
    - Should be equal to: str('')

Single value - null parsed as string null by default:
  based on: Single value
  preconditions:
    code: |
      load("null: null")
  scenario:
    - Should be equal to: '{"null": "null"}'
