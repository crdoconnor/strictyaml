Sequence pattern validation
===========================

invalid_sequence_2
.. code-block:: yaml

  - 3
  - 3
  - 3

valid_sequence
.. code-block:: yaml

  - A
  - B
  - C

invalid_sequence_1
.. code-block:: yaml

  - A
  - B
  - B

.. code-block:: python

  >>> from strictyaml import UniqueSeq, Str, YAMLValidationError, load
  >>> 
  >>> schema = UniqueSeq(Str())

.. code-block:: python

  >>> load(valid_sequence, schema) == ["A", "B", "C", ]
  True

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  while parsing a sequence
    in "<unicode string>", line 1, column 1:
      - A
       ^
  duplicate found
    in "<unicode string>", line 3, column 1:
      - B
      ^

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  while parsing a sequence
    in "<unicode string>", line 1, column 1:
      - '3'
       ^
  duplicate found
    in "<unicode string>", line 3, column 1:
      - '3'
      ^

