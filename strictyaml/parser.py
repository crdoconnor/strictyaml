from ruamel import yaml as ruamelyaml


def load(stream, schema):
    """
    Parse the first YAML document in a stream
    and produce the corresponding Python object.
    """
    return schema(ruamelyaml.load(stream, Loader=ruamelyaml.RoundTripLoader))
