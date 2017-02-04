Datetime validation
===================

valid_sequence
.. code-block:: yaml

  date: 2016-10-22
  datetime1: 2016-10-22T14:23:12+00:00
  datetime2: 2016-10-22T14:23:12Z
  datetime3: 20161022T142312Z

invalid_sequence_1
.. code-block:: yaml

  date: 1
  datetime1: a
  datetime2: b
  datetime3: c

.. code-block:: python

  >>> from strictyaml import Map, Datetime, YAMLValidationError, load
  >>> from datetime import datetime
  >>> from dateutil.tz.tz import tzutc
  >>> 
  >>> schema = Map({
  >>>     "date": Datetime(),
  >>>     "datetime1": Datetime(),
  >>>     "datetime2": Datetime(),
  >>>     "datetime3": Datetime(),
  >>> })

.. code-block:: python

  >>> load(valid_sequence, schema) == {
  >>>     "date": datetime(2016, 10, 22, 0, 0),
  >>>     "datetime1": datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc()),
  >>>     "datetime2": datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc()),
  >>>     "datetime3": datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc()),
  >>> }
  True

