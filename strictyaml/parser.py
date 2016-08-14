from ruamel import yaml as ruamelyaml
from strictyaml import exceptions


def load(stream, schema):
    """
    Parse the first YAML document in a stream
    and produce the corresponding Python object.
    """
    if type(stream) is not str:
        raise TypeError("StrictYAML can only read a string of valid YAML.")

    document = ruamelyaml.load(stream, Loader=ruamelyaml.RoundTripLoader)

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
