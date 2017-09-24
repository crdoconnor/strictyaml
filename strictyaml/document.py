from strictyaml.yamllocation import YAMLChunk
from strictyaml.any_validator import Any
from strictyaml.utils import ruamel_structure
import sys


if sys.version_info[0] == 3:
    unicode = str


def as_document(data):
    return Any()(YAMLChunk(ruamel_structure(data)))
