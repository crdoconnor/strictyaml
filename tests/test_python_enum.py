import enum

import pytest

from strictyaml import Enum, Int, Map, MapPattern, Optional, Seq, Str, as_document, load
from strictyaml.exceptions import (
    InvalidValidatorError,
    YAMLSerializationError,
    YAMLValidationError,
)


class Color(enum.Enum):
    RED = 1
    CRIMSON = 1
    BLUE = 2


@pytest.mark.parametrize("name", ["RED", "CRIMSON", "BLUE"])
def test_names_parse_to_enum_members(name):
    result = load("color: " + name, Map({"color": Enum(Color)}))
    assert result["color"].data is Color[name]
    assert result.data == {"color": Color[name]}


def test_input_spelling_and_comment_are_retained_until_assignment():
    result = load("color: CRIMSON # a color\n", Map({"color": Enum(Color)}))
    assert result.as_yaml() == "color: CRIMSON # a color\n"
    result["color"] = Color.BLUE
    assert result.data == {"color": Color.BLUE}
    assert result.as_yaml() == "color: BLUE    # a color\n"


def test_serialization_uses_canonical_name():
    schema = Map({"color": Enum(Color)})
    result = as_document({"color": Color.CRIMSON}, schema)
    assert result.as_yaml() == "color: RED\n"
    assert result.data == {"color": Color.RED}


@pytest.mark.parametrize("text", ["red", "1", "", "GREEN"])
def test_unknown_names_raise_located_validation_error(text):
    with pytest.raises(YAMLValidationError) as error:
        load("color: " + text, Map({"color": Enum(Color)}), label="palette.yml")
    assert "RED, CRIMSON, BLUE" in str(error.value)
    assert "palette.yml" in str(error.value)


@pytest.mark.parametrize("value", ["RED", 1, None, True])
def test_serialization_rejects_raw_values(value):
    with pytest.raises(YAMLSerializationError, match="named member of Color"):
        as_document(value, Enum(Color))


def test_int_and_string_enums_do_not_accept_equal_raw_or_foreign_values():
    class Number(enum.IntEnum):
        ONE = 1

    class OtherNumber(enum.IntEnum):
        ONE = 1

    class Label(str, enum.Enum):
        ONE = "one"

    for kind, member, invalid in [
        (Number, Number.ONE, 1),
        (Number, Number.ONE, OtherNumber.ONE),
        (Label, Label.ONE, "one"),
    ]:
        assert load("ONE", Enum(kind)).data is member
        assert as_document(member, Enum(kind)).as_yaml() == "ONE\n...\n"
        with pytest.raises(YAMLSerializationError):
            as_document(invalid, Enum(kind))


def test_sequence_defaults_and_union_use_typed_values():
    schema = Map(
        {
            "colors": Seq(Enum(Color)),
            Optional("default", default=Color.RED): Enum(Color),
            "count": Enum(Color) | Int(),
        }
    )
    result = load("colors:\n- RED\n- BLUE\ncount: 3\n", schema)
    assert result.data == {
        "colors": [Color.RED, Color.BLUE],
        "default": Color.RED,
        "count": 3,
    }
    assert load(result.as_yaml(), schema).data == result.data


def test_enum_can_validate_mapping_keys():
    schema = MapPattern(Enum(Color), Int())
    result = load("RED: 1\nBLUE: 2\n", schema)
    assert result.data == {Color.RED: 1, Color.BLUE: 2}
    assert as_document(result.data, schema).as_yaml() == "RED: 1\nBLUE: 2\n"


def test_named_flag_members_round_trip_but_unnamed_combinations_do_not():
    class Access(enum.Flag):
        READ = 1
        WRITE = 2
        EXECUTE = 4
        ALL = 7

    assert load("ALL", Enum(Access)).data is Access.ALL
    assert "ALL" in as_document(Access.ALL, Enum(Access)).as_yaml()
    with pytest.raises(YAMLSerializationError):
        as_document(Access.READ | Access.WRITE, Enum(Access))
    with pytest.raises(YAMLSerializationError):
        as_document(Access(0), Enum(Access))


def test_empty_python_enum_rejects_all_names():
    class Empty(enum.Enum):
        pass

    with pytest.raises(YAMLValidationError):
        load("ANY", Enum(Empty))


def test_item_validator_is_only_for_value_enumerations():
    with pytest.raises(InvalidValidatorError, match="item_validator"):
        Enum(Color, Str())
    schema = Enum([1, 2], Int())
    assert load("1", schema).data == 1
    assert "2" in as_document(2, schema).as_yaml()


def test_repr_identifies_enum_class():
    assert repr(Enum(Color)) == "Enum({0!r})".format(Color)
