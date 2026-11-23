import pytest

from strictyaml import (
    Any,
    Bool,
    EmptyNone,
    Int,
    Map,
    MapCombined,
    Optional,
    Seq,
    Str,
    as_document,
    load,
)
from strictyaml.exceptions import (
    InvalidValidatorError,
    YAMLSerializationError,
    YAMLValidationError,
)


def pipe_schema():
    return Map(
        {
            "name": Str(),
            Optional("wall"): Int(),
            Optional("diameter", required_unless=["wall"]): Int(),
        }
    )


@pytest.mark.parametrize(
    "fields, expected",
    [
        ("wall: 2", {"wall": 2}),
        ("diameter: 10", {"diameter": 10}),
        ("wall: 2\ndiameter: 10", {"wall": 2, "diameter": 10}),
        ("diameter: 10\nwall: 2", {"diameter": 10, "wall": 2}),
        ("wall: 0", {"wall": 0}),
    ],
)
def test_either_or_both_keys_are_present(fields, expected):
    schema = pipe_schema()
    result = load("name: pipe\n" + fields, schema)
    assert result.data == dict(name="pipe", **expected)
    assert load(as_document(result.data, schema).as_yaml(), schema).data == result.data


def test_missing_alternative_has_located_error():
    with pytest.raises(YAMLValidationError) as error:
        load("name: pipe", pipe_schema(), label="pipes.yml")
    assert "'diameter' is required" in str(error.value)
    assert "'wall'" in str(error.value)
    assert error.value.problem_mark.name == "pipes.yml"
    assert error.value.problem_mark.line == 0


def test_serialization_rejects_missing_alternatives():
    with pytest.raises(YAMLSerializationError, match="diameter.*required.*wall"):
        as_document({"name": "pipe"}, pipe_schema())


@pytest.mark.parametrize("text", ["wall: nope", "wall: 2\ndiameter: nope"])
def test_present_values_still_require_their_declared_type(text):
    with pytest.raises(YAMLValidationError, match="integer"):
        load("name: pipe\n" + text, pipe_schema())


def test_any_listed_alternative_suffices_and_input_is_copied():
    alternatives = ["wall", "radius"]
    condition = Optional("diameter", required_unless=alternatives)
    alternatives.append("unknown")
    schema = Map(
        {
            "name": Str(),
            Optional("wall"): Int(),
            Optional("radius"): Int(),
            condition: Int(),
        }
    )
    for text in ["wall: 0", "radius: 2", "wall: 1\nradius: 3", "diameter: 4"]:
        load("name: pipe\n" + text, schema)
    with pytest.raises(YAMLValidationError, match="wall.*radius"):
        load("name: pipe", schema)


@pytest.mark.parametrize("default_key", ["wall", "diameter"])
def test_defaults_satisfy_conditions_and_round_trip_when_omitted(default_key):
    schema = Map(
        {
            "name": Str(),
            Optional("wall", default=2 if default_key == "wall" else None): Int(),
            Optional(
                "diameter",
                default=10 if default_key == "diameter" else None,
                required_unless=["wall"],
            ): Int(),
        }
    )
    parsed = load("name: pipe", schema)
    assert default_key in parsed.data
    assert parsed.as_yaml() == "name: pipe\n"
    rendered = as_document(parsed.data, schema).as_yaml()
    assert rendered == "name: pipe\n"
    assert load(rendered, schema).data == parsed.data


@pytest.mark.parametrize("default", [False, None])
def test_false_and_explicit_none_defaults_count_as_present(default):
    schema = Map(
        {
            "name": Str(),
            Optional(
                "wall", default=default, drop_if_none=default is not None
            ): EmptyNone()
            | Bool(),
            Optional("diameter", required_unless=["wall"]): Int(),
        }
    )
    assert load("name: pipe", schema).data["wall"] is default


def test_explicit_empty_value_counts_as_present():
    schema = Map(
        {Optional("wall"): Str(), Optional("diameter", required_unless=["wall"]): Int()}
    )
    assert load("wall:", schema).data == {"wall": ""}


def test_revalidation_uses_conditions():
    parsed = load("name: pipe\nwall: 2")
    parsed.revalidate(pipe_schema())
    assert parsed.data == {"name": "pipe", "wall": 2}
    invalid = load("name: pipe")
    with pytest.raises(YAMLValidationError, match="diameter.*required"):
        invalid.revalidate(pipe_schema())


def test_nested_conditions_do_not_use_keys_from_parent_or_siblings():
    schema = Map({"wall": Int(), "pipes": Seq(pipe_schema())})
    valid = "wall: 1\npipes:\n- name: one\n  wall: 2\n- name: two\n  diameter: 3"
    assert load(valid, schema).data["pipes"][1]["diameter"] == 3
    with pytest.raises(YAMLValidationError, match="diameter.*required"):
        load("wall: 1\npipes:\n- name: one\n  wall: 2\n- name: two", schema)


def test_assignment_validates_conditional_nested_mapping_before_modification():
    schema = Map({"pipe": pipe_schema()})
    parsed = load("pipe:\n  name: steel\n  wall: 2", schema)
    before = parsed.as_yaml()
    with pytest.raises(YAMLSerializationError, match="diameter.*required"):
        parsed["pipe"] = {"name": "bad"}
    assert parsed.as_yaml() == before
    parsed["pipe"] = {"name": "good", "diameter": 10}
    assert parsed.data == {"pipe": {"name": "good", "diameter": 10}}


def test_map_combined_checks_conditions_and_allows_extra_keys():
    schema = MapCombined(
        {
            Optional("wall"): Int(),
            Optional("diameter", required_unless=["wall"]): Int(),
        },
        Str(),
        Any(),
    )
    assert load("other: yes\nwall: 2", schema).data == {"other": "yes", "wall": 2}
    with pytest.raises(YAMLValidationError, match="diameter.*required"):
        load("other: yes", schema)
    with pytest.raises(YAMLSerializationError, match="diameter.*required"):
        as_document({"other": "yes"}, schema)


def test_mutual_conditions_require_at_least_one_key():
    schema = Map(
        {
            "name": Str(),
            Optional("wall", required_unless=["diameter"]): Int(),
            Optional("diameter", required_unless=["wall"]): Int(),
        }
    )
    load("name: pipe\nwall: 1", schema)
    load("name: pipe\ndiameter: 2", schema)
    with pytest.raises(YAMLValidationError) as error:
        load("name: pipe", schema)
    assert "'wall' is required" in str(error.value)
    assert "'diameter' is required" in str(error.value)


@pytest.mark.parametrize("alternatives", [[], "wall", b"wall", 1])
def test_condition_requires_nonempty_key_iterable(alternatives):
    with pytest.raises(InvalidValidatorError, match="nonempty iterable"):
        Optional("diameter", required_unless=alternatives)


@pytest.mark.parametrize("alternatives", [["unknown"], ["diameter"], [["wall"]]])
def test_condition_must_reference_other_declared_local_keys(alternatives):
    with pytest.raises(InvalidValidatorError, match="same mapping"):
        Map({Optional("diameter", required_unless=alternatives): Int()})


def test_generator_condition_and_repr():
    condition = Optional("diameter", required_unless=(key for key in ["wall"]))
    assert repr(condition) == "Optional(\"diameter\", required_unless=('wall',))"
    schema = Map({Optional("wall"): Int(), condition: Int()})
    assert load("wall: 1", schema).data == {"wall": 1}


def test_ordinary_optional_and_required_keys_keep_their_behavior():
    schema = Map({"name": Str(), Optional("wall"): Int()})
    assert load("name: pipe", schema).data == {"name": "pipe"}
    assert repr(Optional("wall")) == 'Optional("wall")'
    with pytest.raises(YAMLValidationError, match="required key.*name"):
        load("wall: 2", schema)
