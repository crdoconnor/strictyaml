StrictYAML
==========

StrictYAML is a `type-safe <https://en.wikipedia.org/wiki/Type_safety>`_ YAML parser
that parses a
`restricted subset <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-features-does-strictyaml-remove>`_
of the YAML specificaton.

Priorities:

* Readability of YAML.
* Ease of use of API.
* Secure by default.
* Strict validation of markup and straightforward type casting.
* Clear, human readable exceptions with line numbers.
* Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
* Roundtripping - reading in (commented) YAML and writing it out with comments.
* Letting you worry about more interesting things than parsing or writing config files.

Simple example:

.. code-block:: yaml

  # All about the character
  name: Ford Prefect
  age: 42
  possessions:
    - Towel

Default parse result:

.. code-block:: python

   >>> strictyaml.load(yaml)
   YAML({'possessions': ['Towel'], 'age': '42', 'name': 'Ford Prefect'})

   >>> strictyaml.load(yaml).data
   {"name": "Ford Prefect", "age": "42", "possessions": ["Towel", ]}   # All data is str, list or dict

Using a schema:

.. code-block:: python

   >>> from strictyaml import load, Map, Str, Int, Seq
   >>> person = load(yaml, Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})) \
   >>> person.data == {"name": "Ford Prefect", "age": 42, "possessions": ["Towel", ]}     # 42 is now an int


Once parsed you can change values and roundtrip the whole YAML, with comments preserved:

.. code-block:: python

   >>> person['age'] = load('43')
   >>> print(person.as_yaml())
   # All about the character
   name: Ford Prefect
   age: 43
   possessions:
     - Towel

As well as look up line numbers:

.. code-block:: python

   >>> person['possessions'][0].start_line
   5


See more `example driven documentation <http://strictyaml.readthedocs.org/>`_.


Install It
----------

.. code-block:: sh

  $ pip install strictyaml



FAQ
---

From learning programmers:

* `What is YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-is-yaml>`_
* `Why should I care about YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-should-i-care-about-yaml>`_
* `When should I use a validator and when should I not? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#when-should-i-use-a-validator-and-when-should-i-not>`_

If you're looking at this and thinking "why not do/use X instead?" that's a healthy response, and you deserve answers. These are probably the questions you're asking:


* `Why should I use strictyaml instead of ordinary YAML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-should-i-use-strictyaml-instead-of-ordinary-yaml>`_
* `What features does StrictYAML remove? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-features-does-strictyaml-remove>`_
* `Why not use JSON for configuration or DSLs? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-json-for-configuration-or-dsls>`_
* `Why not use INI files for configuration or DSLs? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-ini-files-for-configuration-or-dsls>`_
* `Why shouldn't I just use python for configuration? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-shouldnt-i-just-use-python-for-configuration>`_
* `Why not use XML for configuration or DSLs? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-xml-for-configuration-or-dsls>`_
* `Why not use TOML? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-toml>`_
* `Why not use HJSON? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-hjson>`_
* `Why not use JSON5? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-json5>`_
* `Why not use HOCON? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-hocon>`_
* `Why not use pykwalify to validate YAML instead? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#why-not-use-pykwalify-to-validate-yaml-instead>`_
* `What if I still disagree with everything you wrote here? <https://github.com/crdoconnor/strictyaml/blob/master/FAQ.rst#what-if-i-still-disagree-with-everything-you-wrote-here>`_


Breaking changes
----------------

0.5: Data is now parsed by default as a YAML object instead of directly to dict/list. To get dict/list and ordinary values as before, get yaml_object.data.

0.7: Roundtripping now requires that you only assign YAML objects to index: e.g. yaml_object['x'] = another_yaml_obj


Contributors
------------

* @gvx
* @AlexandreDecan
* @lots0logs
* @tobbez
