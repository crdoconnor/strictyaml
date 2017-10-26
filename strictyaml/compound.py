from ruamel.yaml.comments import CommentedSeq, CommentedMap
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
        for key in chunk.keys():
            chunk.process_key_val(
                self._key_validator(chunk.key(key)),
                self._value_validator(chunk.val(key)),
            )
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
        for key in chunk.keys():
            yaml_key = self._key_validator(chunk.key(key))
            if yaml_key._value not in self._validator_dict.keys():
                chunk.key(key).expecting_but_found(
                    u"while parsing a mapping",
                    u"unexpected key not in schema '{0}'".format(unicode(key))
                )
            
            found_keys.add(yaml_key)
            chunk.process_key_val(yaml_key, self._validator_dict[yaml_key](chunk.val(key)))
        
        if not set(self._required_keys).issubset(found_keys):
            chunk.expecting_but_found(
                u"while parsing a mapping",
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
        chunk.expect_sequence()
        return_snippet = chunk.strictparsed()

        for i, item in enumerate(chunk.contents):
            return_snippet[i] = self._validator(chunk.index(i))

        return return_snippet


class FixedSeq(Validator):
    def __init__(self, validators):
        self._validators = validators

    def __repr__(self):
        return "FixedSeq({0})".format(repr(self._validators))

    def validate(self, chunk):
        chunk.expect_sequence(
            "when expecting a sequence of {0} elements".format(len(self._validators))
        )
        return_snippet = chunk.strictparsed()

        if len(self._validators) != len(chunk.contents):
            chunk.expecting_but_found(
                "when expecting a sequence of {0} elements".format(len(self._validators)),
                "found a sequence of {0} elements".format(len(chunk.contents)),
            )
        for i, item_and_val in enumerate(zip(chunk.contents, self._validators)):
            item, validator = item_and_val
            return_snippet[i] = validator(chunk.index(i))

        return return_snippet


class UniqueSeq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "UniqueSeq({0})".format(repr(self._validator))

    def validate(self, chunk):
        chunk.expect_sequence(
            "when expecting a unique sequence"
        )
        return_snippet = chunk.strictparsed()

        existing_items = set()

        for i, item in enumerate(chunk.contents):
            if item in existing_items:
                chunk.expecting_but_found(
                    "while parsing a sequence",
                    "duplicate found"
                )
            else:
                existing_items.add(item)
                return_snippet[i] = self._validator(chunk.index(i))

        return return_snippet
