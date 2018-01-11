---
title: Why does StrictYAML only parse from strings and not files?
---

While other parsers will take strings, file handles and file names,
StrictYAML will only parse YAML strings.

This is done deliberately to reduce the module's remit, with the
intention of reducing both the potential bug surface and the number
of exceptions that StrictYAML has to deal with - things like
nonexistent files, file system errors, bad reads, unknown file
extensions, etc. become the problem of some other module - ideally
one more focused on handling those kinds of issues.

If you want a quick and easy one liner way to get text from a file,
I recommend that you pip install path.py and and use .text() on the
Path object:

´´´python
>>> from path import Path
>>> from strictyaml import load
>>> parsed_data = load(Path("myfile.yaml").text()).data
>>> print(parsed_data)
[ parsed yaml ]
´´´

