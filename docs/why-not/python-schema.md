---
title: Why not use python's schema library for validation?
---

Python's 'schema' (as well as similar libraries) can also be used to validate
the structure of objects. Validating YAML is even cited as a reason on their
README.

Problems:

* Line numbers and code snippets not reported on errors.
* YAML's implicit typing will still ruin validation.
* Roundtripping is much less straightforward.

[ TODO flesh out ]
