from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.compound import FixedSeq, Map
from strictyaml.validators import Validator
from strictyaml.exceptions import YAMLSerializationError
from strictyaml.scalar import Str


def schema_from_document(document):
    if isinstance(document, CommentedMap):
        return Map(
            {key: schema_from_document(value) for key, value in document.items()}
        )
    elif isinstance(document, CommentedSeq):
        return FixedSeq([schema_from_document(item) for item in document])
    else:
        return Str()


def schema_from_data(data):
    if isinstance(data, dict):
        if len(data) == 0:
            raise YAMLSerializationError(
                "Empty dicts are not serializable to StrictYAML unless schema is used."
            )
        return Map({key: schema_from_data(value) for key, value in data.items()})
    elif isinstance(data, list):
        if len(data) == 0:
            raise YAMLSerializationError(
                "Empty lists are not serializable to StrictYAML unless schema is used."
            )
        return FixedSeq([schema_from_data(item) for item in data])
    else:
        return Str()


class Any(Validator):
    """
    Validates any YAML and returns simple dicts/lists of strings.
    """

    def validate(self, chunk):
        return schema_from_document(chunk.contents)(chunk)

    def to_yaml(self, data):
        return schema_from_data(data).to_yaml(data)
