Disallow invalid YAML
=====================

flow_style
.. code-block:: yaml

  x: { a: 1, b: 2, c: 3 }

node_anchors_and_references
.. code-block:: yaml

  x: 
    a: &node1 3.5
    b: 1
    c: *node1

flow_style_sequence
.. code-block:: yaml

  [a, b]: [x, y]

tag_tokens
.. code-block:: yaml

  x:
    a: !!str yes
    b: !!str 3.5
    c: !!str yes

.. code-block:: python

  >>> from strictyaml import Map, Int, Any, load
  >>> from strictyaml import TagTokenDisallowed, FlowMappingDisallowed, AnchorTokenDisallowed
  >>> 
  >>> schema = Map({"x": Map({"a": Any(), "b": Any(), "c": Any()})})

.. code-block:: python

  >>> load(tag_tokens, schema)
  EXCEPTION RAISED:
  While scanning
    in "<unicode string>", line 2, column 11:
        a: !!str yes
                ^
  Found disallowed tag tokens (do not specify types in markup)
    in "<unicode string>", line 2, column 6:
        a: !!str yes
           ^

.. code-block:: python

  >>> load(flow_style_sequence)
  EXCEPTION RAISED:
  While scanning
    in "<unicode string>", line 1, column 1:
      [a, b]: [x, y]
      ^
  Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
    in "<unicode string>", line 1, column 2:
      [a, b]: [x, y]
       ^

.. code-block:: python

  >>> load(flow_style, schema)
  EXCEPTION RAISED:
  While scanning
    in "<unicode string>", line 1, column 4:
      x: { a: 1, b: 2, c: 3 }
         ^
  Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
    in "<unicode string>", line 1, column 5:
      x: { a: 1, b: 2, c: 3 }
          ^

.. code-block:: python

  >>> load(flow_style, schema)
  EXCEPTION RAISED:
  While scanning
    in "<unicode string>", line 1, column 4:
      x: { a: 1, b: 2, c: 3 }
         ^
  Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
    in "<unicode string>", line 1, column 5:
      x: { a: 1, b: 2, c: 3 }
          ^

.. code-block:: python

  >>> load(node_anchors_and_references, schema)
  EXCEPTION RAISED:
  While scanning
    in "<unicode string>", line 2, column 6:
        a: &node1 3.5
           ^
  Found confusing disallowed anchor token (surround with ' and ' to make text appear literally)
    in "<unicode string>", line 2, column 12:
        a: &node1 3.5
                 ^

