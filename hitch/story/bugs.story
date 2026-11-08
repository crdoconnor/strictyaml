Revalidation with an or breaks lookup:
  based on: strictyaml
  given:
    yaml_snippet: |
      x:
        a: b
    setup: |
      from strictyaml import load, Any, Int, Str, Map
      loose_schema = Map({"x": Any()})
      strict_schema = Str() | Map({"a": Str()})
  steps:
  - run: |
      parsed = load(yaml_snippet, loose_schema)
      parsed['x'].revalidate(strict_schema)
      parsed['x']['a'] = "x"
      assert parsed['x']['a'] == "x"

Parsing string with data shouldn't resolve to ruamel data structures:
  based on: strictyaml
  given:
    yaml_snippet: 'x: |\n   x'
    setup: |
      from strictyaml import load
      from strictyaml.ruamel.scalarstring import ScalarString
  steps:
  - run: |
      assert not isinstance(load("- >\n hello").data[0], ScalarString)

Comments before values followed by blank lines:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import load
    yaml_snippet: |
      name: Action

      on: # yamllint disable-line rule:truth
         push
  steps:
  - run: |
      for blanks in range(1, 4):
          document = load(yaml_snippet + "\n" * blanks)
          assert document.data == {"name": "Action", "on": "push"}
          output = document.as_yaml()
          assert output.count("# yamllint disable-line rule:truth") == 1
          assert output.endswith("\n" * (blanks + 1))
          assert load(output).data == document.data
          document["on"] = "pull_request"
          output = document.as_yaml()
          assert output.count("# yamllint disable-line rule:truth") == 1
          assert load(output).data["on"] == "pull_request"

Comments after multiline values do not replace earlier comments:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import load
    yaml_snippet: |
      outer:
        key: # before the value
          value

        # after the value
        next: other
  steps:
  - run: |
      document = load(yaml_snippet)
      output = document.as_yaml()
      assert document.data == {"outer": {"key": "value", "next": "other"}}
      assert output.count("# before the value") == 1
      assert output.count("# after the value") == 1
      assert output.index("# before the value") < output.index("# after the value")
      assert load(output).data == document.data
      document = load("key: # first\n  value # second\n\n")
      output = document.as_yaml()
      assert output.count("# first") == 1
      assert output.count("# second") == 1
      assert output.endswith("\n\n")
      assert load(output).data == {"key": "value"}

Comments after block scalars remain outside their content:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import load
  steps:
  - run: |
      for style, expected in [("|", "value\nnext value\n"),
                              (">", "value next value\n")]:
          text = ("key: # before the block\n  " + style +
                  "\n    value\n    next value\n# after the block\n")
          document = load(text)
          assert document.data == {"key": expected}
          output = document.as_yaml()
          assert output.count("# after the block") == 1
          assert load(output).data == document.data
