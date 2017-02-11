Optional validation
===================

valid_sequence_1
.. code-block:: yaml

  a: 1
  b: 2

invalid_sequence_3
.. code-block:: yaml

  a: 1
  b: yes
  c: 3

valid_sequence_3
.. code-block:: yaml

  a: 1

valid_sequence_2
.. code-block:: yaml

  a: 1
  c: 3

invalid_sequence_1
.. code-block:: yaml

  b: b

invalid_sequence_2
.. code-block:: yaml

  a: a
  b: 2

.. code-block:: python

  >>> from strictyaml import MapPattern, Int, Str, YAMLValidationError, load
  >>> 
  >>> schema = MapPattern(Str(), Int())

.. code-block:: python

  >>> load(valid_sequence_1, schema) == {"a": 1, "b": 2}
  True

.. code-block:: python

  >>> load(valid_sequence_2, schema) == {"a": 1, "c": 3}
  True

.. code-block:: python

  >>> load(valid_sequence_3, schema) == {"a": 1, }
  True

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      b: b
       ^

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      a: a
       ^

.. code-block:: python

  >>> load(invalid_sequence_3, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 2, column 1:
      b: yes
      ^

