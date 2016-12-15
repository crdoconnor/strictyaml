Or validation
=============

valid_sequence_3
.. code-block:: yaml

  a: no

invalid_sequence_2
.. code-block:: yaml

  a: B

invalid_sequence_1
.. code-block:: yaml

  a: A

valid_sequence_1
.. code-block:: yaml

  a: yes

valid_sequence_2
.. code-block:: yaml

  a: 5

invalid_sequence_3
.. code-block:: yaml

  a: 3.14

.. code-block:: python

  >>> from strictyaml import Map, Bool, Int, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Bool() | Int()})

.. code-block:: python

  >>> load(valid_sequence_1, schema) == {"a" : True}True

.. code-block:: python

  >>> load(valid_sequence_2, schema) == {"a" : 5}True

.. code-block:: python

  >>> load(valid_sequence_3, schema) == {"a" : False}True

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      a: A
       ^

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      a: B
       ^

.. code-block:: python

  >>> load(invalid_sequence_3, schema)
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      a: '3.14'
       ^

