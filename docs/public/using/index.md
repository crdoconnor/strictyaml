---
title: Using StrictYAML
---

How to:

- [Build a YAML document from scratch in code](alpha/howto/build-yaml-document)
- [Either/or schema validation of different, equally valid different kinds of YAML](alpha/howto/either-or-validation)
- [Labeling exceptions](alpha/howto/label-exceptions)
- [Merge YAML documents](alpha/howto/merge-yaml-documents)
- [Revalidate an already validated document](alpha/howto/revalidation)
- [Reading in YAML, editing it and writing it back out](alpha/howto/roundtripping)
- [Get line numbers of YAML elements](alpha/howto/what-line)
- [Parsing YAML without a schema](alpha/howto/without-a-schema)


Compound validators:

- [Fixed length sequences (FixedSeq)](alpha/compound/fixed-length-sequences)
- [Mappings combining defined and undefined keys (MapCombined)](alpha/compound/map-combined)
- [Mappings with arbitrary key names (MapPattern)](alpha/compound/map-pattern)
- [Mapping with defined keys and a custom key validator (Map)](alpha/compound/mapping-with-slug-keys)
- [Using a YAML object of a parsed mapping](alpha/compound/mapping-yaml-object)
- [Mappings with defined keys (Map)](alpha/compound/mapping)
- [Optional keys with defaults (Map/Optional)](alpha/compound/optional-keys-with-defaults)
- [Validating optional keys in mappings (Map)](alpha/compound/optional-keys)
- [Sequences of unique items (UniqueSeq)](alpha/compound/sequences-of-unique-items)
- [Sequence/list validator (Seq)](alpha/compound/sequences)
- [Updating document with a schema](alpha/compound/update)


Scalar validators:

- [Boolean (Bool)](alpha/scalar/boolean)
- [Parsing comma separated items (CommaSeparated)](alpha/scalar/comma-separated)
- [Datetimes (Datetime)](alpha/scalar/datetime)
- [Decimal numbers (Decimal)](alpha/scalar/decimal)
- [Email and URL validators](alpha/scalar/email-and-url)
- [Empty key validation](alpha/scalar/empty)
- [Enumerated scalars (Enum)](alpha/scalar/enum)
- [Floating point numbers (Float)](alpha/scalar/float)
- [Hexadecimal Integers (HexInt)](alpha/scalar/hexadecimal-integer)
- [Integers (Int)](alpha/scalar/integer)
- [Validating strings with regexes (Regex)](alpha/scalar/regular-expressions)
- [Parsing strings (Str)](alpha/scalar/string)

Restrictions:

- [Disallowed YAML](alpha/restrictions/disallowed-yaml)
- [Duplicate keys](alpha/restrictions/duplicate-keys)
- [Dirty load](alpha/restrictions/loading-dirty-yaml)
