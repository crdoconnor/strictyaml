Sequence validation
===================

invalid_sequence_3
.. code-block:: yaml

  - 1.1
  - 1.2

invalid_sequence_2
.. code-block:: yaml

  - 2
  - 3
  - a:
    - 1
    - 2

valid_sequence
.. code-block:: yaml

  - 1
  - 2
  - 3

invalid_sequence_1
.. code-block:: yaml

  a: 1
  b: 2
  c: 3

invalid_sequence_4
.. code-block:: yaml

  - 1
  - 2
  - 3.4

.. code-block:: python

  >>> from strictyaml import Seq, Str, Int, YAMLValidationError, load

.. code-block:: python

  >>> load(valid_sequence, Seq(Str())) == ["1", "2", "3", ]
  True

.. code-block:: python

  >>> load(invalid_sequence_1, Seq(Str()))
  EXCEPTION RAISED:
  when expecting a sequence
    in "<unicode string>", line 1, column 1:
      a: '1'
       ^
  found non-sequence
    in "<unicode string>", line 3, column 1:
      c: '3'
      ^

.. code-block:: python

  >>> load(invalid_sequence_2, Seq(Str()))
  EXCEPTION RAISED:
  when expecting a str
    in "<unicode string>", line 3, column 1:
      - a:
      ^
  found mapping/sequence
    in "<unicode string>", line 5, column 1:
        - '2'
      ^

.. code-block:: python

  >>> load(invalid_sequence_3, Seq(Int()))
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 1, column 1:
      - '1.1'
       ^

.. code-block:: python

  >>> load(invalid_sequence_4, Seq(Int()))
  EXCEPTION RAISED:
  when expecting an integer
  found non-integer
    in "<unicode string>", line 3, column 1:
      - '3.4'
      ^

