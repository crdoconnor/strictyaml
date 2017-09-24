from ruamel.yaml.comments import CommentedSeq, CommentedMap
from re import compile
import sys


if sys.version_info[0] == 3:
    unicode = str


def is_integer(value):
    return compile("^[-+]?\d+$").match(value) is not None


def is_decimal(value):
    return compile(r"^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$").match(value) is not None


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
