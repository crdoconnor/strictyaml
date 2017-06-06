from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.exceptions import raise_exception
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


class Scalar(Validator):
    @property
    def rule_description(self):
        return "a {0}".format(self.__class__.__name__.lower())

    def validate(self, chunk):
        val = chunk.contents

        if type(val) == CommentedSeq or type(val) == CommentedMap:
            raise_exception(
                "when expecting a {0}".format(self.__class__.__name__.lower()),
                "found mapping/sequence",
                chunk,
            )
        else:
            return self.validate_scalar(chunk, value=None)


class Enum(Scalar):
    def __init__(self, restricted_to):
        for element in restricted_to:
            assert type(element) is str
        self._restricted_to = restricted_to

    def validate_scalar(self, chunk, value):
        val = unicode(chunk.contents) if value is None else value
        if val not in self._restricted_to:
            raise_exception(
                "when expecting one of: {0}".format(", ".join(self._restricted_to)),
                "found '{0}'".format(val),
                chunk,
            )
        else:
            return YAML(val, chunk=chunk)

    def __repr__(self):
        return u"Enum({0})".format(repr(self._restricted_to))


class CommaSeparated(Scalar):
    def __init__(self, item_validator):
        self._item_validator = item_validator

    def validate_scalar(self, chunk, value):
        val = unicode(chunk.contents) if value is None else value
        return YAML(
            [
                YAML(self._item_validator.validate_scalar(chunk, value=item.lstrip()))
                for item in val.split(",")
            ],
            chunk=chunk,
        )

    def __repr__(self):
        return "CommaSeparated({0})".format(self._item_validator)


class Regex(Scalar):
    def __init__(self, regular_expression):
        """
        Give regular expression, e.g. u'[0-9]'
        """
        self._regex = regular_expression
        self._matching_message = "when expecting string matching {0}".format(self._regex)

    def validate_scalar(self, chunk, value=None):
        if re.compile(self._regex).match(chunk.contents) is None:
            raise_exception(
                self._matching_message,
                "found non-matching string",
                chunk,
            )
        return YAML(
            unicode(chunk.contents) if value is None else value,
            text=chunk.contents,
            chunk=chunk
        )


class Email(Regex):
    def __init__(self):
        self._regex = constants.REGEXES['email']
        self._matching_message = "when expecting an email address"


class Url(Regex):
    def __init__(self):
        self._regex = constants.REGEXES['url']
        self._matching_message = "when expecting a url"


class Str(Scalar):
    def validate_scalar(self, chunk, value=None):
        return YAML(
            unicode(chunk.contents) if value is None else value,
            text=chunk.contents,
            chunk=chunk,
        )

    def __repr__(self):
        return u"Str()"


class Int(Scalar):
    def validate_scalar(self, chunk, value=None):
        val = unicode(chunk.contents) if value is None else value
        if not utils.is_integer(val):
            raise_exception(
                    "when expecting an integer",
                    "found non-integer",
                    chunk,
                )
        else:
            return YAML(int(val), val, chunk=chunk)

    def __repr__(self):
        return u"Int()"


class Bool(Scalar):
    def validate_scalar(self, chunk, value=None):
        val = unicode(chunk.contents) if value is None else value
        if unicode(val).lower() not in constants.BOOL_VALUES:
            raise_exception(
                """when expecting a boolean value (one of "{0}")""".format(
                    '", "'.join(constants.BOOL_VALUES)
                ),
                "found non-boolean",
                chunk,
            )
        else:
            if val.lower() in constants.TRUE_VALUES:
                return YAML(True, val, chunk=chunk)
            else:
                return YAML(False, val, chunk=chunk)

    def __repr__(self):
        return u"Bool()"


class Float(Scalar):
    def validate_scalar(self, chunk, value=None):
        val = unicode(chunk.contents) if value is None else value
        if not utils.is_decimal(val):
            raise_exception(
                "when expecting a float",
                "found non-float",
                chunk,
            )
        else:
            return YAML(float(val), val, chunk=chunk)

    def __repr__(self):
        return u"Float()"


class Decimal(Scalar):
    def validate_scalar(self, chunk, value=None):
        val = unicode(chunk.contents) if value is None else value
        if not utils.is_decimal(val):
            raise_exception(
                "when expecting a decimal",
                "found non-decimal",
                chunk,
            )
        else:
            return YAML(decimal.Decimal(val), val, chunk=chunk)

    def __repr__(self):
        return u"Decimal()"


class Datetime(Scalar):
    def validate_scalar(self, chunk, value=None):
        val = unicode(chunk.contents) if value is None else value

        try:
            return YAML(dateutil.parser.parse(val), val, chunk=chunk)
        except ValueError:
            raise_exception(
                "when expecting a datetime",
                "found non-datetime",
                chunk,
            )

    def __repr__(self):
        return u"Datetime()"


class EmptyNone(Scalar):
    def validate_scalar(self, chunk, value):
        val = unicode(chunk.contents) if value is None else value
        if val != "":
            raise_exception(
                "when expecting an empty value",
                "found non-empty value",
                chunk,
            )
        else:
            return self.empty(chunk)

    def empty(self, chunk):
        return YAML(None, '', chunk=chunk)

    def __repr__(self):
        return u"EmptyNone()"


class EmptyDict(EmptyNone):
    def empty(self, chunk):
        return YAML({}, '', chunk=chunk)

    def __repr__(self):
        return u"EmptyDict()"


class EmptyList(EmptyNone):
    def empty(self, chunk):
        return YAML([], '', chunk=chunk)

    def __repr__(self):
        return u"EmptyList()"
