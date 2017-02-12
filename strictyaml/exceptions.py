from ruamel.yaml import MarkedYAMLError
from ruamel.yaml.dumper import RoundTripDumper
from ruamel.yaml import dump
try:
    from ruamel.yaml.error import Mark as StringMark
except ImportError:
    from ruamel.yaml.error import StringMark


class StrictYAMLError(MarkedYAMLError):
    pass


class YAMLValidationError(StrictYAMLError):
    pass


class DisallowedToken(StrictYAMLError):
    MESSAGE = "Disallowed token"


class TagTokenDisallowed(DisallowedToken):
    MESSAGE = "Tag tokens not allowed"


class FlowMappingDisallowed(DisallowedToken):
    MESSAGE = "Flow mapping tokens not allowed"


class AnchorTokenDisallowed(DisallowedToken):
    MESSAGE = "Anchor tokens not allowed"


class DuplicateKeysDisallowed(DisallowedToken):
    MESSAGE = "Duplicate keys not allowed"


def raise_exception(context, problem, document, location):
    str_document = dump(document, Dumper=RoundTripDumper)
    context_line = location.start_line(document) - 1
    problem_line = location.end_line(document) - 1
    context_index = len('\n'.join(str_document.split('\n')[:context_line]))
    problem_index = len('\n'.join(str_document.split('\n')[:problem_line]))
    raise YAMLValidationError(
        context,
        StringMark(
            "<unicode string>", context_index, context_line, 0, str_document, context_index + 1
        ),
        problem,
        StringMark(
            "<unicode string>", problem_index, problem_line, 0, str_document, problem_index + 1
        )
    )


def raise_type_error(yaml_object, to_type, alternatives):
    raise TypeError((
        "Cannot cast {0} to {1}.\n"
        "Use {2} instead."
    ).format(repr(yaml_object), to_type, alternatives))
