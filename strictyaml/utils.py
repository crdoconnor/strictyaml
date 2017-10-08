from ruamel.yaml.comments import CommentedSeq, CommentedMap
from re import compile
import sys


if sys.version_info[0] == 3:
    unicode = str


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


def ruamel_structure(data):
    """
    Take dicts and lists and return a ruamel.yaml style
    structure of CommentedMaps, CommentedSeqs and
    data.
    """
    if isinstance(data, dict):
        return CommentedMap([
            (ruamel_structure(key), ruamel_structure(value))
            for key, value in data.items()
        ])
    elif isinstance(data, list):
        return CommentedSeq([
            ruamel_structure(item) for item in data
        ])
    elif isinstance(data, bool):
        return u"yes" if data else u"no"
    else:
        return unicode(data)
