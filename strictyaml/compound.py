from strictyaml.validators import Validator
from strictyaml.scalar import Str
import sys

if sys.version_info[0] == 3:
    unicode = str


class Optional(object):
    def __init__(self, key):
        self.key = key

    def __repr__(self):
        return u'Optional("{0}")'.format(self.key)


class MapPattern(Validator):
    def __init__(self, key_validator, value_validator):
        self._key_validator = key_validator
        self._value_validator = value_validator

    def validate(self, chunk):
        for key, value in chunk.expect_mapping():
            key.process(self._key_validator(key))
            value.process(self._value_validator(value))
        return chunk.strictparsed()

    def __repr__(self):
        return u"MapPattern({0}, {1})".format(
            repr(self._key_validator), repr(self._value_validator)
        )


class Map(Validator):
    def __init__(self, validator, key_validator=None):
        self._validator = validator
        self._key_validator = Str() if key_validator is None else key_validator

        self._validator_dict = {
            key.key if isinstance(key, Optional) else key: value for key, value in validator.items()
        }

        self._required_keys = [key for key in validator.keys() if not isinstance(key, Optional)]

    def __repr__(self):
        return u"Map({{{0}}})".format(', '.join([
            '{0}: {1}'.format(
                repr(key),
                repr(value),
            ) for key, value in self._validator.items()
        ]))

    def validate(self, chunk):
        found_keys = set()
        items = chunk.expect_mapping()

        for key, value in items:
            yaml_key = self._key_validator(key)

            if yaml_key._value not in self._validator_dict.keys():
                key.expecting_but_found(
                    u"while parsing a mapping",
                    u"unexpected key not in schema '{0}'".format(unicode(yaml_key._value))
                )

            value.process(self._validator_dict[yaml_key._value](value))
            key.process(yaml_key)
            found_keys.add(yaml_key._value)

        if not set(self._required_keys).issubset(found_keys):
            chunk.while_parsing_found(
                u"a mapping",
                u"required key(s) '{0}' not found".format(
                    "', '".join(sorted(list(set(self._required_keys).difference(found_keys))))
                )
            )

        return chunk.strictparsed()


class Seq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "Seq({0})".format(repr(self._validator))

    def validate(self, chunk):
        for item in chunk.expect_sequence():
            item.process(self._validator(item))
        return chunk.strictparsed()


class FixedSeq(Validator):
    def __init__(self, validators):
        self._validators = validators

    def __repr__(self):
        return "FixedSeq({0})".format(repr(self._validators))

    def validate(self, chunk):
        sequence = chunk.expect_sequence(
            "when expecting a sequence of {0} elements".format(len(self._validators))
        )

        if len(self._validators) != len(sequence):
            chunk.expecting_but_found(
                "when expecting a sequence of {0} elements".format(len(self._validators)),
                "found a sequence of {0} elements".format(len(chunk.contents)),
            )

        for item, validator in zip(sequence, self._validators):
            item.process(validator(item))

        return chunk.strictparsed()


class UniqueSeq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "UniqueSeq({0})".format(repr(self._validator))

    def validate(self, chunk):
        existing_items = set()

        for item in chunk.expect_sequence("when expecting a unique sequence"):
            if item.contents in existing_items:
                chunk.while_parsing_found("a sequence", "duplicate found")
            else:
                existing_items.add(item.contents)
                item.process(self._validator(item))
        return chunk.strictparsed()
