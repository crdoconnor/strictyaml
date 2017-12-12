What features does StrictYAML remove?
-------------------------------------

+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| Stupid feature           | Example YAML          | Example pyyaml/ruamel/poyo            | Example StrictYAML                 |
+==========================+=======================+=======================================+====================================+
| `Implicit typing`_       | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      x: yes           |      load(yaml) == \                  |      load(yaml) == \               |
|                          |      y: null          |        {"x": True, "y": None}         |        {"x": "yes", "y": "null"}   |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| `Binary data`_           | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      evil: !!binary   |      load(yaml) == \                  |      raises TagTokenDisallowed     |
|                          |       evildata        |      {'evil': b'z\xf8\xa5u\xabZ'}     |                                    |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| `Explicit tags`_         | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      x: !!int 5       |      load(yaml) == {"x": 5}           |     raises TagTokenDisallowed      |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| `Node anchors and refs`_ | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      x: &id001        |      load(yaml) == \                  |     raises NodeAnchorDisallowed    |
|                          |        a: 1           |       {'x': {'a': 1}, 'y': {'a': 1}}  |                                    |
|                          |      y: *id001        |                                       |                                    |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| `Flow style`_            | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      x: 1             |      load(yaml) == \                  |     raises FlowStyleDisallowed     |
|                          |      b: {c: 3, d: 4}  |      {'x': 1, 'b': {'c': 3, 'd': 4}}  |                                    |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| `Duplicate keys`_        | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      x: 1             |      load(yaml) == \                  |     raises DuplicateKeysDisallowed |
|                          |      x: 2             |      {'x': 2}                         |                                    |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+
