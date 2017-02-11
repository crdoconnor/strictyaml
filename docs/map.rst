Mapping validation
==================

valid_sequence
.. code-block:: yaml

  a: 1
  b: 2
  c: 3

invalid_sequence_2
.. code-block:: yaml

  - 1
  - 2
  - 3

invalid_sequence_3
.. code-block:: yaml

  a: 1
  b: 2
  c: 3
  d: 4

invalid_sequence_1
.. code-block:: yaml

  a: 1
  b: 2
  d: 3

.. code-block:: python

  >>> from strictyaml import Map, Int, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Int(), "b": Int(), "c": Int()})

.. code-block:: python

  >>> load(valid_sequence, schema) == {"a": 1, "b": 2, "c": 3}
  True

.. code-block:: python

  >>> load(valid_sequence, schema)["a"] == 1
  True

.. code-block:: python

  >>> len(load(valid_sequence, schema)) == 3
  True

.. code-block:: python

  >>> load(valid_sequence, schema).text
  EXCEPTION RAISED:
  is a mapping, has no text value.

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  while parsing a mapping
  unexpected key not in schema 'd'
    in "<unicode string>", line 3, column 1:
      d: '3'
      ^

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  when expecting a mapping
    in "<unicode string>", line 1, column 1:
      - '1'
       ^
  found non-mapping
    in "<unicode string>", line 3, column 1:
      - '3'
      ^

.. code-block:: python

  >>> load(invalid_sequence_3, schema)
  EXCEPTION RAISED:
  while parsing a mapping
  unexpected key not in schema 'd'
    in "<unicode string>", line 4, column 1:
      d: '4'
      ^

