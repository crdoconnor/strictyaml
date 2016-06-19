StrictYAML
==========

StrictYAML is a YAML parser that forces you to explicitly type your YAML
with a schema before parsing it, eliminating parse surprise bugs caused
by implicit typing.

For example::

  - Don Corleone: Do you have faith in my judgment?
  - Clemenza: Yes
  - Don Corleone: Do I have your loyalty?

Parse output of pyyaml/ruamel.yaml::

    >>> from ruamel.yaml import load
    >>> load(the_godfather)
    [{'Don Corleone': 'Do you have faith in my judgement?'},
     {'Clemenza': True},
     {'Don Corleone': 'Do I have your loyalty?'},]

Wait, Clemenza said what??

Parse output of StrictYAML::

    >>> from strictyaml import load, List, MapPattern, Str
    >>> load(the_godfather, List(MapPattern({Str(), Str()})))
    [{'Don Corleone': 'Do you have faith in my judgement?'},
     {'Clemenza': 'Yes'},
     {'Don Corleone': 'Do I have your loyalty?'},]

Why use StrictYAML?
-------------------

YAML is an excellent metalanguage to describe most kinds of configuration.
It is terse and devoid of noisy syntax (unlike JSON), able to clearly
represent hierarchical data (unlike INI) and most important of all, 
it's not the product of a crazed committee of monkeys hammering away on
typewriters (XML).

YAML has weaknesses, however, which StrictYAML addresses:

* Implicitly typed (StrictYAML fixes this with explicit typing).
* Allows arbitrary binary data leading to, among other things, Ruby on Rails' spectacular [security fail](http://www.h-online.com/open/news/item/Rails-developers-close-another-extremely-critical-flaw-1793511.html) (disallowed in StrictYAML because *why on earth did anybody think this was a good idea?*).
* Tag tokens, allowing you to specify types in the YAML (disallowed in StrictYAML).
* Confusing "flow" style (disallowed by default in StrictYAML).
* Often confusing node anchors and references (disallowed by default in StrictYAML).


Using StrictYAML
----------------

    >>> from strictyaml import load, Map, Str
    >>> load(