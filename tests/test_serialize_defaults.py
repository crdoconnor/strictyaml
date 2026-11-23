import pytest

from strictyaml import (
    Any,
    Bool,
    EmptyNone,
    Int,
    Map,
    MapCombined,
    MapPattern,
    Optional,
    Seq,
    Str,
    as_document,
    load,
)


@pytest.mark.parametrize(
    "default,validator",
    [
        (5, Int()),
        (False, Bool()),
        (0, Int()),
        ("上海", Str()),
        ("", Str()),
        (None, EmptyNone()),
    ],
)
def test_effective_values_round_trip_without_editing_original(default, validator):
    schema = Map(
        {
            "a": Int(),
            Optional("b", default=default, drop_if_none=default is not None): validator,
        }
    )
    document = load("# configuration\na: 01  # keep this\n", schema)
    before = document.as_yaml()
    data = document.data
    rendered = document.as_yaml(include_defaults=True)
    assert rendered.startswith(before)
    assert "b:" in rendered
    assert load(rendered, schema).data == data
    assert document.as_yaml() == before
    assert document.as_yaml(include_defaults=False) == before
    assert document.data == data
    assert document.as_yaml(include_defaults=True) == rendered


def test_nested_defaults_in_maps_sequences_and_defaulted_containers():
    item = Map({"name": Str(), Optional("enabled", default=True): Bool()})
    schema = Map(
        {"items": Seq(item), Optional("fallback", default={"name": "backup"}): item}
    )
    document = load("items:\n- name: primary  # selected\n", schema)
    before = document.as_yaml()
    rendered = document.as_yaml(include_defaults=True)
    assert "# selected" in rendered
    assert rendered.count("enabled: yes") == 2
    assert load(rendered, schema).data == document.data
    assert document.as_yaml() == before
    assert "enabled: yes" in document["items"][0].as_yaml(include_defaults=True)


def test_existing_values_equal_to_defaults_retain_spelling_and_comments():
    schema = Map({"a": Int(), Optional("b", default=True): Bool()})
    document = load("a: 1\nb: true  # explicitly requested\n", schema)
    assert document.as_yaml(include_defaults=True) == document.as_yaml()


def test_serialized_python_values_can_include_defaults():
    schema = Map({"a": Int(), Optional("b", default=False): Bool()})
    document = as_document({"a": 1, "b": False}, schema)
    assert document.as_yaml() == "a: 1\n"
    assert document.as_yaml(include_defaults=True) == "a: 1\nb: no\n"


def test_revalidated_subtrees_and_union_selected_values():
    schema = Map({"a": Int(), Optional("b", default=5): Int()})
    document = load("section:\n  a: 1\n", Map({"section": Any()}))
    document["section"].revalidate(Str() | schema)
    rendered = document.as_yaml(include_defaults=True)
    assert "  b: 5\n" in rendered
    assert document.as_yaml() == "section:\n  a: 1\n"


def test_mapping_patterns_and_combined_mappings():
    schema = MapCombined(
        {"known": Int()},
        Str(),
        MapPattern(Str(), Map({"a": Int(), Optional("b", default=5): Int()})),
    )
    document = load("known: 1\nextra:\n  child:\n    a: 2\n", schema)
    rendered = document.as_yaml(include_defaults=True)
    assert "    b: 5\n" in rendered
    assert load(rendered, schema).data == document.data


def test_normalized_keys_keep_original_spelling():
    class LowerCase(Str):
        def validate_scalar(self, chunk):
            return super(LowerCase, self).validate_scalar(chunk).lower()

    schema = Map(
        {"a": Int(), Optional("b", default=5): Int()}, key_validator=LowerCase()
    )
    document = load("A: 01  # original key\n", schema)
    assert document.as_yaml(include_defaults=True) == "A: 01  # original key\nb: 5\n"


def test_marked_up_copy_is_detached_and_missing_optionals_stay_absent():
    schema = Map({"a": Int(), Optional("b", default=5): Int(), Optional("c"): Str()})
    document = load("a: 1\n", schema)
    expanded = document.as_marked_up(include_defaults=True)
    expanded["a"] = "99"
    expanded["b"] = "0"
    assert document.as_yaml() == "a: 1\n"
    assert document.data == {"a": 1, "b": 5}
    assert "c:" not in document.as_yaml(include_defaults=True)


def test_scalar_and_sequence_without_defaults_are_unchanged():
    for source, schema in [("hello\n", Str()), ("- a\n- b\n", Seq(Str()))]:
        document = load(source, schema)
        assert document.as_yaml(include_defaults=True) == document.as_yaml()


def test_export_reflects_later_edits_without_mutating_schema_defaults():
    fallback = {"name": "backup"}
    child = Map({"name": Str(), Optional("enabled", default=True): Bool()})
    schema = Map({"a": Int(), Optional("fallback", default=fallback): child})
    document = load("a: 1\n", schema)
    document.as_yaml(include_defaults=True)
    document["a"] = 2
    expanded = document.as_yaml(include_defaults=True)
    assert load(expanded, schema).data == document.data
    assert expanded.startswith("a: 2\n")
    assert fallback == {"name": "backup"}
    assert "fallback:" not in document.as_yaml()
