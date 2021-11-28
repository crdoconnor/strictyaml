---
title: Why not use Python's schema library (or similar) for validation?
---

Python's 'schema' (as well as similar libraries) can also be used to validate
the structure of objects. Validating YAML is even [cited as a reason on their
README](https://github.com/keleshev/schema).

Using a schema for validation requires running the YAML through a parser
first which and then taking the output (usually a data structure like a dict)
and passing it through the schema.

Unfortunately there are a number of problems with this approach:


## You still have [the Norway Problem](../../why/implicit-typing-removed)

If the standard YAML parser parses 'NO' as false or [empty string as
None](https://github.com/Grokzen/pykwalify/issues/77) then it doesn't
really matter if the schema says an empty string or the text 'NO' is
okay, it will be seeing a 'None' or a 'False' which will cause a failure.


## You can't get line numbers and snippets for the validation errors

Assuming you've successfully circumvented the Norway problem, parsing
and feeding the output to schema is still problematic. If you pass a
parsed dict to schema, schema can't tell which line number the failure
happened on and can't give you a code snippet highlighting where it
happened.


## Roundtripping becomes very very difficult if not impossible

Due to the loss of metadata about parsed YAML being lost when it
is fed into a generic schema validator, it also becomes impossible to
to *change* the data and serialize it without losing critical
details (i.e. mapping ordering, comments or validation structures).
