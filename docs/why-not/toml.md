---
title: What is wrong with TOML?
---

[TOML](https://github.com/toml-lang/toml) is an improved version of INI -
analogous to how [StrictYAML](https://github.com/crdoconnor/strictyaml) is a
improved version of YAML.

As Martin Vejnár, author of PyTOML [argues](https://github.com/avakar/pytoml/issues/15#issuecomment-217739462),
while TOML works acceptably well for representing simple data structures and shallow hierarchies,
it becomes more unwieldy the larger and more complex the hierarchy:

>TOML is a bad file format. **It looks good at first glance**, and for really really
>trivial things it is probably good. But once I started using it and the
>configuration schema became more complex, I found the syntax ugly and hard to read.

What specifically goes wrong? Read on:


## 1. TOML's hierarchy is difficult to infer from syntax alone

Mapping hierarchy in TOML is determined by dots. This is simple enough for
parsers to read and understand but unfortunately humans find it difficult to infer.

The solution to this problem has been for creators of TOML documents to
*introduce* non-meaningful indentation to make it easier for *humans* to read
what parsers already understand:

* https://github.com/gazreese/gazreese.com/blob/c4c3fa7d576a4c316f11f0f7a652ca11ab23586d/Hugo/config.toml
* https://github.com/leereilly/csi/blob/567e5b55f766847c9dcc7de482c0fd241fa7377a/lib/data/master.toml
* https://github.com/CzarSimon/simonlindgren.info/blob/a391a6345b16f2d8093f6d4c5f422399b4b901eb/simon-cv/config.toml

This parallels the way indentation is added in languages with syntactic markers - e.g. 
JSON, Javascript or Java to make it easier for humans to understand.

Python is a notable exception to this trend - syntactic markers are not necessary and neither
is auto-indentation for readability because the indentation *is* the marker.

The argument over the merits of meaningful indentation has been going on for longer than
StrictYAML's existence, but the various points are argued pretty well in this [stack exchange question about python](https://softwareengineering.stackexchange.com/questions/313034/why-should-a-language-prefer-indentation-over-explicit-markers-for-blocks). In summary:

1. Python inherited the significant indentation from the (now obsolete) predecessor language ABC. ABC is one of the very few programming languages which have used usability testing to direct the design. So while discussions about syntax usually comes down to subjective opinions and personal preferences, the choice of significant indentation actually have a sounder foundation.

2. Guido van Rossum came across subtle bugs where the indentation disagreed with the syntactic grouping. Meaningful indentation fixed this class of bug. Since there are no begin/end brackets there cannot be a disagreement between grouping perceived by the parser and the human reader.

3. Having symbols delimiting blocks and indentation violates the DRY principle.

4. It does away with the typical C debate of "where to put the curly braces".


## 2. It overcomplicates itself just like YAML did

Somewhat ironically, TOML's creator quite rightly criticizes YAML for not aiming for simplicity
and then unfortunately falls into the same trap itself. One way it does this is by
trying to include date and time parsing which imports *all* of the inherent complications associated
with [dates and times](https://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time).

StrictYAML separates parsing (which is part of the restricted spec) and type coercion (which isn't).

**The only three types StrictYAML parser cares about are mappings, sequences and strings**.

StrictYAML takes JSON's (arguably successful) approach - that is, that in order to maintain parser spec
simplicity, except for the *simplest* of data types, parsing and serialization of strings is a problem that
is complicated enough that is should be delegated to something else.

This avoids complicating the spec and isolates the **vastly** underestimated
complication of parsing strings into dates (or other things) and serializing them back to something
that specializes in this.

This is an example of the [UNIX philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) -
simple, short, clear, modular, and extensible.

{{< note title="Executable specification" >}}
StrictYAML *has* a validator that uses python's [most popular date/time parsing library](https://dateutil.readthedocs.io/en/stable/) as to *validate* and type-coerce dates but the deliberately
simplified StrictYAML *parser* spec assumes everything is a string.

Developers to create or use their own date parser/serializer if it suits their needs better.
{{< /note >}}


## 3. It implements syntax typing

Like most other markup languages TOML has [syntax typing](../../why/syntax-typing-bad) -
the *writer* of the markup decides if, for example, something should be parsed as a number
or a string:

```toml
flt2 = 3.1415
string = "hello"
```

StrictYAML does not require quotes around any value to infer a data type. So, for instance:

```yaml
flt2: 3.1415
string: hello
```

Will parse as a float if directed by the parser:

```python
>>> load(yaml, Map({"flt2": Float(), "string": Str()})).data
{"flt": 3.1415, "string": "hello"}
```

And will reject *non* floats with an error.

Or, it will default to string if no schema is given, avoiding all ambiguity:

```python
>>> load(yaml).data
{"flt2": "3.1415", "string": "hello"}
```

Avoiding syntax typing and delegating type information to a schema
is another way that YAML documents that convey equivalent information can be
kept terser and thus easier to read.
