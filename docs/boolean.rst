Boolean validation
==================

Boolean values can be interpreted using a Bool
validator. It case-insensitively interprets
"yes", "true", "1", "on" as True and their
opposites as False.

Any values that are not among the above
will cause a validation error.


invalid_sequence
.. code-block:: yaml

  a: yâs

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

.. code-block:: python

  >>> load(valid_sequence, schema)["g"].text == "FALSE"
  True

.. code-block:: python

  >>> str(load(valid_sequence, schema)["g"])
  EXCEPTION RAISED:
  Cannot cast

.. code-block:: python

  >>> load(invalid_sequence, schema)
  EXCEPTION RAISED:
  when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
  found non-boolean
    in "<unicode string>", line 1, column 1:
      a: "y\xE2s"
       ^ (line: 1)

