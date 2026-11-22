Unacceptable characters report reader errors:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import load, dirty_load
  variations:
    Null character:
      steps:
      - Run:
          code: load("\x00")
          raises:
            type: strictyaml.ruamel.reader.ReaderError
            message: |-
              unacceptable character #x0000: special characters are not allowed
                in "<unicode string>", position 0
    Labeled control character:
      steps:
      - Run:
          code: load("abc\x01", label="config.yml")
          raises:
            type: strictyaml.ruamel.reader.ReaderError
            message: |-
              unacceptable character #x0001: special characters are not allowed
                in "config.yml", position 3
    Surrogate character:
      steps:
      - Run:
          code: load("\ud800")
          raises:
            type: strictyaml.ruamel.reader.ReaderError
            message: |-
              unacceptable character #xd800: special characters are not allowed
                in "<unicode string>", position 0
    Dirty load:
      steps:
      - Run:
          code: dirty_load("\x00", label="dirty.yml")
          raises:
            type: strictyaml.ruamel.reader.ReaderError
            message: |-
              unacceptable character #x0000: special characters are not allowed
                in "dirty.yml", position 0
