from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.yamllocation import YAMLChunk
from strictyaml.any_validator import Any
import sys


if sys.version_info[0] == 3:
    unicode = str


def as_document(data):
    return Any()(YAMLChunk(marked_up(data)))


def marked_up(data):
    if isinstance(data, dict):
        return CommentedMap([
            (marked_up(key), marked_up(value))
            for key, value in data.items()
        ])
    elif isinstance(data, list):
        return CommentedSeq([
            marked_up(item) for item in data
        ])
    elif isinstance(data, bool):
        return u"yes" if data else u"no"
    else:
        return unicode(data)
