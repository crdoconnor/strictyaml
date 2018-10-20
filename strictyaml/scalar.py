from strictyaml.exceptions import YAMLSerializationError
from strictyaml.validators import Validator
from strictyaml.representation import YAML
from strictyaml import constants
from strictyaml import utils
from datetime import datetime
import dateutil.parser
import decimal
import sys
import re


if sys.version_info[0] == 3:
    unicode = str


class ScalarValidator(Validator):
    @property
    def rule_description(self):
        return "a {0}".format(self.__class__.__name__.lower())

    def __call__(self, chunk):
        chunk.expect_scalar(self.rule_description)
        return YAML(
            self.validate_scalar(chunk),
            text=chunk.contents,
            chunk=chunk,
            validator=self,
        )

    def should_be_string(self, data, message):
        if not utils.is_string(data):
            raise YAMLSerializationError(
                "{0} got '{1}' of type {2}.".format(message, data, type(data).__name__)
            )

    def validate_scalar(self, chunk):
        raise NotImplementedError("validate_scalar(self, chunk) must be implemented")


class Enum(ScalarValidator):
    def __init__(self, restricted_to, item_validator=None):
        self._item_validator = Str() if item_validator is None else item_validator
        assert isinstance(
            self._item_validator, ScalarValidator
        ), "item validator must be scalar too"
        self._restricted_to = restricted_to

    def validate_scalar(self, chunk):
        val = self._item_validator(chunk)
        val._validator = self
        if val.scalar not in self._restricted_to:
            chunk.expecting_but_found(
                "when expecting one of: {0}".format(", ".join(self._restricted_to))
            )
        else:
            return val

    def to_yaml(self, data):
        if data not in self._restricted_to:
            raise YAMLSerializationError(
                "Got '{0}' when  expecting one of: {1}".format(
                    data, ", ".join(self._restricted_to)
                )
            )
        return self._item_validator.to_yaml(data)

    def __repr__(self):
        # TODO : item_validator
        return u"Enum({0})".format(repr(self._restricted_to))


class CommaSeparated(ScalarValidator):
    def __init__(self, item_validator):
        self._item_validator = item_validator
        assert isinstance(
            self._item_validator, ScalarValidator
        ), "item validator must be scalar too"

    def validate_scalar(self, chunk):
        return [
            self._item_validator.validate_scalar(
                chunk.textslice(positions[0], positions[1])
            )
            for positions in utils.comma_separated_positions(chunk.contents)
        ]

    def to_yaml(self, data):
        if isinstance(data, list):
            return ", ".join([self._item_validator.to_yaml(item) for item in data])
        elif utils.is_string(data):
            for item in data.split(","):
                self._item_validator.to_yaml(item)
            return data
        else:
            raise YAMLSerializationError(
                "expected string or list, got '{}' of type '{}'".format(data, type(data).__name__)
            )

    def __repr__(self):
        return "CommaSeparated({0})".format(self._item_validator)


class Regex(ScalarValidator):
    def __init__(self, regular_expression):
        """
        Give regular expression, e.g. u'[0-9]'
        """
        self._regex = regular_expression
        self._matching_message = "when expecting string matching {0}".format(
            self._regex
        )

    def validate_scalar(self, chunk):
        if re.compile(self._regex).match(chunk.contents) is None:
            chunk.expecting_but_found(
                self._matching_message, "found non-matching string"
            )
        return chunk.contents

    def to_yaml(self, data):
        self.should_be_string(data, self._matching_message)
        if re.compile(self._regex).match(data) is None:
            raise YAMLSerializationError(
                "{} found '{}'".format(self._matching_message, data)
            )
        return data


class Email(Regex):
    def __init__(self):
        self._regex = constants.REGEXES["email"]
        self._matching_message = "when expecting an email address"


class Url(Regex):
    def __init__(self):
        self._regex = constants.REGEXES["url"]
        self._matching_message = "when expecting a url"


class Str(ScalarValidator):
    def validate_scalar(self, chunk):
        return chunk.contents

    def to_yaml(self, data):
        if not utils.is_string(data):
            raise YAMLSerializationError("'{}' is not a string".format(data))
        return str(data)


class Int(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if not utils.is_integer(val):
            chunk.expecting_but_found("when expecting an integer")
        else:
            return int(val)

    def to_yaml(self, data):
        if utils.is_string(data) or isinstance(data, int):
            if utils.is_integer(str(data)):
                return str(data)
        raise YAMLSerializationError("'{}' not an integer.".format(data))


class Bool(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if unicode(val).lower() not in constants.BOOL_VALUES:
            chunk.expecting_but_found(
                """when expecting a boolean value (one of "{0}")""".format(
                    '", "'.join(constants.BOOL_VALUES)
                )
            )
        else:
            if val.lower() in constants.TRUE_VALUES:
                return True
            else:
                return False

    def to_yaml(self, data):
        if not isinstance(data, bool):
            if str(data).lower() in constants.BOOL_VALUES:
                return data
            else:
                raise YAMLSerializationError("Not a boolean")
        else:
            return u"yes" if data else u"no"


class Float(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if not utils.is_decimal(val):
            chunk.expecting_but_found("when expecting a float")
        else:
            return float(val)

    def to_yaml(self, data):
        if utils.has_number_type(data):
            return str(data)
        if utils.is_string(data) and utils.is_decimal(data):
            return data
        raise YAMLSerializationError("when expecting a float, got '{}'".format(data))


class Decimal(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if not utils.is_decimal(val):
            chunk.expecting_but_found("when expecting a decimal")
        else:
            return decimal.Decimal(val)


class Datetime(ScalarValidator):
    def validate_scalar(self, chunk):
        try:
            return dateutil.parser.parse(chunk.contents)
        except ValueError:
            chunk.expecting_but_found("when expecting a datetime")

    def to_yaml(self, data):
        if isinstance(data, datetime):
            return data.isoformat()
        if utils.is_string(data):
            try:
                dateutil.parser.parse(data)
                return data
            except ValueError:
                raise YAMLSerializationError(
                    "expected a datetime, got '{}'".format(data)
                )
        raise YAMLSerializationError(
            "expected a datetime, got '{}' of type '{}'".format(
                data, type(data).__name__
            )
        )


class EmptyNone(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if val != "":
            chunk.expecting_but_found("when expecting an empty value")
        else:
            return self.empty(chunk)

    def empty(self, chunk):
        return None

    def to_yaml(self, data):
        if data is None:
            return u""
        raise YAMLSerializationError("expected None, got '{}'")


class EmptyDict(EmptyNone):
    def empty(self, chunk):
        return {}

    def to_yaml(self, data):
        if data == {}:
            return u""
        raise YAMLSerializationError("Not an empty dict")


class EmptyList(EmptyNone):
    def empty(self, chunk):
        return []

    def to_yaml(self, data):
        if data == []:
            return u""
        raise YAMLSerializationError("expected empty list, got '{}'")
