from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml import exceptions
from re import compile
import decimal
import sys


if sys.version_info[0] == 3:
    unicode = str


def has_number_type(value):
    """
    Is a value a number or a non-number?

    >>> has_number_type(3.5)
    True

    >>> has_number_type(3)
    True

    >>> has_number_type(decimal.Decimal("3.5"))
    True

    >>> has_number_type("3.5")
    False
    """
    return isinstance(value, (int, float, decimal.Decimal))


def is_string(value):
    """
    Python 2/3 compatible way of checking if a value is a string.
    """
    return str(type(value)) in ("<type 'unicode'>", "<type 'str'>", "<class 'str'>")


def is_integer(value):
    """
    Is a string a string of an integer?

    >>> is_integer("4")
    True

    >>> is_integer("3.4")
    False
    """
    return compile("^[-+]?\d+$").match(value) is not None


def is_decimal(value):
    """
    Is a string a decimal?

    >>> is_decimal("4")
    True

    >>> is_decimal("3.5")
    True

    >>> is_decimal("blah")
    False
    """
    return compile(r"^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$").match(value) is not None


def comma_separated_positions(text):
    """
    Start and end positions of comma separated text items.

    Commas and trailing spaces should not be included.

    >>> comma_separated_positions("ABC, 2,3")
    [(0, 3), (5, 6), (7, 8)]
    """
    chunks = []
    start = 0
    end = 0
    for item in text.split(","):
        space_increment = 1 if item[0] == " " else 0
        start += space_increment  # Is there a space after the comma to ignore? ", "
        end += len(item.lstrip()) + space_increment
        chunks.append((start, end))
        start += len(item.lstrip()) + 1  # Plus comma
        end = start
    return chunks


def ruamel_structure(data, validator=None):
    """
    Take dicts and lists and return a ruamel.yaml style
    structure of CommentedMaps, CommentedSeqs and
    data.

    If a validator is presented and the type is unknown,
    it is checked against the validator to see if it will
    turn it back in to YAML.
    """
    if isinstance(data, dict):
        if len(data) == 0:
            raise exceptions.CannotBuildDocumentsFromEmptyDictOrList(
                "Document must be built with non-empty dicts and lists"
            )
        return CommentedMap(
            [
                (ruamel_structure(key), ruamel_structure(value))
                for key, value in data.items()
            ]
        )
    elif isinstance(data, list):
        if len(data) == 0:
            raise exceptions.CannotBuildDocumentsFromEmptyDictOrList(
                "Document must be built with non-empty dicts and lists"
            )
        return CommentedSeq([ruamel_structure(item) for item in data])
    elif isinstance(data, bool):
        return u"yes" if data else u"no"
    elif isinstance(data, (int, float)):
        return str(data)
    else:
        if not is_string(data):
            raise exceptions.CannotBuildDocumentFromInvalidData(
                (
                    "Document must be built from a combination of:\n"
                    "string, int, float, bool or nonempty list/dict\n\n"
                    "Instead, found variable with type '{}': '{}'"
                ).format(type(data).__name__, data)
            )
        return data
