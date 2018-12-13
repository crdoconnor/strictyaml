---
title: What is syntax typing?
---

Explicit syntax typing is the use of syntax to designate the type of some data.
It is a feature of the design of most programming languages.

```python
x = "11" # this is a string
y = 11   # this isn't
```

It it isn't limited to programming languages though. It's a common feature of
serialization formats like JSON:

```json
{"x": "11", "y": 42}
```

But not others, like INI:

```ini
server=192.0.2.62
port=143
```

Or CSV:

```ini
server,port
192.0.2.62,143
```

Or StrictYAML:

```yaml
server: 192.0.2.62
port: 143
```

In those cases, it's up to the program - in another file - to decide what part
of that data is and what part is an integer.

## What does it mean to attach syntax typing to data?

Syntax typing the explicit prioritization of cohesion over terseness. It
puts type information right next to the data, but in the process this
means that if the data appears a *lot*

## When would you sacrifice terseness?

Let's return to python for a second and imagine that 

```python
x = "11" # this is a string
y = 11   # this isn't
```



This helps distinguish the types for the parser, which is useful for JSON, but it also comes with two disadvantages:

- The distinction is subtle and not particularly clear to *non-programmers*, who will not necessarily understand that a directive needs to be given to the parser to avoid it being misinterpreted.
- It's not necessary if the type structure is maintained outside of the markup.
- Verbosity - two extra characters per string makes the markup longer and noisier.

In JSON when being used as a REST API, syntax typing is often an *advantage* - it is explicit to the machine reading the JSON that "string" and "age" is an integer and it can convert accordingly *in the absence of a schema*.

StrictYAML assumes all values are strings unless the schema explicitly indicates otherwise (e.g. Map(Int(), Int())).

StrictYAML does not require quotation marks for strings that are implicitly converted to other types (e.g. yes or 1.5), but it does require quotation marks for strings that are syntactically confusing (e.g. "{ text in curly brackets }")

Standard YAML has explicit syntax typing to explicitly declare strings, although it's confusing as hell to know when it's required and when it is not. For example:

```yaml
a: text               # not necessary
b: "yes"              # necessary
c: "0"                # necessary
d: "3.5"              # necessary
e: in                 # not necssary
f: out                # not necesary
g: shake it all about # not necessary
h: "on"               # necessary
```

Most other configuration language formats also make use of syntax typing. For example:

- [TOML](../../why-not/toml)
- [JSON5](../../why-not/json5)
- [HJSON](../../why-not/hjson)
- [SDLang](../../why-not/sdlang)
- [HOCON](../../why-not/hocon)

[INI](../../why-not/ini) does not have explicit syntax typing however.
