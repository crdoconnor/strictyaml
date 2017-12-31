from strictyaml.validators import Validator
from strictyaml.scalar import ScalarValidator
from strictyaml.scalar import Str
import sys

if sys.version_info[0] == 3:
    unicode = str


class Optional(object):
    def __init__(self, key):
        self.key = key

    def __repr__(self):
        return u'Optional("{0}")'.format(self.key)


class MapValidator(Validator):
    pass


class MapPattern(MapValidator):
    def __init__(self, key_validator, value_validator, minimum_keys=None, maximum_keys=None):
        self._key_validator = key_validator
        self._value_validator = value_validator
        self._maximum_keys = maximum_keys
        self._minimum_keys = minimum_keys
        assert isinstance(self._key_validator, ScalarValidator), \
            "key_validator must be ScalarValidator"
        assert isinstance(self._value_validator, Validator), \
            "value_validator must be Validator"
        assert isinstance(maximum_keys, (type(None), int)), \
            "maximum_keys must be an integer"
        assert isinstance(minimum_keys, (type(None), int)), \
            "maximum_keys must be an integer"

    @property
    def key_validator(self):
        return self._key_validator

    def validate(self, chunk):
        items = chunk.expect_mapping()

        if self._maximum_keys is not None and len(items) > self._maximum_keys:
            chunk.expecting_but_found(
                u"while parsing a mapping",
                u"expected a maximum of {0} key{1}, found {2}.".format(
                    self._maximum_keys, u"s" if self._maximum_keys > 1 else u"", len(items)
                )
            )

        if self._minimum_keys is not None and len(items) < self._minimum_keys:
            chunk.expecting_but_found(
                u"while parsing a mapping",
                u"expected a minimum of {0} key{1}, found {2}.".format(
                    self._minimum_keys, u"s" if self._minimum_keys > 1 else u"", len(items)
                )
            )

        for key, value in items:
            yaml_key = self._key_validator(key)
            key.process(yaml_key)
            value.process(self._value_validator(value))
            chunk.add_key_association(key.contents, yaml_key.data)

    def __repr__(self):
        return u"MapPattern({0}, {1})".format(
            repr(self._key_validator), repr(self._value_validator)
        )


class Map(MapValidator):
    def __init__(self, validator, key_validator=None):
        self._validator = validator
        self._key_validator = Str() if key_validator is None else key_validator
        assert isinstance(self._key_validator, ScalarValidator), \
            "key validator must be ScalarValidator"

        self._validator_dict = {
            key.key if isinstance(key, Optional) else key: value for key, value in validator.items()
        }

        self._required_keys = [key for key in validator.keys() if not isinstance(key, Optional)]

    @property
    def key_validator(self):
        return self._key_validator

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

            if yaml_key.scalar not in self._validator_dict.keys():
                key.expecting_but_found(
                    u"while parsing a mapping",
                    u"unexpected key not in schema '{0}'".format(unicode(yaml_key.scalar))
                )

            value.process(self._validator_dict[yaml_key.scalar](value))
            key.process(yaml_key)
            chunk.add_key_association(key.contents, yaml_key.data)
            found_keys.add(yaml_key.scalar)

        if not set(self._required_keys).issubset(found_keys):
            chunk.while_parsing_found(
                u"a mapping",
                u"required key(s) '{0}' not found".format(
                    "', '".join(sorted(list(set(self._required_keys).difference(found_keys))))
                )
            )


class SeqValidator(Validator):
    pass


class Seq(SeqValidator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "Seq({0})".format(repr(self._validator))

    def validate(self, chunk):
        for item in chunk.expect_sequence():
            item.process(self._validator(item))


class FixedSeq(SeqValidator):
    def __init__(self, validators):
        self._validators = validators
        for item in validators:
            assert isinstance(item, Validator),\
                "all FixedSeq validators must be Validators"

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


class UniqueSeq(SeqValidator):
    def __init__(self, validator):
        self._validator = validator
        assert isinstance(self._validator, ScalarValidator), \
            "UniqueSeq validator must be ScalarValidator"

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
