What is wrong with implicit typing?
-----------------------------------

Imagine you are parsing a DSL to represent movie scripts:

.. code-block:: yaml

  - Don Corleone: Do you have faith in my judgment?
  - Clemenza: Yes
  - Don Corleone: Do I have your loyalty?

Parse output of `pyyaml <http://pyyaml.org and ruamel.yaml>`_, `ruamel.yaml <https://bitbucket.org/ruamel/yaml>`_ and `Poyo <https://github.com/hackebrot/poyo>`_:

.. code-block:: python

    >>> from ruamel.yaml import load
    >>> load(the_godfather)
    [{'Don Corleone': 'Do you have faith in my judgement?'},
     {'Clemenza': True},
     {'Don Corleone': 'Do I have your loyalty?'},]

Wait, Clemenza said what??

Parse output of StrictYAML without validators:

.. code-block:: python

    >>> from strictyaml import load, List, MapPattern, Str
    >>> load(the_godfather)
    [{'Don Corleone': 'Do you have faith in my judgement?'},
     {'Clemenza': 'Yes'},
     {'Don Corleone': 'Do I have your loyalty?'},]

Let's try the Matrix instead:

.. code-block:: python

  - Morpheus: Do you believe in fate, Neo?
  - Neo: No

Parse output from pyyaml, ruamel.yaml and poyo:

.. code-block:: python

    >>> load(the_matrix) == [{"Morpheus": "Do you belive in fate, Neo?"}, {"Neo": False}]

It isn't just a problem in movie scripts:

.. code-block:: yaml

   python: 3.5.3
   postgres: 9.3

.. code-block:: python

    >>> load(versions) == [{"python": "3.5.3", "postgres": 9.3}]    # oops those *both* should have been strings

It's also makes `Christopher Null <http://www.wired.com/2015/11/null/>`_ unhappy:

.. code-block:: yaml

   first name: Christopher
   surname: Null

.. code-block:: python

    # Is it okay if we just call you Christopher None instead?
    >>> load(name) == {"first name": "Christopher", "surname": None}


In the above cases, implicit typing represents a major violation of `the principle of least astonishment <https://en.wikipedia.org/wiki/Principle_of_least_astonishment>`_.
