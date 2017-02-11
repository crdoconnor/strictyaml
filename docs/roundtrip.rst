Roundtripped YAML
=================

Loaded YAML can be dumped out again and commments
should be preserved.

Loaded YAML can even be modified and dumped out again too.


modified_commented_yaml
.. code-block:: yaml

  # Some comment
  
  a: 2 # value comment
  
  # Another comment
  b: 2

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

.. code-block:: python

  >>> to_modify = load(commented_yaml, schema)
  >>> 
  >>> to_modify['a'] = 2

.. code-block:: python

  >>> to_modify.as_yaml() == modified_commented_yaml
  True

