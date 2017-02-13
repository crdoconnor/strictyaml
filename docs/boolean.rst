Boolean validation
==================

valid_sequence
.. code-block:: yaml

  a: yes
  b: true
  c: on
  d: 1
  e: 0
  f: off
  g: false
  h: no

.. code-block:: python

  >>> from strictyaml import Bool, Str, MapPattern, YAMLValidationError, load
  >>> 
  >>> schema = MapPattern(Str(), Bool())

.. code-block:: python

  >>> load(valid_sequence, schema)["a"] == True
  True

.. code-block:: python

  >>> load(valid_sequence, schema)["a"].value is True
  True

.. code-block:: python

  >>> load(valid_sequence, schema)["g"].text == "false"
  True

.. code-block:: python

  >>> str(load(valid_sequence, schema)["g"])
  EXCEPTION RAISED:
  Cannot cast

