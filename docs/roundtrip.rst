Roundtripped YAML
=================

commented_yaml
.. code-block:: yaml

  # Some comment
  
  a: 1 # value comment
  
  # Another comment
  b: 2

.. code-block:: python

  >>> from strictyaml import Map, Int, YAMLValidationError, load
  >>> 
  >>> schema = Map({"a": Int(), "b": Int()})

.. code-block:: python

  >>> load(commented_yaml, schema).as_yaml() == commented_yaml
  True

