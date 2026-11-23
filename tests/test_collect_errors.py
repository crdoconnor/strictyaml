import pytest

from strictyaml import (
    Any,
    Bool,
    CommaSeparated,
    FixedSeq,
    Int,
    Map,
    MapCombined,
    MapPattern,
    Optional,
    Seq,
    Str,
    UniqueSeq,
    dirty_load,
    load,
    exceptions,
)
from strictyaml.scalar import ScalarValidator
from strictyaml.validators import Validator


def errors(text, schema=None, **options):
    with pytest.raises(exceptions.YAMLValidationErrors) as caught:
        load(text, schema, collect_errors=True, **options)
    assert isinstance(caught.value.errors, tuple)
    assert str(len(caught.value.errors)) + " YAML errors:" in str(caught.value)
    return caught.value.errors


def test_independent_mapping_errors_and_locations():
    result = errors(
        "first: no\nsecond: bad",
        Map({"first": Int(), "second": Int()}),
        label="settings.yml",
    )
    assert len(result) == 2
    assert all(isinstance(error, exceptions.YAMLValidationError) for error in result)
    assert [error.problem_mark.line for error in result] == [0, 1]
    assert all(error.problem_mark.name == "settings.yml" for error in result)
    assert all("required key" not in str(error) for error in result)


def test_nested_mapping_and_sequence_errors_do_not_stop_siblings():
    schema = Map({"items": Seq(Map({"number": Int(), "flag": Bool()})), "last": Int()})
    result = errors(
        "items:\n- number: no\n  flag: other\n- number: bad\n  flag: huh\nlast: x",
        schema,
    )
    assert len(result) == 5


def test_unexpected_keys_and_missing_required_keys_are_reported():
    result = errors("unknown: x\nother: y", Map({"required": Int()}))
    assert len(result) == 3
    assert "'unknown'" in str(result[0])
    assert "'other'" in str(result[1])
    assert "required key(s) 'required'" in str(result[2])


def test_map_pattern_reports_size_keys_and_values():
    result = errors("one: no\ntwo: bad", MapPattern(Int(), Int(), minimum_keys=3))
    assert len(result) == 5
    assert "minimum" in str(result[0])


def test_map_combined_checks_declared_and_extra_values():
    result = errors(
        "known: bad\nextra: wrong", MapCombined({"known": Int()}, Str(), Int())
    )
    assert len(result) == 2


def test_fixed_sequence_reports_length_and_available_items():
    result = errors("- bad\n- nope\n- extra", FixedSeq([Int(), Int()]))
    assert len(result) == 3
    assert "sequence of 2 elements" in str(result[0])


def test_unique_sequence_reports_duplicates_and_item_errors():
    result = errors("- bad\n- bad\n- wrong", UniqueSeq(Int()))
    assert len(result) == 4
    assert sum("duplicate found" in str(error) for error in result) == 1


def test_unique_sequence_wrong_shapes_do_not_raise_unhashable_type_error():
    result = errors("- key: value\n- other: value\n- bad", UniqueSeq(Int()))
    assert len(result) == 3


def test_comma_separated_values_collect_each_invalid_item():
    result = errors("values: 1, no, 2, bad", Map({"values": CommaSeparated(Int())}))
    assert len(result) == 2


def test_or_discards_speculative_failures_when_any_alternative_succeeds():
    schema = Map({"first": Int() | Str(), "values": CommaSeparated(Int()) | Str()})
    parsed = load("first: nope\nvalues: 1, bad", schema, collect_errors=True)
    assert parsed.data == {"first": "nope", "values": "1, bad"}


def test_or_reports_failed_alternatives_without_duplicates():
    result = errors("bad", Int() | Bool())
    assert len(result) == 2
    assert "integer" in str(result[0])
    assert "boolean" in str(result[1])


def test_nested_or_can_discard_all_inner_failures():
    assert load("bad", (Int() | Bool()) | Str(), collect_errors=True).data == "bad"


def test_compound_or_collects_nested_errors_and_alternative_shape_error():
    result = errors("a: bad\nb: nope", Map({"a": Int(), "b": Int()}) | Str())
    assert len(result) == 3
    assert sum("integer" in str(error) for error in result) == 2
    assert "expecting a str" in str(result[-1])


def test_valid_documents_keep_comments_defaults_and_mutation_validation():
    schema = Map({"number": Int(), Optional("flag", default=True): Bool()})
    text = "# config\nnumber: 2 # count\n"
    parsed = load(text, schema, collect_errors=True)
    ordinary = load(text, schema)
    assert parsed.data == ordinary.data
    assert parsed.as_yaml() == ordinary.as_yaml()
    with pytest.raises(exceptions.YAMLSerializationError):
        parsed["number"] = "bad"
    with pytest.raises(exceptions.YAMLValidationError):
        parsed.revalidate(Map({"number": Bool()}))


def test_valid_collecting_document_does_not_leave_nested_collector_active():
    parsed = load(
        "outer:\n  number: 2",
        Map({"outer": Map({"number": Int()})}),
        collect_errors=True,
    )
    with pytest.raises(exceptions.YAMLValidationError):
        parsed["outer"].revalidate(Map({"number": Bool()}))


@pytest.mark.parametrize("text", ["hello", '"hello"', "# comment\nhello\n", ""])
def test_valid_scalar_behavior_matches_ordinary_load(text):
    assert load(text, collect_errors=True).data == load(text).data


def test_flow_tag_duplicate_and_schema_errors_can_coexist():
    text = "items: [bad, nope]\nvalue: !!str wrong\nvalue: 2\nother: {count: no}"
    schema = Map({"items": Seq(Int()), "value": Int(), "other": Map({"count": Int()})})
    result = errors(text, schema, label="mixed.yml")
    types = [type(error) for error in result]
    assert types.count(exceptions.FlowMappingDisallowed) == 2
    assert types.count(exceptions.TagTokenDisallowed) == 1
    assert types.count(exceptions.DuplicateKeysDisallowed) == 1
    assert types.count(exceptions.YAMLValidationError) == 4
    assert all(error.problem_mark.name == "mixed.yml" for error in result)


def test_each_duplicate_is_reported_and_first_value_is_schema_checked():
    result = errors("number: bad\nnumber: 2\nnumber: 3", Map({"number": Int()}))
    assert (
        sum(isinstance(error, exceptions.DuplicateKeysDisallowed) for error in result)
        == 2
    )
    assert (
        sum(isinstance(error, exceptions.YAMLValidationError) for error in result) == 1
    )


def test_schema_locations_use_original_source_after_duplicate_removal():
    text = "# header\nnumber: 1\nnumber: 2\nbad: nope\n"
    result = errors(text, Map({"number": Int(), "bad": Int()}), label="original.yml")
    invalid = result[-1]
    assert invalid.problem_mark.line == 3
    assert invalid.problem_mark.column == 5
    assert "bad: nope" in str(invalid)
    assert "line 4, column 6" in str(invalid)


def test_flow_children_keep_source_columns_and_unicode_marks():
    text = "雪: [bad, nope]\n"
    result = errors(text, Map({"雪": Seq(Int())}), label="unicode.yml")
    validation = [
        item for item in result if isinstance(item, exceptions.YAMLValidationError)
    ]
    assert [item.problem_mark.line for item in validation] == [0, 0]
    assert [item.problem_mark.column for item in validation] == [4, 9]
    assert all("雪: [bad, nope]" in str(item) for item in validation)


def test_unknown_tags_are_ignored_for_diagnostics_without_tag_construction():
    result = errors(
        "first: !application no\nsecond: !!int bad",
        Map({"first": Int(), "second": Int()}),
    )
    assert (
        sum(isinstance(error, exceptions.TagTokenDisallowed) for error in result) == 2
    )
    assert (
        sum(isinstance(error, exceptions.YAMLValidationError) for error in result) == 2
    )


def test_recursive_and_undefined_aliases_are_never_expanded():
    text = "items: &items\n- *items\n- *undefined\nlast: bad"
    result = errors(text, Map({"items": Seq(Int()), "last": Int()}))
    assert (
        sum(isinstance(error, exceptions.AnchorTokenDisallowed) for error in result)
        == 3
    )
    assert (
        sum(isinstance(error, exceptions.YAMLValidationError) for error in result) == 1
    )
    assert all(str(error) for error in result)


def test_root_alias_has_only_its_parser_error():
    result = errors("*undefined", Int())
    assert len(result) == 1
    assert isinstance(result[0], exceptions.AnchorTokenDisallowed)


def test_reused_anchors_do_not_warn_or_create_shared_nodes():
    result = errors("a: &name bad\nb: &name wrong", Map({"a": Int(), "b": Int()}))
    assert len(result) == 4


def test_inconsistent_mapping_indentation_does_not_hide_schema_errors():
    text = "first:\n  n: bad\nsecond:\n    n: wrong\nthird:\n      n: nope"
    schema = Map({key: Map({"n": Int()}) for key in ["first", "second", "third"]})
    result = errors(text, schema)
    assert (
        sum(
            isinstance(error, exceptions.InconsistentIndentationDisallowed)
            for error in result
        )
        == 2
    )
    assert (
        sum(isinstance(error, exceptions.YAMLValidationError) for error in result) == 3
    )


def test_dirty_load_flow_option_keeps_its_meaning():
    with pytest.raises(exceptions.YAMLValidationErrors) as caught:
        dirty_load(
            "a: [bad, nope]",
            Map({"a": Seq(Int())}),
            allow_flow_style=True,
            collect_errors=True,
        )
    assert len(caught.value.errors) == 2
    assert all(
        isinstance(error, exceptions.YAMLValidationError)
        for error in caught.value.errors
    )


def test_syntax_failure_is_fatal_but_preserves_earlier_restrictions():
    result = errors(
        "a: [1]\nb: [", Map({"a": Seq(Int()), "b": Int()}), label="broken.yml"
    )
    assert (
        sum(isinstance(error, exceptions.FlowMappingDisallowed) for error in result)
        == 2
    )
    assert not isinstance(result[-1], exceptions.StrictYAMLError)
    assert result[-1].problem_mark.name == "broken.yml"


def test_invalid_character_becomes_aggregate_reader_error():
    result = errors("a: \x00")
    assert len(result) == 1
    assert "special characters are not allowed" in str(result[0])


def test_custom_scalar_errors_are_collected():
    class Positive(ScalarValidator):
        def validate_scalar(self, chunk):
            value = Int().validate_scalar(chunk)
            if value <= 0:
                chunk.expecting_but_found("when expecting a positive number")
            return value

    assert len(errors("- -1\n- 0", Seq(Positive()))) == 2


def test_custom_compound_can_use_scopes_for_independent_children():
    class Numbers(Validator):
        def validate(self, chunk):
            for item in chunk.expect_sequence():
                with item.validation_scope():
                    item.process(item.validate(Int()))

    assert len(errors("- bad\n- nope", Numbers())) == 2


def test_programming_errors_are_not_swallowed():
    failure = ValueError("custom validator failed")

    class Broken(ScalarValidator):
        def validate_scalar(self, chunk):
            raise failure

    with pytest.raises(ValueError) as caught:
        load("a: bad\nb: x", Map({"a": Int(), "b": Broken()}), collect_errors=True)
    assert caught.value is failure


def test_fail_fast_mode_keeps_existing_error_types():
    with pytest.raises(exceptions.FlowMappingDisallowed):
        load("a: [1]")
    with pytest.raises(exceptions.TagTokenDisallowed):
        load("a: !!str value")
    with pytest.raises(exceptions.DuplicateKeysDisallowed):
        load("a: x\na: y")
    with pytest.raises(exceptions.YAMLValidationError):
        load("a: bad\nb: no", Map({"a": Int(), "b": Int()}))


def test_collection_state_is_separate_between_loads_and_schema_reuse():
    schema = Map({"a": Int(), "b": Int()})
    assert len(errors("a: x\nb: y", schema)) == 2
    assert load("a: 1\nb: 2", schema, collect_errors=True).data == {"a": 1, "b": 2}
    assert len(errors("a: 1\nb: no", schema)) == 1


def test_wrong_shape_reports_only_reachable_schema_branches():
    schema = Map({"outer": Map({"a": Int(), "b": Int()}), "last": Int()})
    result = errors("outer: value\nlast: bad", schema)
    assert len(result) == 2


def test_untyped_load_still_collects_parser_restrictions():
    result = errors("first: [1, 2]\nsecond: {x: 3}", Any())
    assert len(result) == 2
