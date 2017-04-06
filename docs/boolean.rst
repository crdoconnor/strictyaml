Boolean validation
==================

Boolean values can be interpreted using a Bool
validator. It case-insensitively interprets
"yes", "true", "1", "on" as True and their
opposites as False.

Any values that are not among the above
will cause a validation error.


valid_sequence
.. code-block:: yaml

  a: yes
  b: true
  c: on
  d: 1
  e: 0
  f: Off
  g: FALSE
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

