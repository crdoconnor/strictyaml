Scalar validation
=================

invalid_sequence_4
.. code-block:: yaml

  a: 1
  b: yes
  c: string
  d: 3.141
  e: not a decimal

invalid_sequence_2
.. code-block:: yaml

  a: string
  b: 2
  c: string
  d: 3.141
  e: 3.1415926535

invalid_sequence_3
.. code-block:: yaml

  a: 1
  b: yes
  c: string
  d: not a float
  e: 3.1415926535

valid_sequence
.. code-block:: yaml

  a: 1
  b: yes
  c: string
  d: 3.141
  e: 3.1415926535

invalid_sequence_1
.. code-block:: yaml

  a: 1
  b: 2
  c: string
  d: 3.141
  e: 3.1415926535

.. code-block:: python

  >>> from strictyaml import Map, Int, Bool, Float, Str, Decimal, YAMLValidationError, load
  >>> import decimal
  >>> 
  >>> schema = Map({"a": Int(), "b": Bool(), "c": Str(), "d": Float(), "e": Decimal()})

.. code-block:: python

  >>> load(valid_sequence, schema) == {"a": 1, "b": True, "c": "string", "d": 3.141, "e": decimal.Decimal("3.1415926535")}
  True

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
  found non-boolean
    in "<unicode string>", line 2, column 1:
      b: '2'
      ^

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      a: string
       ^

.. code-block:: python

  >>> load(invalid_sequence_3, schema)
  EXCEPTION RAISED:
  when expecting a float
  found non-float
    in "<unicode string>", line 4, column 1:
      d: not a float
      ^

.. code-block:: python

  >>> load(invalid_sequence_4, schema)
  EXCEPTION RAISED:
  when expecting a decimal
  found non-decimal
    in "<unicode string>", line 5, column 1:
      e: not a decimal
      ^

