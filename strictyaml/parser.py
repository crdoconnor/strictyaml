from ruamel import yaml as ruamelyaml
from strictyaml import exceptions
from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.validators import Any


from ruamel.yaml.reader import Reader
from ruamel.yaml.scanner import RoundTripScanner
from ruamel.yaml.parser import RoundTripParser
from ruamel.yaml.composer import Composer
from ruamel.yaml.constructor import RoundTripConstructor
from ruamel.yaml.resolver import VersionedResolver
from ruamel.yaml.nodes import MappingNode
from ruamel.yaml.compat import PY2
from ruamel.yaml.constructor import ConstructorError
import collections


# StrictYAMLConstructor is mostly taken from ruamel/yaml/constructor.py
# Differences:
#  * If a duplicate key is found, an exception is raised


class StrictYAMLConstructor(RoundTripConstructor):
        def construct_mapping(self, node, maptyp, deep=False):
            if not isinstance(node, MappingNode):
                raise ConstructorError(
                    None, None,
                    "expected a mapping node, but found %s" % node.id,
                    node.start_mark)
            merge_map = self.flatten_mapping(node)
            # mapping = {}
            if node.comment:
                maptyp._yaml_add_comment(node.comment[:2])
                if len(node.comment) > 2:
                    maptyp.yaml_end_comment_extend(node.comment[2], clear=True)
            if node.anchor:
                from ruamel.yaml.serializer import templated_id
                if not templated_id(node.anchor):
                    maptyp.yaml_set_anchor(node.anchor)
            for key_node, value_node in node.value:
                # keys can be list -> deep
                key = self.construct_object(key_node, deep=True)
                # lists are not hashable, but tuples are
                if not isinstance(key, collections.Hashable):
                    if isinstance(key, list):
                        key = tuple(key)
                if PY2:
                    try:
                        hash(key)
                    except TypeError as exc:
                        raise ConstructorError(
                            "while constructing a mapping", node.start_mark,
                            "found unacceptable key (%s)" %
                            exc, key_node.start_mark)
                else:
                    if not isinstance(key, collections.Hashable):
                        raise ConstructorError(
                            "while constructing a mapping", node.start_mark,
                            "found unhashable key", key_node.start_mark)
                value = self.construct_object(value_node, deep=deep)
                if key_node.comment:
                    maptyp._yaml_add_comment(key_node.comment, key=key)
                if value_node.comment:
                    maptyp._yaml_add_comment(value_node.comment, value=key)
                maptyp._yaml_set_kv_line_col(
                    key,
                    [
                        key_node.start_mark.line,
                        key_node.start_mark.column,
                        value_node.start_mark.line,
                        value_node.start_mark.column
                    ]
                )
                if key in maptyp:
                    raise exceptions.DuplicateKeysDisallowed(
                        "Duplicate key found",
                        key_node.start_mark.line + 1,
                        key_node.end_mark.line + 1
                    )
                maptyp[key] = value
            # do this last, or <<: before a key will prevent insertion in instances
            # of collections.OrderedDict (as they have no __contains__
            if merge_map:
                maptyp.add_yaml_merge(merge_map)


class StrictYAMLLoader(
            Reader,
            RoundTripScanner,
            RoundTripParser,
            Composer,
            StrictYAMLConstructor,
            VersionedResolver
        ):
    def __init__(self, stream, version=None, preserve_quotes=None):
        Reader.__init__(self, stream)
        RoundTripScanner.__init__(self)
        RoundTripParser.__init__(self)
        Composer.__init__(self)
        StrictYAMLConstructor.__init__(self, preserve_quotes=preserve_quotes)
        VersionedResolver.__init__(self, version)


def load(yaml_string, schema=None):
    """
    Parse the first YAML document in a string
    and produce corresponding python object (dict, list, string).
    """
    if str(type(yaml_string)) not in ("<type 'unicode'>", "<type 'str'>", "<class 'str'>"):
        raise TypeError("StrictYAML can only read a string of valid YAML.")

    document = ruamelyaml.load(yaml_string, Loader=StrictYAMLLoader)

    # Document is single item (string, int, etc.)
    if type(document) not in (CommentedMap, CommentedSeq):
        document = yaml_string

    for token in ruamelyaml.scan(yaml_string):
        if type(token) is ruamelyaml.tokens.TagToken:
            raise exceptions.TagTokenDisallowed(
                document,
                token.start_mark.line + 1,
                token.end_mark.line + 1
            )
        if type(token) is ruamelyaml.tokens.FlowMappingStartToken:
            raise exceptions.FlowMappingDisallowed(
                document,
                token.start_mark.line + 1,
                token.end_mark.line + 1
            )
        if type(token) is ruamelyaml.tokens.AnchorToken:
            raise exceptions.AnchorTokenDisallowed(
                document,
                token.start_mark.line + 1,
                token.end_mark.line + 1
            )

    if schema is None:
        schema = Any()

    return schema(document)
