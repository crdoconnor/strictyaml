---
title: Why not use TOML?
---

[TOML](https://github.com/toml-lang/toml) is a redesigned configuration language that's essentially an extended version of INI which
allows the expression of both hierarchical and typed data.

TOML's main criticism of YAML is spot on::

  TOML aims for simplicity, a goal which is not apparent in the YAML specification.

StrictYAML's cut down version of the YAML specification - with implicit typing, node anchors/references and flow style cut out,
ends up being *simpler* than TOML.

While TOML works well enough for simple data - perhaps as a drop in replacement for the INI files which inspired it -
things start to get a little hairier when you have more complex nested tables/arrays.

## 1. Nesting

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

In order to partially circumvent this issue, complicated TOML is often presented with indentation. For example:

* https://github.com/gazreese/gazreese.com/blob/c4c3fa7d576a4c316f11f0f7a652ca11ab23586d/Hugo/config.toml
* https://github.com/leereilly/csi/blob/567e5b55f766847c9dcc7de482c0fd241fa7377a/lib/data/master.toml
* https://github.com/CzarSimon/simonlindgren.info/blob/a391a6345b16f2d8093f6d4c5f422399b4b901eb/simon-cv/config.toml

## 2. Syntax Typing

Like most other markup languages TOML has [syntax typing](../../why/syntax-typing-bad).

```toml
flt2 = 3.1415
string = "hello"
```

StrictYAML (except for a few very niche edge cases) simply does not require quotes around any value to
infer a data type. So, for instance:

```yaml
flt2: 3.1415
string: hello
```

Will simply parse as string:

```python
>>> load(yaml).data
{"flt2": "3.1415", "string": "hello"}
```

...unless directed to parse as something else by the schema:

```python
>>> load(yaml, Map({"flt2": Float(), "string": Str()})).data
{"flt": 3.1415, "string": "hello"}
```

The schema based approach not only eliminates the need for syntax typing, making the markup terser,
it is more type-safe at the same time.


## 3. Duplicate keys

TOML, like standard YAML, allows [duplicate keys](../../why/duplicate-keys-disallowed) which can lead to ambiguity and bugs.
