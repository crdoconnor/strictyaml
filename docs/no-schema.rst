No schema validation
====================

sequence_1
.. code-block:: yaml

  a:
    x: 9
    y: 8
  b: 2
  c: 3

sequence_3
.. code-block:: yaml

  a: 11
  b: 2
  d: 3

sequence_2
.. code-block:: yaml

  a:
    - 9
    - 8
  b: 2
  d: 3

.. code-block:: python

  >>> from strictyaml import Map, Int, YAMLValidationError, load

.. code-block:: python

  >>> load(sequence_1) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}True

.. code-block:: python

  >>> load(sequence_2) == {"a": ["9", "8",], "b": "2", "d": "3"}True

.. code-block:: python

  >>> load(sequence_3) == {"a": "11", "b": "2", "d": "3"}True

