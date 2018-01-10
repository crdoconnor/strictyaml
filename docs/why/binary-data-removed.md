What is wrong with binary data?
-------------------------------

StrictYAML doesn't allow binary data to be parsed and will throw an exception if it sees it:

.. code-block:: yaml

    evildata: !!binary |
      R0lGODdhDQAIAIAAAAAAANn
      Z2SwAAAAADQAIAAACF4SDGQ
      ar3xxbJ9p0qa7R0YxwzaFME
      1IAADs=

This idiotic feature led to Ruby on Rails' spectacular `security fail <http://www.h-online.com/open/news/item/Rails-developers-close-another-extremely-critical-flaw-1793511.html>`_.
