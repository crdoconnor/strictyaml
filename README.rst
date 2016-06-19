StrictYAML
==========

StrictYAML is a `type-safe <https://en.wikipedia.org/wiki/Type_safety>`_ YAML parser,
eliminating surprise bugs caused by implicit typing.

For example:

.. code-block:: yaml

  - Don Corleone: Do you have faith in my judgment?
  - Clemenza: Yes
  - Don Corleone: Do I have your loyalty?

Parse output of `pyyaml <http://pyyaml.org and ruamel.yaml>`_ and `ruamel.yaml <https://bitbucket.org/ruamel/yaml>`_:

.. code-block:: python

    >>> from ruamel.yaml import load
    >>> load(the_godfather)
    [{'Don Corleone': 'Do you have faith in my judgement?'},
     {'Clemenza': True},
     {'Don Corleone': 'Do I have your loyalty?'},]

Wait, Clemenza said what??

Parse output of StrictYAML:

.. code-block:: python

    >>> from strictyaml import load, List, MapPattern, Str
    >>> load(the_godfather, List(MapPattern({Str(), Str()})))
    [{'Don Corleone': 'Do you have faith in my judgement?'},
     {'Clemenza': 'Yes'},
     {'Don Corleone': 'Do I have your loyalty?'},]

Why use StrictYAML?
-------------------

YAML is an excellent metalanguage to describe most kinds of configuration
as well as for creating simple DSLs.

It is terse and devoid of noisy syntax (unlike JSON), able to clearly
represent hierarchical data (unlike INI) and most important of all, 
it's not the product of a crazed committee of monkeys hammering away on
typewriters (XML).

YAML has weaknesses, however, which StrictYAML addresses:

* Implicitly typed (StrictYAML fixes this with explicit typing).
* Allows arbitrary binary data leading to, among other things, Ruby on Rails' spectacular `security fail <http://www.h-online.com/open/news/item/Rails-developers-close-another-extremely-critical-flaw-1793511.html>`_ (disallowed in StrictYAML because *why on earth did anybody think this was a good idea?*).
* Tag tokens, allowing you to specify types in the YAML (disallowed in StrictYAML).
* Confusing "flow" style (disallowed by default in StrictYAML).
* Often confusing node anchors and references (disallowed by default in StrictYAML).


Using StrictYAML
----------------

Map pattern in YAML can be translated to dicts:

.. code-block:: python

    >>> from strictyaml import load, MapPattern, Str, Int
    >>> load("a: 1\nb: 2", MapPattern(Str(), Int()))
    {'a': 1, 'b': 2}

Restricted, specified maps can also be translated to dicts:

.. code-block:: python

    >>> from strictyaml import load, Map, Bool
    >>> load("a: yes\nb: no", Map({"a": Bool(), "b": Bool()}))
    {'a': True, 'b': False}

Validators can be nested and lists can be restricted to a single type:

.. code-block:: python

    >>> from strictyaml import load, Map, Seq, Float
    >>> list_float_typed_yaml = """
    ... a:
    ...   - 1.5
    ...   - 2.5
    ... b:
    ...   - 2
    ...   - -3.14e5
    ... """
    >>> load(list_float_typed_yaml, Map({"a": Seq(Float()), "b": Seq(Float())}))
    {'b': [2.0, -314000.0], 'a': [1.5, 2.5]}

Types can be mixed and matched:

.. code-block:: python

    >>> from strictyaml import load, Map, Bool, Str, Decimal
    >>> product_yaml = """
    ... Name: Tea
    ... Price: 3.55
    ... Available: Yes
    ... """
    >>> load(product_yaml, Map({"Name": Str(), "Price": Decimal(), "Available": Bool()}))
    {'Available': True, 'Name': 'Tea', 'Price': Decimal('3.55')}

You can also use enums:

.. code-block:: python

    >>> from strictyaml import load, Map, Str, Enum
    >>> product_yaml = """
    ... Name: Tea
    ... Type: Green
    ... """
    >>> load(product_yaml, Map({"Name": Str(), "Type": Enum(["Green", "Mint"])}))
    {'Name': 'Tea', 'Type': 'Green'}