from ruamel.yaml.comments import CommentedMap, CommentedSeq
from strictyaml.exceptions import YAMLSerializationError, InvalidOptionalDefault
from strictyaml.scalar import ScalarValidator, Str
from strictyaml.validators import Validator, MapValidator
from strictyaml.yamllocation import YAMLChunk
import sys


if sys.version_info[0] == 3:
    unicode = str


class Optional(object):
    def __init__(self, key, default=None):
        self.key = key
        self.default = default

    def __repr__(self):
        # TODO: Add default
        return u'Optional("{0}")'.format(self.key)


class MapPattern(MapValidator):
    def __init__(
        self, key_validator, value_validator, minimum_keys=None, maximum_keys=None
    ):
        self._key_validator = key_validator
        self._value_validator = value_validator
        self._maximum_keys = maximum_keys
        self._minimum_keys = minimum_keys
        assert isinstance(
            self._key_validator, ScalarValidator
        ), "key_validator must be ScalarValidator"
        assert isinstance(
            self._value_validator, Validator
        ), "value_validator must be Validator"
        assert isinstance(
            maximum_keys, (type(None), int)
        ), "maximum_keys must be an integer"
        assert isinstance(
            minimum_keys, (type(None), int)
        ), "maximum_keys must be an integer"

    @property
    def key_validator(self):
        return self._key_validator

    def validate(self, chunk):
        items = chunk.expect_mapping()

        if self._maximum_keys is not None and len(items) > self._maximum_keys:
            chunk.expecting_but_found(
                u"while parsing a mapping",
                u"expected a maximum of {0} key{1}, found {2}.".format(
                    self._maximum_keys,
                    u"s" if self._maximum_keys > 1 else u"",
                    len(items),
                ),
            )

        if self._minimum_keys is not None and len(items) < self._minimum_keys:
            chunk.expecting_but_found(
                u"while parsing a mapping",
                u"expected a minimum of {0} key{1}, found {2}.".format(
                    self._minimum_keys,
                    u"s" if self._minimum_keys > 1 else u"",
                    len(items),
                ),
            )

        for key, value in items:
            yaml_key = self._key_validator(key)
            key.process(yaml_key)
            value.process(self._value_validator(value))
            chunk.add_key_association(key.contents, yaml_key.data)

    def to_yaml(self, data):
        self._should_be_mapping(data)
        # TODO : Maximum minimum keys
        return CommentedMap(
            [
                (self._key_validator.to_yaml(key), self._value_validator.to_yaml(value))
                for key, value in data.items()
            ]
        )

    def __repr__(self):
        return u"MapPattern({0}, {1})".format(
            repr(self._key_validator), repr(self._value_validator)
        )


class Map(MapValidator):
    def __init__(self, validator, key_validator=None):
        self._validator = validator
        self._key_validator = Str() if key_validator is None else key_validator
        assert isinstance(
            self._key_validator, ScalarValidator
        ), "key validator must be ScalarValidator"

        self._validator_dict = {
            key.key if isinstance(key, Optional) else key: value
            for key, value in validator.items()
        }

        self._required_keys = [
            key for key in validator.keys() if not isinstance(key, Optional)
        ]

        for key_val, value_val in validator.items():
            if isinstance(key_val, Optional):
                if key_val.default is not None:
                    try:
                        value_val.to_yaml(key_val.default)
                    except YAMLSerializationError as error:
                        raise InvalidOptionalDefault(
                            "Optional default for '{}' failed validation:\n  {}".format(
                                key_val.key, error
                            )
                        )

        self._defaults = {
            key.key: key.default
            for key in validator.keys()
            if isinstance(key, Optional) and key.default is not None
        }

    @property
    def key_validator(self):
        return self._key_validator

    def __repr__(self):
        # TODO : repr key_validator
        return u"Map({{{0}}})".format(
            ", ".join(
                [
                    "{0}: {1}".format(repr(key), repr(value))
                    for key, value in self._validator.items()
                ]
            )
        )

    def validate(self, chunk):
        found_keys = set()
        items = chunk.expect_mapping()

        for key, value in items:
            yaml_key = self._key_validator(key)

            if yaml_key.scalar not in self._validator_dict.keys():
                key.expecting_but_found(
                    u"while parsing a mapping",
                    u"unexpected key not in schema '{0}'".format(
                        unicode(yaml_key.scalar)
                    ),
                )

            value.process(self._validator_dict[yaml_key.scalar](value))
            key.process(yaml_key)
            chunk.add_key_association(key.contents, yaml_key.data)
            found_keys.add(yaml_key.scalar)

        for default_key, default_data in self._defaults.items():
            if default_key not in [key.contents for key, _ in items]:
                key_chunk = YAMLChunk(default_key)
                yaml_key = self._key_validator(key_chunk)
                strictindex = yaml_key.data
                value_validator = self._validator_dict[default_key]
                new_value = value_validator(
                    YAMLChunk(value_validator.to_yaml(default_data))
                )
                forked_chunk = chunk.fork(strictindex, new_value)
                forked_chunk.val(strictindex).process(new_value)
                updated_value = value_validator(forked_chunk.val(strictindex))
                updated_value._chunk.make_child_of(chunk.val(strictindex))
                # marked_up = new_value.as_marked_up()
                # chunk.contents[chunk.ruamelindex(strictindex)] = marked_up
                chunk.add_key_association(default_key, strictindex)
                chunk.strictparsed()[yaml_key] = updated_value

        if not set(self._required_keys).issubset(found_keys):
            chunk.while_parsing_found(
                u"a mapping",
                u"required key(s) '{0}' not found".format(
                    "', '".join(
                        sorted(list(set(self._required_keys).difference(found_keys)))
                    )
                ),
            )

    def to_yaml(self, data):
        self._should_be_mapping(data)
        # TODO : if keys not in list or required keys missing, raise exception.
        return CommentedMap(
            [
                (key, self._validator_dict[key].to_yaml(value))
                for key, value in data.items()
                if key not in self._defaults.keys()
                or key in self._defaults.keys()
                and value != self._defaults[key]
            ]
        )


class SeqValidator(Validator):
    def _should_be_list(self, data):
        if not isinstance(data, list):
            raise YAMLSerializationError("Expected a list, found '{}'".format(data))
        if len(data) == 0:
            raise YAMLSerializationError(
                (
                    "Expected a non-empty list, found an empty list.\n"
                    "Use EmptyList validator to serialize empty lists."
                )
            )


class Seq(SeqValidator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "Seq({0})".format(repr(self._validator))

    def validate(self, chunk):
        for item in chunk.expect_sequence():
            item.process(self._validator(item))

    def to_yaml(self, data):
        self._should_be_list(data)
        return CommentedSeq([self._validator.to_yaml(item) for item in data])


class FixedSeq(SeqValidator):
    def __init__(self, validators):
        self._validators = validators
        for item in validators:
            assert isinstance(
                item, Validator
            ), "all FixedSeq validators must be Validators"

    def __repr__(self):
        return "FixedSeq({0})".format(repr(self._validators))

    def validate(self, chunk):
        sequence = chunk.expect_sequence(
            "when expecting a sequence of {0} elements".format(len(self._validators))
        )

        if len(self._validators) != len(sequence):
            chunk.expecting_but_found(
                "when expecting a sequence of {0} elements".format(
                    len(self._validators)
                ),
                "found a sequence of {0} elements".format(len(chunk.contents)),
            )

        for item, validator in zip(sequence, self._validators):
            item.process(validator(item))

    def to_yaml(self, data):
        self._should_be_list(data)
        # TODO : Different length string
        return CommentedSeq(
            [validator.to_yaml(item) for item, validator in zip(data, self._validators)]
        )


class UniqueSeq(SeqValidator):
    def __init__(self, validator):
        self._validator = validator
        assert isinstance(
            self._validator, ScalarValidator
        ), "UniqueSeq validator must be ScalarValidator"

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

    def to_yaml(self, data):
        self._should_be_list(data)

        if len(set(data)) < len(data):
            raise YAMLSerializationError(
                (
                    "Expecting all unique items, "
                    "but duplicates were found in '{}'.".format(data)
                )
            )

        return CommentedSeq([self._validator.to_yaml(item) for item in data])
