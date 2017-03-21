Non-schema validation
=====================

When using strictyaml you do not have to specify a schema. If
you do this, the validator "Any" is used which will accept any
mapping and any list and any value (which will always be rendered
as a string).

This is recommended when prototyping programs and the schema is
frequently changing. When your prototype code is parsing YAML
that has a fixed structure, lock it down with a schema.


valid_sequence
.. code-block:: yaml

  a:
    x: 9
    y: 8
  b: 2
  c: 3

.. code-block:: python

  >>> from strictyaml import Any, MapPattern, YAMLValidationError, load

.. code-block:: python

  >>> load(valid_sequence, Any()) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}
  True

.. code-block:: python

  >>> load(valid_sequence, MapPattern(Any(), Any())) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}
  True

