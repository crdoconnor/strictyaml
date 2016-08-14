from ruamel import yaml as ruamelyaml
from strictyaml import exceptions
from ruamel.yaml.comments import CommentedSeq, CommentedMap


def load(stream, schema):
    """
    Parse the first YAML document in a stream
    and produce the corresponding Python object.
    """
    stream_type = str(type(stream))
    if stream_type not in ("<type 'unicode'>", "<type 'str'>", "<class 'str'>"):
        raise TypeError("StrictYAML can only read a string of valid YAML.")

    document = ruamelyaml.load(stream, Loader=ruamelyaml.RoundTripLoader)

    # Document is single item (string, int, etc.)
    if type(document) not in (CommentedMap, CommentedSeq):
        document = stream

    for token in ruamelyaml.scan(stream):
        if type(token) == ruamelyaml.tokens.TagToken:
            raise exceptions.TagTokenDisallowed(
                document,
                token.start_mark.line + 1,
                token.end_mark.line + 1
            )
        if type(token) == ruamelyaml.tokens.FlowMappingStartToken:
            raise exceptions.FlowMappingDisallowed(
                document,
                token.start_mark.line + 1,
                token.end_mark.line + 1
            )
        if type(token) == ruamelyaml.tokens.AnchorToken:
            raise exceptions.AnchorTokenDisallowed(
                document,
                token.start_mark.line + 1,
                token.end_mark.line + 1
            )

    return schema(document)
