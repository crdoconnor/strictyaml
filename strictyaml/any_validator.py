from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.validators import Validator, FixedSeq, Map
from strictyaml.scalar import Str



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
    def validate(self, chunk):
        return schema_from_data(chunk.contents)(chunk)

    def __repr__(self):
        return u"Any()"
