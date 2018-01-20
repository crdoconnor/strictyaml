StrictYAML
==========

StrictYAML is a [type-safe](https://en.wikipedia.org/wiki/Type_safety) YAML parser
that parses a [restricted subset](http://hitchdev.com/strictyaml/features-removed) of the [YAML](http://hitchdev.com/strictyaml/what-is-yaml)
specificaton.

Priorities:

- Beautiful API
- Refusing to parse [the ugly, hard to read and insecure features of YAML](http://hitchdev.com/strictyaml/features-removed).
- Strict validation of markup and straightforward type casting.
- Clear, readable exceptions with **code snippets** and **line numbers**.
- Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
- Ability to read in YAML, make changes and write it out again with comments preserved.
- *Not* speed, currently.


Simple example:

```yaml
# All about the character
name: Ford Prefect
age: 42
possessions:
- Towel

```


```python
from strictyaml import load, Map, Str, Int, Seq, YAMLError

```





Default parse result:


```python
>>> load(yaml_snippet)
YAML(OrderedDict([('name', 'Ford Prefect'), ('age', '42'), ('possessions', ['Towel'])]))
```



All data is string, list or OrderedDict:


```python
>>> load(yaml_snippet).data
OrderedDict([('name', 'Ford Prefect'), ('age', '42'), ('possessions', ['Towel'])])
```



Quickstart with schema:


```python
from strictyaml import load, Map, Str, Int, Seq, YAMLError

schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})

```





42 is now parsed as an integer:


```python
>>> person = load(yaml_snippet, schema)
>>> person.data
OrderedDict([('name', 'Ford Prefect'), ('age', 42), ('possessions', ['Towel'])])
```



A YAMLError will be raised if there are syntactic problems, violations of your schema or use of disallowed YAML features:

```yaml
# All about the character
name: Ford Prefect
age: 42

```






For example, a schema violation:


```python
try:
    person = load(yaml_snippet, schema)
except YAMLError as error:
    print(error)

```

```yaml
while parsing a mapping
  in "<unicode string>", line 1, column 1:
    # All about the character
     ^ (line: 1)
required key(s) 'possessions' not found
  in "<unicode string>", line 3, column 1:
    age: '42'
    ^ (line: 3)
```





If parsed correctly:


```python
from strictyaml import load, Map, Str, Int, Seq, YAMLError

schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})

```





You can modify values and write out the YAML with comments preserved:


```python
person = load(yaml_snippet, schema)
person['age'] = 43
print(person.as_yaml())

```

```yaml
# All about the character
name: Ford Prefect
age: 43
possessions:
- Towel
```





As well as look up line numbers:


```python
>>> person = load(yaml_snippet, schema)
>>> person['possessions'][0].start_line
5
```




Install
-------

```sh
$ pip install strictyaml
```

Why StrictYAML?
---------------

There are a number of formats and approaches that can achieve more or
less the same purpose as StrictYAML. I've tried to make it the best one.
Below is a series of documented justifications:


- [Why not JSON for simple configuration files?](http://hitchdev.com/strictyaml/why-not/json)
- [Why not use HJSON?](http://hitchdev.com/strictyaml/why-not/hjson)
- [Why not use TOML?](http://hitchdev.com/strictyaml/why-not/toml)
- [Why not use the YAML 2.0 standard? - we don't need a new standard!](http://hitchdev.com/strictyaml/why-not/ordinary-yaml)
- [Why not use kwalify with standard YAML to validate my YAML?](http://hitchdev.com/strictyaml/why-not/pykwalify)
- [Why not use python's schema library for validation?](http://hitchdev.com/strictyaml/why-not/python-schema)
- [Why not HOCON?](http://hitchdev.com/strictyaml/why-not/hocon)
- [Why not JSON5?](http://hitchdev.com/strictyaml/why-not/json5)
- [Why not use XML for configuration or DSLs?](http://hitchdev.com/strictyaml/why-not/xml)
- [Why shouldn't I just use python code for configuration?](http://hitchdev.com/strictyaml/why-not/turing-complete-code)
- [Why not use INI files?](http://hitchdev.com/strictyaml/why-not/ini)
- [Why not use SDLang?](http://hitchdev.com/strictyaml/why-not/sdlang)
- [Why not use JSON Schema for validation?](http://hitchdev.com/strictyaml/why-not/json-schema)



Using StrictYAML
----------------

- [compound](http://hitchdev.com/strictyaml/using/alpha/compound)

  - [Validating optional keys in mappings (Map)](http://hitchdev.com/strictyaml/using/alpha/compound/optional-keys)

  - [Using a YAML object of a parsed mapping](http://hitchdev.com/strictyaml/using/alpha/compound/mapping-yaml-object)

  - [Sequences of unique items (UniqueSeq)](http://hitchdev.com/strictyaml/using/alpha/compound/sequences-of-unique-items)

  - [Mappings with defined keys (Map)](http://hitchdev.com/strictyaml/using/alpha/compound/mapping)

  - [Mappings with arbitrary key names (MapPattern)](http://hitchdev.com/strictyaml/using/alpha/compound/map-pattern)

  - [Fixed length sequences (FixedSeq)](http://hitchdev.com/strictyaml/using/alpha/compound/fixed-length-sequences)

  - [Sequence/list validator (Seq)](http://hitchdev.com/strictyaml/using/alpha/compound/sequences)

  - [Mapping with defined keys and a custom key validator (Map)](http://hitchdev.com/strictyaml/using/alpha/compound/mapping-with-slug-keys)

- [howto](http://hitchdev.com/strictyaml/using/alpha/howto)

  - [Revalidate an already validated document](http://hitchdev.com/strictyaml/using/alpha/howto/revalidation)

  - [Merge YAML documents](http://hitchdev.com/strictyaml/using/alpha/howto/merge-yaml-documents)

  - [Parsing YAML without a schema](http://hitchdev.com/strictyaml/using/alpha/howto/without-a-schema)

  - [Labeling exceptions](http://hitchdev.com/strictyaml/using/alpha/howto/label-exceptions)

  - [Build a YAML document from scratch in code](http://hitchdev.com/strictyaml/using/alpha/howto/build-yaml-document)

  - [Reading in YAML, editing it and writing it back out](http://hitchdev.com/strictyaml/using/alpha/howto/roundtripping)

  - [Get line numbers of YAML elements](http://hitchdev.com/strictyaml/using/alpha/howto/what-line)

  - [Either/or schema validation of two equally valid different kinds of YAML](http://hitchdev.com/strictyaml/using/alpha/howto/either-or-validation)

- [scalar](http://hitchdev.com/strictyaml/using/alpha/scalar)

  - [Validating strings with regexes (Regex)](http://hitchdev.com/strictyaml/using/alpha/scalar/regular-expressions)

  - [Integers (Int)](http://hitchdev.com/strictyaml/using/alpha/scalar/integer)

  - [Empty key validation](http://hitchdev.com/strictyaml/using/alpha/scalar/empty)

  - [Floating point numbers (Float)](http://hitchdev.com/strictyaml/using/alpha/scalar/float)

  - [Decimal numbers (Decimal)](http://hitchdev.com/strictyaml/using/alpha/scalar/decimal)

  - [Enumerated scalars (Enum)](http://hitchdev.com/strictyaml/using/alpha/scalar/enum)

  - [Parsing strings (Str)](http://hitchdev.com/strictyaml/using/alpha/scalar/string)

  - [Boolean (Bool)](http://hitchdev.com/strictyaml/using/alpha/scalar/boolean)

  - [Email and URL validators](http://hitchdev.com/strictyaml/using/alpha/scalar/email-and-url)

  - [Datetimes (Datetime)](http://hitchdev.com/strictyaml/using/alpha/scalar/datetime)

  - [Parsing comma separated items (CommaSeparated)](http://hitchdev.com/strictyaml/using/alpha/scalar/comma-separated)

- [restrictions](http://hitchdev.com/strictyaml/using/alpha/restrictions)

  - [Disallowed YAML](http://hitchdev.com/strictyaml/using/alpha/restrictions/disallowed-yaml)

  - [Duplicate keys](http://hitchdev.com/strictyaml/using/alpha/restrictions/duplicate-keys)




Design justifications
---------------------

There are some design decisions in StrictYAML which are controversial
and/or not obvious. Those are documented here:

- [What is wrong with explicit tags?](http://hitchdev.com/strictyaml/why/explicit-tags-removed)
- [What is wrong with explicit syntax typing in a readable configuration language?](http://hitchdev.com/strictyaml/why/syntax-typing-bad)
- [What is wrong with implicit typing?](http://hitchdev.com/strictyaml/why/implicit-typing-removed)
- [What is wrong with flow style YAML?](http://hitchdev.com/strictyaml/why/flow-style-removed)
- [Why does StrictYAML only parse from strings and not files?](http://hitchdev.com/strictyaml/why/only-parse-strings-not-files)
- [What is wrong with duplicate keys?](http://hitchdev.com/strictyaml/why/duplicate-keys-disallowed)
- [Why does StrictYAML not parse direct representations of python objects?](http://hitchdev.com/strictyaml/why/binary-data-removed)
- [What is wrong with node anchors and references?](http://hitchdev.com/strictyaml/why/node-anchors-and-references-removed)
- [Why does StrictYAML make you define a schema in python - a turing complete language?](http://hitchdev.com/strictyaml/why/turing-complete-schema)


Breaking changes
----------------

0.5: Data is now parsed by default as a YAML object instead of directly to dict/list. To get dict/list and ordinary values as before, get yaml_object.data.

Contributors
------------

- @gvx
- @AlexandreDecan
- @lots0logs
- @tobbez
