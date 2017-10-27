from strictyaml.validators import Validator
from strictyaml.representation import YAML
from strictyaml import constants
from strictyaml import utils
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

    def validate_scalar(self, chunk):
        raise NotImplementedError("validate_scalar(self, chunk) must be implemented")


class Enum(ScalarValidator):
    def __init__(self, restricted_to, item_validator=None):
        self._item_validator = Str() if item_validator is None else item_validator
        assert isinstance(self._item_validator, ScalarValidator), \
            "item validator must be scalar too"
        self._restricted_to = restricted_to

    def validate_scalar(self, chunk):
        val = self._item_validator(chunk)
        if val.scalar not in self._restricted_to:
            chunk.expecting_but_found(
                "when expecting one of: {0}".format(", ".join(self._restricted_to)),
            )
        else:
            return val

    def __repr__(self):
        return u"Enum({0})".format(repr(self._restricted_to))


class CommaSeparated(ScalarValidator):
    def __init__(self, item_validator):
        self._item_validator = item_validator
        assert isinstance(self._item_validator, ScalarValidator), \
            "item validator must be scalar too"

    def validate_scalar(self, chunk):
        return [
            self._item_validator.validate_scalar(chunk.textslice(positions[0], positions[1]))
            for positions in utils.comma_separated_positions(chunk.contents)
        ]

    def __repr__(self):
        return "CommaSeparated({0})".format(self._item_validator)


class Regex(ScalarValidator):
    def __init__(self, regular_expression):
        """
        Give regular expression, e.g. u'[0-9]'
        """
        self._regex = regular_expression
        self._matching_message = "when expecting string matching {0}".format(self._regex)

    def validate_scalar(self, chunk):
        if re.compile(self._regex).match(chunk.contents) is None:
            chunk.expecting_but_found(
                self._matching_message,
                "found non-matching string",
            )
        return chunk.contents


class Email(Regex):
    def __init__(self):
        self._regex = constants.REGEXES['email']
        self._matching_message = "when expecting an email address"


class Url(Regex):
    def __init__(self):
        self._regex = constants.REGEXES['url']
        self._matching_message = "when expecting a url"


class Str(ScalarValidator):
    def validate_scalar(self, chunk):
        return chunk.contents


class Int(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if not utils.is_integer(val):
            chunk.expecting_but_found(
                "when expecting an integer",
            )
        else:
            return int(val)


class Bool(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if unicode(val).lower() not in constants.BOOL_VALUES:
            chunk.expecting_but_found(
                """when expecting a boolean value (one of "{0}")""".format(
                    '", "'.join(constants.BOOL_VALUES)
                ),
            )
        else:
            if val.lower() in constants.TRUE_VALUES:
                return True
            else:
                return False


class Float(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if not utils.is_decimal(val):
            chunk.expecting_but_found(
                "when expecting a float",
            )
        else:
            return float(val)


class Decimal(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if not utils.is_decimal(val):
            chunk.expecting_but_found(
                "when expecting a decimal",
            )
        else:
            return decimal.Decimal(val)


class Datetime(ScalarValidator):
    def validate_scalar(self, chunk):
        try:
            return dateutil.parser.parse(chunk.contents)
        except ValueError:
            chunk.expecting_but_found(
                "when expecting a datetime",
            )


class EmptyNone(ScalarValidator):
    def validate_scalar(self, chunk):
        val = chunk.contents
        if val != "":
            chunk.expecting_but_found(
                "when expecting an empty value",
            )
        else:
            return self.empty(chunk)

    def empty(self, chunk):
        return None


class EmptyDict(EmptyNone):
    def empty(self, chunk):
        return {}


class EmptyList(EmptyNone):
    def empty(self, chunk):
        return []
