StrictYAML
==========

StrictYAML is a
`type-safe <https://en.wikipedia.org/wiki/Type_safety>`__ YAML parser
that parses a `restricted
subset <http://hitchdev.com/strictyaml/features-removed>`__ of the
`YAML <http://hitchdev.com/strictyaml/what-is-yaml>`__ specificaton.

Priorities:

-  Beautiful API
-  Refusing to parse `the ugly, hard to read and insecure features of
   YAML <http://hitchdev.com/strictyaml/features-removed>`__.
-  Strict validation of markup and straightforward type casting.
-  Clear, readable exceptions with **code snippets** and **line
   numbers**.
-  Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
-  Ability to read in YAML, make changes and write it out again with
   comments preserved.
-  *Not* speed, currently.

Simple example:

.. code:: yaml

    # All about the character
    name: Ford Prefect
    age: 42
    possessions:
    - Towel

.. code:: python

    from strictyaml import load, Map, Str, Int, Seq, YAMLError

Default parse result:

.. code:: python

    >>> load(yaml_snippet)
    YAML(OrderedDict([('name', 'Ford Prefect'), ('age', '42'), ('possessions', ['Towel'])]))

All data is string, list or OrderedDict:

.. code:: python

    >>> load(yaml_snippet).data
    OrderedDict([('name', 'Ford Prefect'), ('age', '42'), ('possessions', ['Towel'])])

Quickstart with schema:

.. code:: python

    from strictyaml import load, Map, Str, Int, Seq, YAMLError

    schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})

42 is now parsed as an integer:

.. code:: python

    >>> person = load(yaml_snippet, schema)
    >>> person.data
    OrderedDict([('name', 'Ford Prefect'), ('age', 42), ('possessions', ['Towel'])])

A YAMLError will be raised if there are syntactic problems, violations
of your schema or use of disallowed YAML features:

.. code:: yaml

    # All about the character
    name: Ford Prefect
    age: 42

For example, a schema violation:

.. code:: python

    try:
        person = load(yaml_snippet, schema)
    except YAMLError as error:
        print(error)

.. code:: yaml

    while parsing a mapping
      in "<unicode string>", line 1, column 1:
        # All about the character
         ^ (line: 1)
    required key(s) 'possessions' not found
      in "<unicode string>", line 3, column 1:
        age: '42'
        ^ (line: 3)

If parsed correctly:

.. code:: python

    from strictyaml import load, Map, Str, Int, Seq, YAMLError

    schema = Map({"name": Str(), "age": Int(), "possessions": Seq(Str())})

You can modify values and write out the YAML with comments preserved:

.. code:: python

    person = load(yaml_snippet, schema)
    person['age'] = 43
    print(person.as_yaml())

.. code:: yaml

    # All about the character
    name: Ford Prefect
    age: 43
    possessions:
    - Towel

As well as look up line numbers:

.. code:: python

    >>> person = load(yaml_snippet, schema)
    >>> person['possessions'][0].start_line
    5

Install
-------

.. code:: sh

    $ pip install strictyaml

Why StrictYAML?
---------------

There are a number of formats and approaches that can achieve more or
less the same purpose as StrictYAML. I've tried to make it the best one.
Below is a series of documented justifications:

-  `Why not JSON for simple configuration
   files? <http://hitchdev.com/strictyaml/why-not/json>`__
-  `Why not use HJSON? <http://hitchdev.com/strictyaml/why-not/hjson>`__
-  `Why not use TOML? <http://hitchdev.com/strictyaml/why-not/toml>`__
-  `Why not use the YAML 2.0 standard? - we don't need a new
   standard! <http://hitchdev.com/strictyaml/why-not/ordinary-yaml>`__
-  `Why not use kwalify with standard YAML to validate my
   YAML? <http://hitchdev.com/strictyaml/why-not/pykwalify>`__
-  `Why not use python's schema library for
   validation? <http://hitchdev.com/strictyaml/why-not/python-schema>`__
-  `Why not HOCON? <http://hitchdev.com/strictyaml/why-not/hocon>`__
-  `Why not JSON5? <http://hitchdev.com/strictyaml/why-not/json5>`__
-  `Why not use XML for configuration or
   DSLs? <http://hitchdev.com/strictyaml/why-not/xml>`__
-  `Why shouldn't I just use python code for
   configuration? <http://hitchdev.com/strictyaml/why-not/turing-complete-code>`__
-  `Why not use INI
   files? <http://hitchdev.com/strictyaml/why-not/ini>`__
-  `Why not use
   SDLang? <http://hitchdev.com/strictyaml/why-not/sdlang>`__
-  `Why not use JSON Schema for
   validation? <http://hitchdev.com/strictyaml/why-not/json-schema>`__

Using StrictYAML
----------------

-  `compound <http://hitchdev.com/strictyaml/using/alpha/compound>`__

-  `Validating optional keys in mappings
   (Map) <http://hitchdev.com/strictyaml/using/alpha/compound/optional-keys>`__

-  `Using a YAML object of a parsed
   mapping <http://hitchdev.com/strictyaml/using/alpha/compound/mapping-yaml-object>`__

-  `Sequences of unique items
   (UniqueSeq) <http://hitchdev.com/strictyaml/using/alpha/compound/sequences-of-unique-items>`__

-  `Mappings with defined keys
   (Map) <http://hitchdev.com/strictyaml/using/alpha/compound/mapping>`__

-  `Mappings with arbitrary key names
   (MapPattern) <http://hitchdev.com/strictyaml/using/alpha/compound/map-pattern>`__

-  `Fixed length sequences
   (FixedSeq) <http://hitchdev.com/strictyaml/using/alpha/compound/fixed-length-sequences>`__

-  `Sequence/list validator
   (Seq) <http://hitchdev.com/strictyaml/using/alpha/compound/sequences>`__

-  `Mapping with defined keys and a custom key validator
   (Map) <http://hitchdev.com/strictyaml/using/alpha/compound/mapping-with-slug-keys>`__

-  `howto <http://hitchdev.com/strictyaml/using/alpha/howto>`__

-  `Revalidate an already validated
   document <http://hitchdev.com/strictyaml/using/alpha/howto/revalidation>`__

-  `Merge YAML
   documents <http://hitchdev.com/strictyaml/using/alpha/howto/merge-yaml-documents>`__

-  `Parsing YAML without a
   schema <http://hitchdev.com/strictyaml/using/alpha/howto/without-a-schema>`__

-  `Labeling
   exceptions <http://hitchdev.com/strictyaml/using/alpha/howto/label-exceptions>`__

-  `Build a YAML document from scratch in
   code <http://hitchdev.com/strictyaml/using/alpha/howto/build-yaml-document>`__

-  `Reading in YAML, editing it and writing it back
   out <http://hitchdev.com/strictyaml/using/alpha/howto/roundtripping>`__

-  `Get line numbers of YAML
   elements <http://hitchdev.com/strictyaml/using/alpha/howto/what-line>`__

-  `Either/or schema validation of two equally valid different kinds of
   YAML <http://hitchdev.com/strictyaml/using/alpha/howto/either-or-validation>`__

-  `scalar <http://hitchdev.com/strictyaml/using/alpha/scalar>`__

-  `Validating strings with regexes
   (Regex) <http://hitchdev.com/strictyaml/using/alpha/scalar/regular-expressions>`__

-  `Integers
   (Int) <http://hitchdev.com/strictyaml/using/alpha/scalar/integer>`__

-  `Empty key
   validation <http://hitchdev.com/strictyaml/using/alpha/scalar/empty>`__

-  `Floating point numbers
   (Float) <http://hitchdev.com/strictyaml/using/alpha/scalar/float>`__

-  `Decimal numbers
   (Decimal) <http://hitchdev.com/strictyaml/using/alpha/scalar/decimal>`__

-  `Enumerated scalars
   (Enum) <http://hitchdev.com/strictyaml/using/alpha/scalar/enum>`__

-  `Parsing strings
   (Str) <http://hitchdev.com/strictyaml/using/alpha/scalar/string>`__

-  `Boolean
   (Bool) <http://hitchdev.com/strictyaml/using/alpha/scalar/boolean>`__

-  `Email and URL
   validators <http://hitchdev.com/strictyaml/using/alpha/scalar/email-and-url>`__

-  `Datetimes
   (Datetime) <http://hitchdev.com/strictyaml/using/alpha/scalar/datetime>`__

-  `Parsing comma separated items
   (CommaSeparated) <http://hitchdev.com/strictyaml/using/alpha/scalar/comma-separated>`__

-  `restrictions <http://hitchdev.com/strictyaml/using/alpha/restrictions>`__

-  `Disallowed
   YAML <http://hitchdev.com/strictyaml/using/alpha/restrictions/disallowed-yaml>`__

-  `Duplicate
   keys <http://hitchdev.com/strictyaml/using/alpha/restrictions/duplicate-keys>`__

Design justifications
---------------------

There are some design decisions in StrictYAML which are controversial
and/or not obvious. Those are documented here:

-  `What is wrong with explicit
   tags? <http://hitchdev.com/strictyaml/why/explicit-tags-removed>`__
-  `What is wrong with explicit syntax typing in a readable
   configuration
   language? <http://hitchdev.com/strictyaml/why/syntax-typing-bad>`__
-  `What is wrong with implicit
   typing? <http://hitchdev.com/strictyaml/why/implicit-typing-removed>`__
-  `What is wrong with flow style
   YAML? <http://hitchdev.com/strictyaml/why/flow-style-removed>`__
-  `Why does StrictYAML only parse from strings and not
   files? <http://hitchdev.com/strictyaml/why/only-parse-strings-not-files>`__
-  `What is wrong with duplicate
   keys? <http://hitchdev.com/strictyaml/why/duplicate-keys-disallowed>`__
-  `Why does StrictYAML not parse direct representations of python
   objects? <http://hitchdev.com/strictyaml/why/binary-data-removed>`__
-  `What is wrong with node anchors and
   references? <http://hitchdev.com/strictyaml/why/node-anchors-and-references-removed>`__
-  `Why does StrictYAML make you define a schema in python - a turing
   complete
   language? <http://hitchdev.com/strictyaml/why/turing-complete-schema>`__

Breaking changes
----------------

0.5: Data is now parsed by default as a YAML object instead of directly
to dict/list. To get dict/list and ordinary values as before, get
yaml\_object.data.

Contributors
------------

-  @gvx
-  @AlexandreDecan
-  @lots0logs
-  @tobbez
