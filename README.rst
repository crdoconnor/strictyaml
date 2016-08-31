StrictYAML
==========

StrictYAML is a `type-safe <https://en.wikipedia.org/wiki/Type_safety>`_ YAML parser.
built atop `ruamel.yaml <http://pypi.python.org/pypi/ruamel.yaml>`_ that parses a restricted
subset of the YAML specificaton.

Priorities:

* Readability of YAML.
* Ease of use of API.
* Secure by default.
* Strict validation of markup and straightforward type casting.
* Clear, human readable exceptions with line numbers.
* Acting as a drop in replacement for pyyaml, ruamel.yaml or poyo.
* Letting you worry about more interesting things than parsing config files.

Simple example:

.. code-block:: yaml

  name: Ford Prefect
  age: 42
  posessions:
    - Towel

Default parse result:

.. code-block:: python

   >>> strictyaml.load(yaml) \
     == {"name": "Ford Prefect", "age": "42", "possessions": ["Towel", ]}   # Without validator all data is a string, dict or list

Example using optional validator - using mapping, sequence, string and integer:

.. code-block:: python

   >>> from strictyaml import load, Map, Str, Int, Seq
   >>> load(yaml, Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})) \
     == {"name": "Ford Prefect", "age": 42, "possessions": ["Towel", ]}     # 42 is now an int


Which features are cut out of the YAML spec?
--------------------------------------------

+--------------------------+-----------------------+---------------------------------------+------------------------------------+
| Stupid feature           | Example YAML          | Example pyyaml/ruamel/poyo            | Example StrictYAML                 |
+==========================+=======================+=======================================+====================================+
| `Implicit typing`_       | .. code-block:: yaml  | .. code-block:: python                | .. code-block:: python             |
|                          |                       |                                       |                                    |
|                          |      x: yes           |      load(yaml) == \                  |      load(yaml) == \               |
|                          |      y: null          |        {"x": True, "y": None}         |        {"x": "yes", "y": "null}    |
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
|                          |      b: {c: 3, d: 4}  |      {'x': {'a': 1}, 'y': {'a': 1}}   |                                    |
+--------------------------+-----------------------+---------------------------------------+------------------------------------+


FAQ
---

From learning programmers:

* `What is YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-yaml>`_
* `Why should I care about YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-should-i-care-about-yaml>`_
* `When should I use a validator and when should I not? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#when-should-i-use-a-validator-and-when-should-i-not>`_

If you're looking at this and thinking "why not do/use X instead?" that's a healthy response, and you deserve answers. These are probably the questions you're asking:

* `Why should I use strictyaml instead of ordinary YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-should-i-use-strictyaml-instead-of-ordinary-YAML>`_
* `What bullshit in ordinary YAML does strictyaml remove? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-bullshit-in-ordinary-yaml-does-strictyaml-remove>`_
* `What do you mean implicit typing is a terrible idea? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-do-you-mean-implicit-typing-is-a-terrible-idea>`_
* `Why not use JSON for configuration or DSLs? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-json-for-configuration-or-dsls>`_
* `Why not use INI files for configuration or DSLs? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-ini-files-for-configuration-or-dsls>`_
* `Why shouldn't I just use python for configuration? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-shouldnt-i-just-use-python-for-configuration>`_
* `Why not use XML for configuration or DSLs? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-xml-for-configuration-or-dsls>`_
* `Why not use TOML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-toml>`_
* `Why not use HJSON? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-hjson>`_
* `Why not use JSON5? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-json5>`_
* `Why not use pykwalify to validate YAML instead? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-pykwalify-to-validate-yaml-instead>`_
* `What if I still disagree with everything you wrote here? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-if-i-still-disagree-with-everything-you-wrote-here>`_


Map Patterns
------------

If you're not sure what the key is going to be but you know what type the values will be, use this.

.. code-block:: yaml

  emails:
    arthur: arthur@earth.gov
    zaphod: zaphod@beeblebrox.com
    ford: ford@ursa-minor.com

.. code-block:: python

   >>> from strictyaml import load, Map, MapPattern, Str
   >>> load(yaml, Map({"emails": MapPattern({Str(), Str()})}) \
     == {"emails": {"arthur": "arthur@earth.gov", "zaphod": "zaphod@beeblebrox.com", "ford": "ford@ursa-minor.com"}}


All Scalar Types
----------------

StrictYAML will parse a string into the correct data type if you specify it:

.. code-block:: python

  >>> import from strictyaml import load, Map
  >>> load("string: string", Map({"string": strictyaml.Str()})) == {"string": "string"}
  >>> load("float: 42.3333", Map({"float": strictyaml.Float()})) == {"string": 42.3333}
  >>> load("price: 35.42811", Map({"price": strictyaml.Decimal()})) == {"price": decimal.Decimal('35.32811')}

  >>> load("booltrue: yes", Map({"booltrue": strictyaml.Bool()})) == {"booltrue": True}
  >>> load("boolfalse: no", Map({"boolfalse": strictyaml.Bool()})) == {"booltrue": True}
  >>> load("booltrue: true", Map({"booltrue": strictyaml.Bool()})) == {"booltrue": True}
  >>> load("boolfalse: False", Map({"boolfalse": strictyaml.Bool()})) == {"booltrue": False}

  >>> load("enum: monday", Map({"enum": strictyaml.Enum(["monday", "tuesday", "wednesday"])})) == {"enum": "monday"}



Custom scalar types
-------------------

COMING SOON


Using YAML Valdation
--------------------

See: What is kwalify and when should I use it?

COMING SOON


Saving YAML
-----------

COMING SOON

Roundtripping YAML
------------------

COMING SOON

.. _Implicit typing: https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-wrong-with-implicit-typing
.. _Binary data: https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-wrong-with-binary-data
.. _Explicit tags: https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-wrong-with-explicit-tags
.. _Flow style: https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-wrong-with-flow-style
.. _Node anchors and refs: https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-wrong-with-node-anchors-and-references