String scalars
==============

valid_sequence
.. code-block:: yaml

  a: 1
  b: yes
  c: string
  d: |
    multiline string

.. code-block:: python

  >>> from strictyaml import Str, Map, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Str(), "b": Str(), "c": Str(), "d": Str()})

.. code-block:: python

  >>> load(valid_sequence, schema) == {"a": "1", "b": "yes", "c": "string", "d": "multiline string\n"}
  True

.. code-block:: python

  >>> str(load(valid_sequence, schema)["a"]) == "1"
  True

.. code-block:: python

  >>> int(load(valid_sequence, schema)["a"]) == 1
  True

.. code-block:: python

  >>> bool(load(valid_sequence, schema)["a"])
  EXCEPTION RAISED:
  Cannot cast

