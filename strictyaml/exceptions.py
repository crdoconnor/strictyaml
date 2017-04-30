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


def raise_exception(context, problem, chunk):
    context_line = chunk.start_line() - 1
    problem_line = chunk.end_line() - 1
    str_document = dump(chunk.document, Dumper=RoundTripDumper)
    context_index = len(u'\n'.join(str_document.split(u'\n')[:context_line]))
    problem_index = len(u'\n'.join(str_document.split(u'\n')[:problem_line]))
    string_mark_a = StringMark(
        u"<unicode string>", context_index, context_line, 0, str_document, context_index + 1
    )
    string_mark_b = StringMark(
        u"<unicode string>", problem_index, problem_line, 0, str_document, problem_index + 1
    )
    raise YAMLValidationError(
        context,
        string_mark_a,
        problem,
        string_mark_b,
    )


def raise_type_error(yaml_object, to_type, alternatives):
    raise TypeError((
        "Cannot cast {0} to {1}.\n"
        "Use {2} instead."
    ).format(repr(yaml_object), to_type, alternatives))
