---
title: Why not use TOML?
---

[TOML](https://github.com/toml-lang/toml) is a redesigned configuration language that's essentially an extended version of INI which
allows the expression of both hierarchical and typed data.

TOML's main criticism of YAML is spot on::

  TOML aims for simplicity, a goal which is not apparent in the YAML specification.

StrictYAML's cut down version of the YAML specification - with implicit typing, node anchors/references and flow style cut out,
ends up being *simpler* than TOML.

While TOML works well enough for simple data - much like the INI files which inspired it - things start to get a little
hairier when you have nested tables/arrays.

For example:

```toml
# not clear that this is an array
[[tables]]
foo = "foo"
```

Similarly, all arrays have the type `array`. So even though arrays are homogenous in TOML, you can oddly do:

```toml
array = [["foo"], [1]]

# but not
array = ["foo", 1]
```

TOML's overall structure is also less intuitive. So, for example, this:

```toml
[[fruit]]
name = "apple"

[fruit.physical]
color = "red"
shape = "round"
```

Is not as clear as this:

```yaml
fruit:
  name: apple
  physical:
    color: red
    shape: round
```

Finally, like most other markup languages it does [syntax typing](../why/syntax-typing-bad):

```toml
flt2 = 3.1415
string = "hello"
```

Whereas, strictyaml(except for a few niche edge cases) simply does not need quotes around any value:

```yaml
flt2: 3.1415
string: hello
```

...since is parses *everything* as string by default:

```python
>>> load(yaml).data
{"flt2": "3.1415", "string": "hello"}
```

...and will parse to other types if that's what the schema says to do:

```python
>>> load(yaml, Map({"flt2": Float(), "string": Str()})).data
{"flt": 3.1415, "string": "hello"}
```

The schema based approach not only eliminates the need for syntax typing, it is more typesafe.
