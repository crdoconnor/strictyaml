---
title: What is wrong with explicit syntax typing in a readable configuration language?
---

Explicit syntax typing is the process of using syntax to define types in markup. So, for instance in JSON, quotation marks are used to define name as a string and age as a number:

´´´json
{"name": "Arthur Dent", "age": 42}
´´´

This helps distinguish the types for the parser, which is useful for JSON, but it also comes with two disadvantages:

- The distinction is subtle and not particularly clear to *non-programmers*, who will not necessarily understand that a directive needs to be given to the parser to avoid it being misinterpreted.
- It's not necessary if the type structure is maintained outside of the markup.
- Verbosity - two extra characters per string makes the markup longer and noisier.

In JSON when being used as a REST API, syntax typing is often an *advantage* - it is explicit to the machine reading the JSON that "string" and "age" is an integer and it can convert accordingly *in the absence of a schema*.

StrictYAML assumes all values are strings unless the schema explicitly indicates otherwise (e.g. Map(Int(), Int())).

StrictYAML does not require quotation marks for strings that are implicitly converted to other types (e.g. yes or 1.5), but it does require quotation marks for strings that are syntactically confusing (e.g. "{ text in curly brackets }")

Regular YAML has explicit `syntax typing <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#whats-wrong-with-syntax-typing-in-a-readable-configuration-language>`_
to explicitly declare strings, although it's confusing as hell to know when it's required and when it is not. For example::

´´´yaml
  a: text               # not necessary
  b: "yes"              # necessary
  c: "0"                # necessary
  d: "3.5"              # necessary
  e: in                 # not necssary
  f: out                # not necesary
  g: shake it all about # not necessary
  h: "on"               # necessary
´´´

Several other configuration language formats also have syntax typing in lieu of schemas. They are:

- TOML
- JSON5
- HJSON
- SDLang
- HOCON

INI does not.
