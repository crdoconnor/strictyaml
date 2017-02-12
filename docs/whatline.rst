What line
=========

Line and context can be determined from the returned YAML object.


commented_yaml
.. code-block:: yaml

  # Some comment
  
  a: x # value comment
  
  # Another comment
  b: y

.. code-block:: python

  >>> from strictyaml import Map, Str, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Str(), "b": Str()})

.. code-block:: python

  >>> load(commented_yaml, schema)["a"].end_line == 3
  True

.. code-block:: python

  >>> load(commented_yaml, schema).start_line == 1
  True

.. code-block:: python

  >>> load(commented_yaml, schema).end_line == 6
  True

