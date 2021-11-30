---
title: Why not use HJSON?
---

!!! note "No longer supported"

    HJSON is no longer supported.


[HJSON](http://hjson.org/) is an attempt at fixing the aforementioned lack of readability of JSON.

It has the following criticisms of YAML:

- JSON is easier to explain (compare the JSON and YAML specs).

- JSON is not bloated (it does not have anchors, substitutions or concatenation).

As with TOML's criticism, these are spot on. However, strictyaml fixes this by *cutting out those parts of the spec*, leaving something that is actually simpler than HJSON.

It has another criticism:

- JSON does not suffer from significant whitespace.

This is not a valid criticism.

Whitespace and indentation is meaningful to people parsing any kind of code and markup (why else would code which *doesn't* have meaningful whitespace use indentation as well?) so it *should* be meaningful to computers parsing.

There is an initial 'usability hump' for first time users of languages which have significant whitespace *that were previously not used to significant whitespace* but this isn't especially hard to overcome - especially if you have a propery configured decent editor which is explicit about the use of whitespace.

Python users often report this being a problem, but after using the language for a while usually come to prefer it since it keeps the code shorter and makes its intent clearer.
