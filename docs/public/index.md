---
title: StrictYAML
---

{{< github-stars user="crdoconnor" project="strictyaml" >}}


StrictYAML is a [type-safe](https://en.wikipedia.org/wiki/Type_safety) YAML parser
that parses and validates a [restricted subset](features-removed) of the [YAML](what-is-yaml)
specification.

Priorities:

- Beautiful API
- Refusing to parse [the ugly, hard to read and insecure features of YAML](features-removed) like [the Norway problem](why/implicit-typing-removed).
- Strict validation of markup and straightforward type casting.
- Clear, readable exceptions with **code snippets** and **line numbers**.
- Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
- Ability to read in YAML, make changes and write it out again with comments preserved.
- [Not speed](why/speed-not-a-priority), currently.


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
YAML({'name': 'Ford Prefect', 'age': '42', 'possessions': ['Towel']})
```



All data is string, list or OrderedDict:


```python
>>> load(yaml_snippet).data
{'name': 'Ford Prefect', 'age': '42', 'possessions': ['Towel']}
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
{'name': 'Ford Prefect', 'age': 42, 'possessions': ['Towel']}
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

- [Why avoid using environment variables as configuration?](why-not/)
- [Why not HOCON?](why-not/)
- [Why not use INI files?](why-not/)
- [Why not use JSON Schema for validation?](why-not/)
- [Why not JSON for simple configuration files?](why-not/)
- [Why not JSON5?](why-not/)
- [Why not use the YAML 1.2 standard? - we don't need a new standard!](why-not/)
- [Why not use kwalify with standard YAML to validate my YAML?](why-not/)
- [Why not use Python's schema library (or similar) for validation?](why-not/)
- [Why not use SDLang?](why-not/)
- [What is wrong with TOML?](why-not/)
- [Why shouldn't I just use Python code for configuration?](why-not/)
- [Why not use XML for configuration or DSLs?](why-not/)



## Using StrictYAML

How to:

- [Build a YAML document from scratch in code](using/alpha/howto/)
- [Either/or schema validation of different, equally valid different kinds of YAML](using/alpha/howto/)
- [Labeling exceptions](using/alpha/howto/)
- [Merge YAML documents](using/alpha/howto/)
- [Revalidate an already validated document](using/alpha/howto/)
- [Reading in YAML, editing it and writing it back out](using/alpha/howto/)
- [Get line numbers of YAML elements](using/alpha/howto/)
- [Parsing YAML without a schema](using/alpha/howto/)


Compound validators:

- [Fixed length sequences (FixedSeq)](using/alpha/compound/)
- [Mappings combining defined and undefined keys (MapCombined)](using/alpha/compound/)
- [Mappings with arbitrary key names (MapPattern)](using/alpha/compound/)
- [Mapping with defined keys and a custom key validator (Map)](using/alpha/compound/)
- [Using a YAML object of a parsed mapping](using/alpha/compound/)
- [Mappings with defined keys (Map)](using/alpha/compound/)
- [Optional keys with defaults (Map/Optional)](using/alpha/compound/)
- [Validating optional keys in mappings (Map)](using/alpha/compound/)
- [Sequences of unique items (UniqueSeq)](using/alpha/compound/)
- [Sequence/list validator (Seq)](using/alpha/compound/)
- [Updating document with a schema](using/alpha/compound/)


Scalar validators:

- [Boolean (Bool)](using/alpha/scalar/)
- [Parsing comma separated items (CommaSeparated)](using/alpha/scalar/)
- [Datetimes (Datetime)](using/alpha/scalar/)
- [Decimal numbers (Decimal)](using/alpha/scalar/)
- [Email and URL validators](using/alpha/scalar/)
- [Empty key validation](using/alpha/scalar/)
- [Enumerated scalars (Enum)](using/alpha/scalar/)
- [Floating point numbers (Float)](using/alpha/scalar/)
- [Hexadecimal Integers (HexInt)](using/alpha/scalar/)
- [Integers (Int)](using/alpha/scalar/)
- [Validating strings with regexes (Regex)](using/alpha/scalar/)
- [Parsing strings (Str)](using/alpha/scalar/)


Restrictions:

- [Disallowed YAML](using/alpha/restrictions/)
- [Duplicate keys](using/alpha/restrictions/)
- [Dirty load](using/alpha/restrictions/)



## Design justifications

There are some design decisions in StrictYAML which are controversial
and/or not obvious. Those are documented here:

- [What is wrong with duplicate keys?](why/)
- [What is wrong with explicit tags?](why/)
- [What is wrong with flow-style YAML?](why/)
- [The Norway Problem - why StrictYAML refuses to do implicit typing and so should you](why/)
- [What is wrong with node anchors and references?](why/)
- [Why does StrictYAML not parse direct representations of Python objects?](why/)
- [Why does StrictYAML only parse from strings and not files?](why/)
- [Why is parsing speed not a high priority for StrictYAML?](why/)
- [What is syntax typing?](why/)
- [Why does StrictYAML make you define a schema in Python - a Turing-complete language?](why/)



## Star Contributors

- @wwoods
- @chrisburr
- @jnichols0

## Other Contributors

- @eulores
- @WaltWoods
- @ChristopherGS
- @gvx
- @AlexandreDecan
- @lots0logs
- @tobbez
- @jaredsampson
- @BoboTIG

StrictYAML also includes code from [ruamel.yaml](https://yaml.readthedocs.io/en/latest/), Copyright Anthon van der Neut.

## Contributing

- Before writing any code, please read the tutorial on [contributing to hitchdev libraries](https://hitchdev.com/approach/contributing-to-hitch-libraries/).
- Before writing any code, if you're proposing a new feature, please raise it on github. If it's an existing feature / bug, please comment and briefly describe how you're going to implement it.
- All code needs to come accompanied with a story that exercises it or a modification to an existing story. This is used both to test the code and build the documentation.