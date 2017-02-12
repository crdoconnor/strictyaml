Scalar validation
=================

valid_sequence
.. code-block:: yaml

  a: 1
  b: 5

.. code-block:: python

  >>> from strictyaml import Map, Int, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Int(), "b": Int()})

.. code-block:: python

  >>> load(valid_sequence, schema) == {"a": 1, "b": 5}
  True

.. code-block:: python

  >>> str(load(valid_sequence, schema)["a"]) == "1"
  True

.. code-block:: python

  >>> float(load(valid_sequence, schema)["a"]) == 1.0
  True

.. code-block:: python

  >>> bool(load(valid_sequence, schema)['a'])
  EXCEPTION RAISED:
  Cannot cast

