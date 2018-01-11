---
title: Why does StrictYAML make you define a schema in python - a turing complete language?
---

StrictYAML defines schemas in python (i.e. turing complete) code. For example:

.. code-block:: python

  Map({"name": Str(), "email": Str()})
  
Instead of:

.. code-block:: yaml

  type:       map
  mapping:
  "name":
      type:      str
      required:  yes
  "email":
      type:      str
      required:  yes

There are some trade offs here:

Schema definition in a non-turing complete language like YAML makes
the schema programming language independent and gives it more
potential for being read and understood by non-programmers.

However, schema definition in a non-turing complete language also
restricts and makes certain use cases impossible or awkward.

Some use cases I came across included:

* Being able to import pycountry's country list and restrict "country: " to valid country names.

* Being able to implement a schema that validated date/time scalar values against the specific date/time parser I wanted.

* Being able to revalidate sections of the document on a 'second pass' that used new data - e.g. a list in one part of the document is restricted to items which come from another part.
