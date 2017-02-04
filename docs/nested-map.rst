Nested mapping validation
=========================

invalid_sequence_2
.. code-block:: yaml

  a: 11
  b: 2
  d: 3

valid_sequence
.. code-block:: yaml

  a:
    x: 9
    y: 8
  b: 2
  c: 3

invalid_sequence_1
.. code-block:: yaml

  a:
    x: 9
    z: 8
  b: 2
  d: 3

.. code-block:: python

  >>> from strictyaml import Map, Int, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Map({"x": Int(), "y": Int()}), "b": Int(), "c": Int()})

.. code-block:: python

  >>> load(valid_sequence, schema) == {"a": {"x": 9, "y": 8}, "b": 2, "c": 3}
  True

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  while parsing a mapping
  unexpected key not in schema 'z'
    in "<unicode string>", line 3, column 1:
        z: '8'
      ^

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  when expecting a mapping
  found non-mapping
    in "<unicode string>", line 1, column 1:
      a: '11'
       ^

