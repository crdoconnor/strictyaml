from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.exceptions import YAMLValidationError
from strictyaml.yamllocation import YAMLLocation
from strictyaml.exceptions import raise_exception
from strictyaml.representation import YAML
from strictyaml import utils
import dateutil.parser
import decimal
import copy


class Optional(object):
    def __init__(self, key):
        self.key = key


class Validator(object):
    def __or__(self, other):
        return OrValidator(self, other)

    def __call__(self, document, location=None):
        if location is None:
            location = YAMLLocation()
        return self.validate(document, location)


class OrValidator(Validator):
    def __init__(self, validator_a, validator_b):
        self._validator_a = validator_a
        self._validator_b = validator_b

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)

        try:
            return self._validator_a(document, location=location)
        except YAMLValidationError:
            return self._validator_b(document, location=location)

    def __repr__(self):
        return u"{0} | {1}".format(repr(self._validator_a), repr(self._validator_b))


def schema_from_data(document):
    if isinstance(document, CommentedMap):
        return Map({key: schema_from_data(value) for key, value in document.items()})
    elif isinstance(document, CommentedSeq):
        return FixedSeq([schema_from_data(item) for item in document])
    else:
        return Str()


class Any(Validator):
    """
    Validates any YAML and returns simple dicts/lists of strings.
    """
    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return schema_from_data(location.get(document))(document, location=location)

    def __repr__(self):
        return u"Any()"


class Scalar(Validator):
    @property
    def rule_description(self):
        return "a {0}".format(self.__class__.__name__.lower())

    def validate(self, document, location=None):
        val = location.get(document)

        if type(val) == CommentedSeq or type(val) == CommentedMap:
            raise_exception(
                "when expecting a {0}".format(self.__class__.__name__.lower()),
                "found mapping/sequence",
                document, location=location,
            )
        else:
            return self.validate_scalar(document, location, value=None)


class Enum(Scalar):
    def __init__(self, restricted_to):
        for element in restricted_to:
            assert type(element) is str
        self._restricted_to = restricted_to

    def validate_scalar(self, document, location, value):
        val = str(location.get(document)) if value is None else value
        if val not in self._restricted_to:
            raise_exception(
                "when expecting one of: {0}".format(", ".join(self._restricted_to)),
                "found '{0}'".format(val),
                document, location=location,
            )
        else:
            return YAML(val, document=document, location=location)

    def __repr__(self):
        return u"Enum({0})".format(repr(self._restricted_to))


class EmptyNone(Scalar):
    def validate_scalar(self, document, location, value):
        val = str(location.get(document)) if value is None else value
        if val != "":
            raise_exception(
                "when expecting an empty value",
                "found non-empty value",
                document, location=location,
            )
        else:
            return self.empty(document, location)

    def empty(self, document, location):
        return YAML(None, '', document=document, location=location)

    def __repr__(self):
        return u"EmptyNone()"


class EmptyDict(EmptyNone):
    def empty(self, document, location):
        return YAML({}, '', document=document, location=location)

    def __repr__(self):
        return u"EmptyDict()"


class EmptyList(EmptyNone):
    def empty(self, document, location):
        return YAML([], '', document=document, location=location)

    def __repr__(self):
        return u"EmptyList()"


class CommaSeparated(Scalar):
    def __init__(self, item_validator):
        self._item_validator = item_validator

    def validate_scalar(self, document, location, value):
        val = str(location.get(document)) if value is None else value
        return YAML(
            [
                YAML(self._item_validator.validate_scalar(document, location, value=item.lstrip()))
                for item in val.split(",")
            ],
            document=document,
            location=location
        )


class Str(Scalar):
    def validate_scalar(self, document, location, value=None):
        return YAML(
            str(location.get(document)) if value is None else value,
            text=location.get(document),
            document=document,
            location=location
        )

    def __repr__(self):
        return u"Str()"


class Int(Scalar):
    def validate_scalar(self, document, location, value=None):
        val = str(location.get(document)) if value is None else value
        if not utils.is_integer(val):
            raise_exception(
                    "when expecting an integer",
                    "found non-integer",
                    document, location=location,
                )
        else:
            return YAML(int(val), val, document=document, location=location)

    def __repr__(self):
        return u"Int()"


TRUE_VALUES = ["yes", "true", "on", "1", ]
FALSE_VALUES = ["no", "false", "off", "0", ]
BOOL_VALUES = TRUE_VALUES + FALSE_VALUES


class Bool(Scalar):
    def validate_scalar(self, document, location, value=None):
        val = str(location.get(document)) if value is None else value
        if str(val).lower() not in BOOL_VALUES:
            raise_exception(
                """when expecting a boolean value (one of "{0}")""".format(
                    '", "'.join(BOOL_VALUES)
                ),
                "found non-boolean",
                document, location=location,
            )
        else:
            if val in TRUE_VALUES:
                return YAML(True, val, document=document, location=location)
            else:
                return YAML(False, val, document=document, location=location)

    def __repr__(self):
        return u"Bool()"


class Float(Scalar):
    def validate_scalar(self, document, location, value=None):
        val = str(location.get(document)) if value is None else value
        if not utils.is_decimal(str(val)):
            raise_exception(
                "when expecting a float",
                "found non-float",
                document, location=location,
            )
        else:
            return YAML(float(val), val, document=document, location=location)

    def __repr__(self):
        return u"Float()"


class Decimal(Scalar):
    def validate_scalar(self, document, location, value=None):
        val = str(location.get(document)) if value is None else value
        if not utils.is_decimal(str(val)):
            raise_exception(
                "when expecting a decimal",
                "found non-decimal",
                document, location=location,
            )
        else:
            return YAML(decimal.Decimal(val), val, document=document, location=location)

    def __repr__(self):
        return u"Decimal()"


class Datetime(Scalar):
    def validate_scalar(self, document, location, value=None):
        val = str(location.get(document)) if value is None else value

        try:
            return YAML(dateutil.parser.parse(val), val, document=document, location=location)
        except ValueError:
            raise_exception(
                "when expecting a datetime",
                "found non-datetime",
                document, location=location,
            )

    def __repr__(self):
        return u"Datetime()"


class MapPattern(Validator):
    def __init__(self, key_validator, value_validator):
        self._key_validator = key_validator
        self._value_validator = value_validator

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = location.get(document)

        if type(location.get(document)) != CommentedMap:
            raise_exception(
                "when expecting a mapping",
                "found non-mapping",
                document, location=location,
            )
        else:
            for key, value in location.get(document).items():
                valid_key = self._key_validator(document, location.key(key))
                valid_val = self._value_validator(document, location.val(key))
                return_snippet[valid_key] = valid_val

        return YAML(return_snippet, document=document, location=location)

    def __repr__(self):
        return u"MapPattern({0}, {1})".format(
            repr(self._key_validator), repr(self._value_validator)
        )


class Map(Validator):
    def __init__(self, validator):
        self._validator = validator

        self._validator_dict = {
            key.key if type(key) == Optional else key: value for key, value in validator.items()
        }

    def __repr__(self):
        return u"Map({{{0}}})".format(', '.join([
            '{0}: {1}'.format(
                'Optional("{0}")'.format(key.key) if type(key) is Optional else '"{0}"'.format(key),
                repr(value)
            ) for key, value in self._validator.items()
        ]))

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = location.get(document)

        if type(location.get(document)) != CommentedMap:
            raise_exception(
                "when expecting a mapping",
                "found non-mapping",
                document, location=location,
            )
        else:
            for key, value in location.get(document).items():
                if key not in self._validator_dict.keys():
                    raise_exception(
                        "while parsing a mapping",
                        "unexpected key not in schema '{0}'".format(key),
                        document, location=location.key(key)
                    )

                del return_snippet[key]
                return_snippet[
                    YAML(key, document=document, location=location.key(key))
                ] = self._validator_dict[key](
                    document, location.val(key)
                )

        return YAML(return_snippet, document=document, location=location)


class Seq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "Seq({0})".format(repr(self._validator))

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = location.get(document)

        if type(location.get(document)) != CommentedSeq:
            raise_exception(
                "when expecting a sequence",
                "found non-sequence",
                document, location=location,
            )
        else:
            for i, item in enumerate(location.get(document)):
                return_snippet[i] = self._validator(document, location=location.index(i))

        return YAML(return_snippet, document=document, location=location)


class FixedSeq(Validator):
    def __init__(self, validators):
        self._validators = validators

    def __repr__(self):
        return "FixedSeq({0})".format(repr(self._validators))

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = location.get(document)

        if type(location.get(document)) != CommentedSeq:
            raise_exception(
                "when expecting a sequence of {0} elements".format(len(self._validators)),
                "found non-sequence",
                document, location=location,
            )
        else:
            if len(self._validators) != len(location.get(document)):
                raise_exception(
                    "when expecting a sequence of {0} elements".format(len(self._validators)),
                    "found a sequence of {0} elements".format(len(location.get(document))),
                    document, location=location,
                )
            for i, item_and_val in enumerate(zip(location.get(document), self._validators)):
                item, validator = item_and_val
                return_snippet[i] = validator(document, location=location.index(i))

        return YAML(return_snippet, document=document, location=location)


class UniqueSeq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def __repr__(self):
        return "UniqueSeq({0})".format(repr(self._validator))

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)

        return_snippet = location.get(document)

        if type(location.get(document)) != CommentedSeq:
            raise_exception(
                "when expecting a unique sequence",
                "found non-sequence",
                document, location=location,
            )
        else:
            existing_items = set()

            for i, item in enumerate(location.get(document)):
                if item in existing_items:
                    raise_exception(
                        "while parsing a sequence",
                        "duplicate found",
                        document, location=location
                    )
                else:
                    existing_items.add(item)
                    return_snippet[i] = self._validator(document, location=location.index(i))

        return YAML(return_snippet, document=document, location=location)
