Roundtripped YAML
=================

Loaded YAML can be dumped out again and commments
should be preserved.

Loaded YAML can even be modified and dumped out again too.


modified_commented_yaml
.. code-block:: yaml

  # Some comment
  
  a: x # value comment
  
  # Another comment
  b: x

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

  >>> load(commented_yaml, schema).as_yaml() == commented_yaml
  True

.. code-block:: python

  >>> to_modify = load(commented_yaml, schema)
  >>> 
  >>> to_modify['b'] = 'x'

.. code-block:: python

  >>> to_modify.as_yaml() == modified_commented_yaml
  True

