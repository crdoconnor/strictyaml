Enum validation
===============

invalid_sequence_2
.. code-block:: yaml

  a: yes

valid_sequence_3
.. code-block:: yaml

  a: C

valid_sequence_2
.. code-block:: yaml

  a: B

invalid_sequence_1
.. code-block:: yaml

  a: D

valid_sequence_1
.. code-block:: yaml

  a: A

invalid_sequence_3
.. code-block:: yaml

  a: 1

.. code-block:: python

  >>> from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Enum(["A", "B", "C"])})

.. code-block:: python

  >>> load(valid_sequence_1, schema) == {"a": "A"}
  True

.. code-block:: python

  >>> load(valid_sequence_2, schema) == {"a": "B"}
  True

.. code-block:: python

  >>> load(valid_sequence_3, schema) == {"a": "C"}
  True

.. code-block:: python

  >>> load(invalid_sequence_1, schema)
  EXCEPTION RAISED:
  

.. code-block:: python

  >>> load(invalid_sequence_2, schema)
  EXCEPTION RAISED:
  

.. code-block:: python

  >>> load(invalid_sequence_3, schema)
  EXCEPTION RAISED:
  

