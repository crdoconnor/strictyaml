Comma separated strings
=======================

invalid_sequence
.. code-block:: yaml

  a: 1, x, 3

valid_sequence
.. code-block:: yaml

  a: 1, 2, 3

.. code-block:: python

  >>> from strictyaml import CommaSeparated, Int, Map, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": CommaSeparated(Int())})

.. code-block:: python

  >>> load(valid_sequence, schema) == {"a": [1, 2, 3]}
  True

.. code-block:: python

  >>> load(invalid_sequence, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      a: 1, x, 3
       ^

