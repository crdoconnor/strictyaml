# StrictYAML

StrictYAML is a [type-safe](https://en.wikipedia.org/wiki/Type_safety) YAML parser
that parses and validates a [restricted subset](https://hitchdev.com/strictyaml/features-removed) of the [YAML](https://hitchdev.com/strictyaml/what-is-yaml)
specification.

Priorities:

- Beautiful API
- Refusing to parse [the ugly, hard to read and insecure features of YAML](https://hitchdev.com/strictyaml/features-removed) like [the Norway problem](https://hitchdev.com/strictyaml/why/implicit-typing-removed).
- Strict validation of markup and straightforward type casting.
- Clear, readable exceptions with **code snippets** and **line numbers**.
- Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
- Ability to read in YAML, make changes and write it out again with comments preserved.
- [Not speed](https://hitchdev.com/strictyaml/why/speed-not-a-priority), currently.


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
from strictyaml import load, Map, Str, Int, Seq, YAMLError, as_document

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



And construct YAML documents from dicts or lists:


```python
print(as_document({"x": 1}).as_yaml())

```

```yaml
x: 1
```






## Install

```sh
$ pip install strictyaml
```

## Why StrictYAML?

There are a number of formats and approaches that can achieve more or
less the same purpose as StrictYAML. I've tried to make it the best one.
Below is a series of documented justifications:


- [Why not use JSON Schema for validation?](https://hitchdev.com/strictyaml/why-not/json-schema)
- [What is wrong with TOML?](https://hitchdev.com/strictyaml/why-not/toml)
- [Why shouldn't I just use Python code for configuration?](https://hitchdev.com/strictyaml/why-not/turing-complete-code)
- [Why not JSON5?](https://hitchdev.com/strictyaml/why-not/json5)
- [Why not JSON for simple configuration files?](https://hitchdev.com/strictyaml/why-not/json)
- [Why avoid using environment variables as configuration?](https://hitchdev.com/strictyaml/why-not/environment-variables-as-config)
- [Why not use XML for configuration or DSLs?](https://hitchdev.com/strictyaml/why-not/xml)
- [Why not use INI files?](https://hitchdev.com/strictyaml/why-not/ini)
- [Why not use the YAML 1.2 standard? - we don't need a new standard!](https://hitchdev.com/strictyaml/why-not/ordinary-yaml)
- [Why not use Python's schema library (or similar) for validation?](https://hitchdev.com/strictyaml/why-not/python-schema)
- [Why not HOCON?](https://hitchdev.com/strictyaml/why-not/hocon)
- [Why not use SDLang?](https://hitchdev.com/strictyaml/why-not/sdlang)
- [Why not use kwalify with standard YAML to validate my YAML?](https://hitchdev.com/strictyaml/why-not/pykwalify)



## Using StrictYAML

How to:

- [Merge YAML documents](https://hitchdev.com/strictyaml/using/alpha/howto/merge-yaml-documents)
- [Build a YAML document from scratch in code](https://hitchdev.com/strictyaml/using/alpha/howto/build-yaml-document)
- [Reading in YAML, editing it and writing it back out](https://hitchdev.com/strictyaml/using/alpha/howto/roundtripping)
- [Get line numbers of YAML elements](https://hitchdev.com/strictyaml/using/alpha/howto/what-line)
- [Either/or schema validation of different, equally valid different kinds of YAML](https://hitchdev.com/strictyaml/using/alpha/howto/either-or-validation)
- [Labeling exceptions](https://hitchdev.com/strictyaml/using/alpha/howto/label-exceptions)
- [Parsing YAML without a schema](https://hitchdev.com/strictyaml/using/alpha/howto/without-a-schema)
- [Revalidate an already validated document](https://hitchdev.com/strictyaml/using/alpha/howto/revalidation)


Compound validators:

- [Using a YAML object of a parsed mapping](https://hitchdev.com/strictyaml/using/alpha/compound/mapping-yaml-object)
- [Mapping with defined keys and a custom key validator (Map)](https://hitchdev.com/strictyaml/using/alpha/compound/mapping-with-slug-keys)
- [Mappings with defined keys (Map)](https://hitchdev.com/strictyaml/using/alpha/compound/mapping)
- [Updating document with a schema](https://hitchdev.com/strictyaml/using/alpha/compound/update)
- [Validating optional keys in mappings (Map)](https://hitchdev.com/strictyaml/using/alpha/compound/optional-keys)
- [Mappings with arbitrary key names (MapPattern)](https://hitchdev.com/strictyaml/using/alpha/compound/map-pattern)
- [Optional keys with defaults (Map/Optional)](https://hitchdev.com/strictyaml/using/alpha/compound/optional-keys-with-defaults)
- [Sequence/list validator (Seq)](https://hitchdev.com/strictyaml/using/alpha/compound/sequences)
- [Sequences of unique items (UniqueSeq)](https://hitchdev.com/strictyaml/using/alpha/compound/sequences-of-unique-items)
- [Fixed length sequences (FixedSeq)](https://hitchdev.com/strictyaml/using/alpha/compound/fixed-length-sequences)


Scalar validators:

- [Empty key validation](https://hitchdev.com/strictyaml/using/alpha/scalar/empty)
- [Datetimes (Datetime)](https://hitchdev.com/strictyaml/using/alpha/scalar/datetime)
- [Floating point numbers (Float)](https://hitchdev.com/strictyaml/using/alpha/scalar/float)
- [Email and URL validators](https://hitchdev.com/strictyaml/using/alpha/scalar/email-and-url)
- [Parsing comma separated items (CommaSeparated)](https://hitchdev.com/strictyaml/using/alpha/scalar/comma-separated)
- [Integers (Int)](https://hitchdev.com/strictyaml/using/alpha/scalar/integer)
- [Decimal numbers (Decimal)](https://hitchdev.com/strictyaml/using/alpha/scalar/decimal)
- [Boolean (Bool)](https://hitchdev.com/strictyaml/using/alpha/scalar/boolean)
- [Validating strings with regexes (Regex)](https://hitchdev.com/strictyaml/using/alpha/scalar/regular-expressions)
- [Parsing strings (Str)](https://hitchdev.com/strictyaml/using/alpha/scalar/string)
- [Enumerated scalars (Enum)](https://hitchdev.com/strictyaml/using/alpha/scalar/enum)


Restrictions:

- [Disallowed YAML](https://hitchdev.com/strictyaml/using/alpha/restrictions/disallowed-yaml)
- [Dirty load](https://hitchdev.com/strictyaml/using/alpha/restrictions/loading-dirty-yaml)
- [Duplicate keys](https://hitchdev.com/strictyaml/using/alpha/restrictions/duplicate-keys)


## Design justifications

There are some design decisions in StrictYAML which are controversial
and/or not obvious. Those are documented here:

- [Why is parsing speed not a high priority for StrictYAML?](https://hitchdev.com/strictyaml/why/speed-not-a-priority)
- [What is syntax typing?](https://hitchdev.com/strictyaml/why/syntax-typing-bad)
- [What is wrong with node anchors and references?](https://hitchdev.com/strictyaml/why/node-anchors-and-references-removed)
- [What is wrong with duplicate keys?](https://hitchdev.com/strictyaml/why/duplicate-keys-disallowed)
- [What is wrong with explicit tags?](https://hitchdev.com/strictyaml/why/explicit-tags-removed)
- [The Norway Problem - why StrictYAML refuses to do implicit typing and so should you](https://hitchdev.com/strictyaml/why/implicit-typing-removed)
- [Why does StrictYAML not parse direct representations of Python objects?](https://hitchdev.com/strictyaml/why/not-parse-direct-representations-of-python-objects)
- [Why does StrictYAML only parse from strings and not files?](https://hitchdev.com/strictyaml/why/only-parse-strings-not-files)
- [Why does StrictYAML make you define a schema in Python - a turing complete language?](https://hitchdev.com/strictyaml/why/turing-complete-schema)
- [What is wrong with flow style YAML?](https://hitchdev.com/strictyaml/why/flow-style-removed)


## Star Contributors

- @wwoods

## Contributors

- @gvx
- @AlexandreDecan
- @lots0logs
- @tobbez
- @jaredsampson
- @BoboTIG

## Contributing

* Before writing any code, please read the tutorial on [contributing to hitchdev libraries](https://hitchdev.com/approach/contributing-to-hitch-libraries/).

* Before writing any code, if you're proposing a new feature, please raise it on github. If it's an existing feature / bug, please comment and briefly describe how you're going to implement it.

* All code needs to come accompanied with a story that exercises it or a modification to an existing story. This is used both to test the code and build the documentation.

