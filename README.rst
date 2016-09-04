StrictYAML
==========

StrictYAML is a `type-safe <https://en.wikipedia.org/wiki/Type_safety>`_ YAML parser
built atop `ruamel.yaml <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-is-strictyaml-built-on-ruamelyaml>`_ that parses a
`restricted subset <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-features-does-strictyaml-remove>`_
of the YAML specificaton.

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
     == {"name": "Ford Prefect", "age": "42", "possessions": ["Towel", ]}   # All data is str, list or dict

Example using optional validator - using mapping, sequence, string and integer:

.. code-block:: python

   >>> from strictyaml import load, Map, Str, Int, Seq
   >>> load(yaml, Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})) \
     == {"name": "Ford Prefect", "age": 42, "possessions": ["Towel", ]}     # 42 is now an int




FAQ
---

From learning programmers:

* `What is YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-yaml>`_
* `Why should I care about YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-should-i-care-about-yaml>`_
* `When should I use a validator and when should I not? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#when-should-i-use-a-validator-and-when-should-i-not>`_

If you're looking at this and thinking "why not do/use X instead?" that's a healthy response, and you deserve answers. These are probably the questions you're asking:


* `Why should I use strictyaml instead of ordinary YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-should-i-use-strictyaml-instead-of-ordinary-YAML>`_
* `What features does StrictYAML remove? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-features-does-strictyaml-remove>`_
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
   >>> load(yaml, Map({"emails": MapPattern({Str(): Str()})}) \
     == {"emails": {"arthur": "arthur@earth.gov", "zaphod": "zaphod@beeblebrox.com", "ford": "ford@ursa-minor.com"}}


Strings, Floats and Decimal
---------------------------

StrictYAML will parse a string into the correct data type if you specify it:

.. code-block:: python

  >>> import from strictyaml import load, Map
  >>> assert load("string: string", Map({"string": strictyaml.Str()})) == {"string": "string"}
  >>> assert load("float: 42.3333", Map({"float": strictyaml.Float()})) == {"string": 42.3333}
  >>> assert load("price: 35.42811", Map({"price": strictyaml.Decimal()})) == {"price": decimal.Decimal('35.32811')}

Booleans
--------

.. code-block:: python

  >>> assert load("booltrue: yes", Map({"booltrue": strictyaml.Bool()})) == {"booltrue": True}
  >>> assert load("boolfalse: no", Map({"boolfalse": strictyaml.Bool()})) == {"booltrue": True}
  >>> assert load("booltrue: true", Map({"booltrue": strictyaml.Bool()})) == {"booltrue": True}
  >>> assert load("boolfalse: False", Map({"boolfalse": strictyaml.Bool()})) == {"booltrue": False}


Enums
-----

.. code-block:: python

  >>> assert load("day: monday", Map({"day": strictyaml.Enum(["monday", "tuesday", "wednesday"])})) == {"day": "monday"}


Dates, times and timestamps
---------------------------

COMING SOON

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
