What is YAML?
-------------

YAML is a simple, human readable format for representing associative and hierarchical data:

.. code-block:: yaml

    receipt: Oz-Ware Purchase Invoice
    date: 2012-08-06
    customer:
      first name: Harry
      family name: Potter
    address: |-
      4 Privet Drive,
      Little Whinging,
      England
    items:
      - part_no: A4786
        description: Water Bucket (Filled)
        price: 1.47
        quantity:  4

      - part_no: E1628
        description: High Heeled "Ruby" Slippers
        size: 8
        price: 133.7
        quantity: 1

Key features:

* Things which are associated with other things - delimited by the colon (:).
* Ordered lists of things - delimited by the prepended dash (-).
* Multi-line strings - delimited by the bar (|) if there is another newline at the end of the string, or bar + dash (|-) if not.
* Indentation describing the hierarchy of data.
* Maps directly to data types common to most high level languages - lists, dicts, scalars.

This is all you really need to know.
