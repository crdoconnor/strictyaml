Empty validation
================

valid_sequence_1
.. code-block:: yaml

  a: A

valid_sequence_2
.. code-block:: yaml

  a:

invalid_sequence_1
.. code-block:: yaml

  a: C

valid_sequence_4
.. code-block:: yaml

  a:

valid_sequence_3
.. code-block:: yaml

  a:

.. code-block:: python

  >>> from strictyaml import Map, Enum, EmptyNone, EmptyDict, EmptyList, YAMLValidationError, load

.. code-block:: python

  >>> load(valid_sequence_1, Map({"a": Enum(["A", "B",]) | EmptyNone()})) == {"a": "A"}
  True

.. code-block:: python

  >>> load(valid_sequence_2, Map({"a": Enum(["A", "B",]) | EmptyNone()})) == {"a": None}
  True

.. code-block:: python

  >>> load(valid_sequence_3, Map({"a": Enum(["A", "B",]) | EmptyDict()})) == {"a": {}}
  True

.. code-block:: python

  >>> load(valid_sequence_3, Map({"a": Enum(["A", "B",]) | EmptyList()})) == {"a": []}
  True

.. code-block:: python

  >>> load(invalid_sequence_1, Map({"a": Enum(["A", "B",]) | EmptyNone()}))
  EXCEPTION RAISED:
  when expecting an empty value
  found non-empty value
    in "<unicode string>", line 1, column 1:
      a: C
       ^

