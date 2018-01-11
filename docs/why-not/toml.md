---
title: Why not use TOML?
---

[TOML](https://github.com/toml-lang/toml) is a redesigned configuration language that's essentially an extended version of INI which
allows the expression of both hierarchical and typed data.

TOML's main criticism of YAML is spot on::

  TOML aims for simplicity, a goal which is not apparent in the YAML specification.

StrictYAML's cut down version of the YAML specification however - with implicit typing, node anchors/references and flow style cut out,
ends up being simpler than TOML.

The main complication in TOML is its inconsistency in how it handles tables and arrays. For example:

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

TOML's use of special characters for delimiters instead of whitespace like YAML makes the resulting output noiser and harder for humans
to parse. Here's an example from the TOML site:

```toml
[[fruit]]
name = "apple"

[fruit.physical]
color = "red"
shape = "round"
```

Equivalent YAML:

```yaml
fruit:
  name: apple
  physical:
    color: red
    shape: round
```

It also embeds type information used by the parser into the syntax:

```toml
flt2 = 3.1415
string = "hello"
```

Whereas strictyaml:

```yaml
flt2: 3.1415
string: hello
```

Will yield this:

```python
>>> load(yaml).data
{"flt2": "3.1415", "string": "hello"}
```

Or this:

```python
>>> load(yaml, Map({"flt2": Float(), "string": Str()})).data
{"flt": 3.1415, "string": "hello"}
```

This not only eliminates the need for [syntax typing](https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-wrong-with-explicit-syntax-typing-in-a-readable-configuration-languages>), it adds more type safety.
