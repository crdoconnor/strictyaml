---
title: What is wrong with TOML?
---

[TOML](https://github.com/toml-lang/toml) is an improved version of [INI](../ini) -
analogous to this project - [StrictYAML](https://github.com/crdoconnor/strictyaml) is a
improved version of YAML. They are both one of at least
[13 potential, often confusing choices](../) for parsing and serializing
configuration files.

To be clear, I am against the use of TOML but I think that it isn't the worst choice
provided you use it infrequently, for relatively small and non-complex configuration
files.

Martin Vejnár, the author of PyTOML
[argued exactly this](https://github.com/avakar/pytoml/issues/15#issuecomment-217739462)
initially built a TOML parser out of enthusiasm for this new format but later abandoned
it. When asked if he would like to see his library used as a dependency for pip as
part of [PEP-518](https://www.python.org/dev/peps/pep-0518/), he explained himself:

>TOML is a bad file format. **It looks good at first glance**, and for really really
>trivial things it is probably good. But once I started using it and the
>configuration schema became more complex, I found the syntax ugly and hard to read.

Ultimately, despite this PyPA still went ahead and used TOML for PEP-518, albeit
with a different parser.

I don't believe this to be an awful decision since pyproject.toml *is* fairly trivial
in its complexity and there's only one per project.

StrictYAML was designed to be a language to write
[readable tests with](../../../hitchstory), which requires all three of the same basic
data types (mapping, list and strings) but which depicts more complex hierarchies

So what specifically is wrong with TOML when you scale it up?


## 1. Human readability: TOML's hierarchy is difficult to infer from syntax alone

Mapping hierarchy in TOML is determined by dots. This is simple enough for
parsers to read and understand but this alone makes it difficult to perceive
the relationships between data.

This has been recognized by many TOML users who have adopted a method that
will be quite familiar to a lot of programmers:

[![Non-meaningful indentation](../toml-indentation-1.png)](https://github.com/gazreese/gazreese.com/blob/c4c3fa7d576a4c316f11f0f7a652ca11ab23586d/Hugo/config.toml)

Indentation that is meaningful to humans but not parsers (
[Other](https://github.com/leereilly/csi/blob/567e5b55f766847c9dcc7de482c0fd241fa7377a/lib/data/master.toml)
[examples](https://github.com/CzarSimon/simonlindgren.info/blob/a391a6345b16f2d8093f6d4c5f422399b4b901eb/simon-cv/config.toml)).

This parallels the way indentation is added in *lots* of programming languages with syntactic markers
- e.g.  JSON, Javascript or Java are all commonly rendered with non-parsed indentation to make it
easier for humans to understand.

But not python.

Python, has long been a stand out exception in how it was designed -
syntactic markers are *not* necessary to infer program structure because indentation *is* the marker
that determines program structure.

This argument over the merits of meaningful indentation in python has been going on for decades, but the various points are argued pretty well in this [stack exchange question asking why python did it](https://softwareengineering.stackexchange.com/questions/313034/why-should-a-language-prefer-indentation-over-explicit-markers-for-blocks). In summary:

1. Python inherited the significant indentation from the (now obsolete) predecessor language ABC. ABC is one of the very few programming languages which have used usability testing to direct the design. So while discussions about syntax usually comes down to subjective opinions and personal preferences, the choice of significant indentation actually have a sounder foundation.

2. Guido van Rossum came across subtle bugs where the indentation disagreed with the syntactic grouping. Meaningful indentation fixed this class of bug. Since there are no begin/end brackets there cannot be a disagreement between grouping perceived by the parser and the human reader.

3. Having symbols delimiting blocks and indentation violates the DRY principle.

4. It does away with the typical religious C debate of "where to put the curly braces".


## 2. Overcomplication: Like YAML it has too many features

Somewhat ironically, TOML's creator quite rightly criticizes YAML for not aiming for simplicity
and then unfortunately falls into the same trap itself - albeit not quite as deeply.

One way it does this is by trying to include date and time parsing which imports
*all* of the inherent complications associated with dates and times. Dates and times,
as many more experienced programmers are probably aware is an unexpectedly deep rabbit hole
of [complications and quirky, unexpected, bug inducing edge cases](https://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time).

The best way to deal with complications like these is to decouple, isolate the complexity and *delegate* it to a
[specialist tool that is good at handling that specific problem](https://en.wikipedia.org/wiki/Unix_philosophy).

StrictYAML takes JSON's (arguably successful) KISS approach - that is, for complex data types parsed from and
serialized to strings, parsing and serialization of strings should be delegated to another tool.

StrictYAML the library (as opposed to the format) has a validator that uses
[python's most popular date/time parsing library](https://dateutil.readthedocs.io/en/stable/) although
developers are encouraged to carefully consider their own need create their own
date parser/serializer using different tools if it doesn't fit their needs.


## 3. Human readability: TOML has noisy syntax

Like most other markup languages TOML has [syntax typing](../../why/syntax-typing-bad) -
the *writer* of the markup decides if, for example, something should be parsed as a number
or a string:

```toml
flt2 = 3.1415
string = "hello"
```

StrictYAML does not require quotes around any value to infer a data type because the
schema is assumed to be the single source of truth for type information:

```yaml
flt2: 3.1415
string: hello
```

In the above example it just removes two characters, but in larger documents with more
complex data, pushing type parsing decision to the schema (or assuming strings)
emoves an enormous amount of syntactic noise.

The lack of syntax typing combined with the use of indentation instead of square brackets
to denote hierarchies makes equivalent StrictYAML documents 10-20% shorter, cleaner
and ultimately more readable.

## Advantages of TOML still has over StrictYAML

There are currently still a few:

* StrictYAML does not currently have an "official spec". The spec is currently just "YAML 2.0 with [features removed](../../features-removed)". This has some advantages (e.g. YAML syntax highlighting in editors works just fine) but also some disadvantages (some documents will render differently).

* StrictYAML does not yet have parsers in languages other than python. If you'd like to write one for your language (if you don't also do validation it actually wouldn't be very complicated), contact me, I'd love to help you in any way I can - including doing a test suite and documentation.

* Popularity.
