---
title: What is wrong with TOML?
---

```yaml
# This is a TOML document.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
dob = 1979-05-27T07:32:00-08:00 # First class dates
```

[TOML](https://github.com/toml-lang/toml) is a configuration designed as a sort
of "improved" [INI file](../ini). It's analogous to this project -
[StrictYAML](https://github.com/crdoconnor/strictyaml), a similar attempt
to [fix YAML's flaws](../../features-removed):

```yaml
# All about the character
name: Ford Prefect
age: 42
possessions:
- Towel
```

I'm not going to argue here that TOML is the *worst* file format out there -
if you use it infrequently on small and simple files it does its job fine.

It's a warning though: as you scale up its usage, many bad warts start to appear.

Martin Vejnár, the author of PyTOML
[argued exactly this](https://github.com/avakar/pytoml/issues/15#issuecomment-217739462).
He initially built a TOML parser out of enthusiasm for this new format but later abandoned
it. When asked if he would like to see his library used as a dependency for pip as
part of [PEP-518](https://www.python.org/dev/peps/pep-0518/), he said no - and
explained why he abandoned the project:

>TOML is a bad file format. **It looks good at first glance**, and for really really
>trivial things it is probably good. But once I started using it and the
>configuration schema became more complex, I found the syntax ugly and hard to read.

Despite this, PyPA still went ahead and used TOML for PEP-518. Fortunately
pyproject.toml *is* fairly trivial and appears just once per project
so the problems he alludes to aren't that pronounced.

StrictYAML, by contrast, was designed to be a language to write
[readable 'story' tests](../../../hitchstory) where there will be *many* files
per project with more complex hierarchies, a use case where TOML starts
to really suck.

So what specifically *is* wrong with TOML when you scale it up?


## 1. It's very verbose. It's not DRY. It's syntactically noisy.

In [this example of a StrictYAML story](https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/map.story)
and [its equivalent serialized TOML](https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/map.toml)
the latter ends up [spending](https://www.goodreads.com/quotes/775257-my-point-today-is-that-if-we-wish-to-count) 
**50% more** characters to represent the exact same data.

This is largely due to the design decision to have the full name of every key being
associated with every value which is **not** [DRY](../../../code-quality/least-code).

It is also partly due to the large numbers of syntactic cruft - quotation marks
and square brackets dominate TOML documents whereas in the StrictYAML example they are
absent.

Shortening program lengths (and DRYing code), all other things being equal,
[reduces the number of bugs significantly](https://blog.codinghorror.com/diseconomies-of-scale-and-lines-of-code/)
because maintenance becomes easier and deriving intent from the code becomes clearer.
What goes for Turing-complete code also applies to configuration code.


## 2. TOML's hierarchies are difficult to infer from syntax alone

Mapping hierarchy in TOML is determined by dots. This is simple enough for
parsers to read and understand but this alone makes it difficult to perceive
the relationships between data.

This has been recognized by [many](https://github.com/leereilly/csi/blob/567e5b55f766847c9dcc7de482c0fd241fa7377a/lib/data/master.toml) TOML [writers](https://github.com/CzarSimon/simonlindgren.info/blob/a391a6345b16f2d8093f6d4c5f422399b4b901eb/simon-cv/config.toml) who have adopted a method that
will be quite familiar to a lot of programmers - indentation that the parser ignores:

[![Non-meaningful indentation](../toml-indentation-1.png)](https://github.com/gazreese/gazreese.com/blob/c4c3fa7d576a4c316f11f0f7a652ca11ab23586d/Hugo/config.toml)

This parallels the way indentation is added in *lots* of programming languages that have syntactic markers
like brackets - e.g.  JSON, Javascript or Java are all commonly rendered with non-parsed indentation to make it
easier for humans to understand them.

But not Python.

Python, has long been a stand out exception in how it was designed -
syntactic markers are *not* necessary to infer program structure because indentation *is* the marker
that determines program structure.

This argument over the merits of meaningful indentation in Python has been going on for decades, and [not everybody agrees with this](https://www.quora.com/Do-you-think-that-indentation-in-Python-is-annoying), but it's generally
considered a good idea - usually for [the reasons argued in this stack exchange question](https://softwareengineering.stackexchange.com/questions/313034/why-should-a-language-prefer-indentation-over-explicit-markers-for-blocks):

1. Python inherited the significant indentation from the (now obsolete) predecessor language ABC. ABC is one of the very few programming languages which have used usability testing to direct the design. So while discussions about syntax usually comes down to subjective opinions and personal preferences, the choice of significant indentation actually has a sounder foundation.

2. Guido van Rossum came across subtle bugs where the indentation disagreed with the syntactic grouping. Meaningful indentation fixed this class of bug. Since there are no begin/end brackets there cannot be a disagreement between grouping perceived by the parser and the human reader.

3. Having symbols delimiting blocks and indentation violates the DRY principle.

4. It does away with the typical religious C debate of "where to put the curly braces" (although TOML is not yet popular enough to inspire such religious wars over indentation... yet).


## 3. Overcomplication: Like YAML, TOML has too many features

Somewhat ironically, TOML's creator quite rightly
[criticizes YAML for not aiming for simplicity](https://github.com/toml-lang/toml#comparison-with-other-formats)
and then falls into the same trap itself - albeit not quite as deeply.

One way it does this is by trying to include date and time parsing which imports
*all* of the inherent complications associated with dates and times.

Dates and times, as many more experienced programmers are probably aware is an unexpectedly deep rabbit hole
of [complications and quirky, unexpected, headache and bug inducing edge cases](https://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time). TOML experiences [many](https://github.com/uiri/toml/issues/55) [of these](https://github.com/uiri/toml/issues/196) [edge cases](https://github.com/uiri/toml/issues/202) because of this.

The best way to deal with [essential complexity](https://simplicable.com/new/accidental-complexity-vs-essential-complexity) like these is to decouple, isolate the complexity and *delegate* it to a
[specialist tool that is good at handling that specific problem](https://en.wikipedia.org/wiki/Unix_philosophy)
which you can swap out later if required.

This the approach that JSON took (arguably a good decision) and it's the approach that StrictYAML takes too.

StrictYAML the library (as opposed to the format) has a validator that uses
[Python's most popular date/time parsing library](https://dateutil.readthedocs.io/en/stable/) although
developers are not obliged or even necessarily encouraged to use this. StrictYAML parses everything as a
string by default and whatever validation occurs later is considered to be outside of its purview.


## 4. Syntax typing

Like most other markup languages TOML has [syntax typing](../../why/syntax-typing-bad) -
the *writer* of the markup decides if, for example, something should be parsed as a number
or a string:

```toml
flt2 = 3.1415
string = "hello"
```

Programmers will feel at home maintaining this, but non programmers tend to find the
difference between "1.5" and 1.5 needlessly confusing.

StrictYAML does not require quotes around any value to infer a data type because the
schema is assumed to be the single source of truth for type information:

```yaml
flt2: 3.1415
string: hello
```

In the above example it just removes two characters, but in larger documents with more
complex data, pushing type parsing decision to the schema (or assuming strings)
removes an enormous amount of syntactic noise.

The lack of syntax typing combined with the use of indentation instead of square brackets
to denote hierarchies makes equivalent StrictYAML documents 10-20% shorter, cleaner
and ultimately more readable.


## Advantages of TOML still has over StrictYAML

There are currently still a few:

* StrictYAML does not currently have an "official spec". The spec is currently just "YAML 1.2 with [features removed](../../features-removed)". This has some advantages (e.g. YAML syntax highlighting in editors works just fine) but also some disadvantages (some documents will render differently).

* StrictYAML does not yet have parsers in languages other than Python. If you'd like to write one for your language (if you don't also do validation it actually wouldn't be very complicated), contact me, I'd love to help you in any way I can - including doing a test suite and documentation.

* Popularity.
