import pytest

import strictyaml as yaml


def test_mapping_sequence_and_scalar_documents():
    source = 'a: 1\n---\n- yes\n- no\n---\n"quoted"\n'
    assert [doc.data for doc in yaml.load_all(source)] == [
        {"a": "1"},
        ["yes", "no"],
        "quoted",
    ]


@pytest.mark.parametrize("source", ["", "# comments only\n", " \n\n"])
def test_empty_stream_has_no_documents(source):
    assert list(yaml.load_all(source)) == []


def test_explicit_empty_documents_and_markers():
    assert [doc.data for doc in yaml.load_all("---\n---\nx\n...\n---\n")] == [
        "",
        "x",
        "",
    ]


def test_block_scalars_are_parsed_without_splitting_on_marker_text():
    source = "--- >\n  Mark McGwire's\n  year was crippled.\n--- |\n  ---\n  ...\n"
    assert [doc.data for doc in yaml.load_all(source)] == [
        "Mark McGwire's year was crippled.\n",
        "---\n...\n",
    ]


def test_schema_applies_to_each_document():
    schema = yaml.Map({"count": yaml.Int()})
    assert [doc.data for doc in yaml.load_all("count: 1\n---\ncount: 2\n", schema)] == [
        {"count": 1},
        {"count": 2},
    ]


def test_validation_error_uses_global_source_marks_and_label():
    source = "# first\ncount: 1\n\n---\n# second\n\ncount: invalid\n"
    with pytest.raises(yaml.YAMLValidationError) as raised:
        list(yaml.load_all(source, yaml.Map({"count": yaml.Int()}), label="batch.yaml"))
    error = raised.value
    assert error.context_mark.line == 6
    assert error.problem_mark.line == 6
    assert error.problem_mark.name == "batch.yaml"
    assert "count: invalid" in str(error)
    assert "line 7" in str(error)


def test_nested_and_scalar_validation_locations():
    source = "- 1\n---\n- 2\n- bad\n"
    with pytest.raises(yaml.YAMLValidationError) as raised:
        list(yaml.load_all(source, yaml.Seq(yaml.Int())))
    assert raised.value.context_mark.line == 3
    with pytest.raises(yaml.YAMLValidationError) as raised:
        list(yaml.load_all("1\n--- bad\n", yaml.Int()))
    assert raised.value.problem_mark.line == 1


def test_revalidation_keeps_global_locations():
    documents = list(yaml.load_all("count: 1\n---\ncount: bad\n", label="batch.yaml"))
    with pytest.raises(yaml.YAMLValidationError) as raised:
        documents[1].revalidate(yaml.Map({"count": yaml.Int()}))
    assert raised.value.problem_mark.line == 2
    assert raised.value.problem_mark.name == "batch.yaml"


def test_line_accessors_use_the_original_stream():
    first, second = yaml.load_all("count: 1\n---\n# next\ncount: 2\n")
    assert first.start_line == 1
    assert second["count"].start_line == 4
    assert second["count"].end_line == 4
    assert second["count"].lines() == "count: 2"
    assert second["count"].lines_before(1) == "# next"


@pytest.mark.parametrize(
    "text, exception",
    [
        ("x: 1\nx: 2\n", yaml.DuplicateKeysDisallowed),
        ("x: &anchor text\n", yaml.AnchorTokenDisallowed),
        ("x: !!str text\n", yaml.TagTokenDisallowed),
        ("x: [1, 2]\n", yaml.FlowMappingDisallowed),
    ],
)
def test_restrictions_apply_to_later_documents(text, exception):
    with pytest.raises(exception) as raised:
        list(yaml.load_all("x: first\n---\n" + text, label="stream.yaml"))
    assert raised.value.problem_mark.line >= 2
    assert raised.value.problem_mark.name == "stream.yaml"


def test_dirty_load_all_allows_flow_only_when_requested():
    source = "{x: 1}\n---\n[x, y]\n"
    assert [doc.data for doc in yaml.dirty_load_all(source, allow_flow_style=True)] == [
        {"x": "1"},
        ["x", "y"],
    ]
    with pytest.raises(yaml.FlowMappingDisallowed):
        list(yaml.dirty_load_all(source))


def test_comments_and_edits_stay_with_their_document():
    first, second = yaml.load_all("# first\nx: 1\n---\n# second\nx: 2\n")
    second["x"] = "changed"
    assert first.data == {"x": "1"}
    assert second.data == {"x": "changed"}
    assert "# second" in second.as_yaml()
    assert "# first" not in second.as_yaml()
    assert "changed" in second["x"].lines()


def test_documents_are_yielded_before_later_validation_errors():
    documents = yaml.load_all("1\n---\nwrong\n", yaml.Int())
    assert next(documents).data == 1
    with pytest.raises(yaml.YAMLValidationError):
        next(documents)


def test_generator_close_disposes_the_parser(monkeypatch):
    disposed = []
    original = yaml.parser.StrictYAMLLoader.dispose

    def dispose(loader):
        disposed.append(True)
        original(loader)

    monkeypatch.setattr(yaml.parser.StrictYAMLLoader, "dispose", dispose)
    documents = yaml.load_all("1\n---\n2\n")
    next(documents)
    documents.close()
    assert disposed == [True]


def test_single_document_api_still_rejects_multiple_documents():
    with pytest.raises(yaml.YAMLError):
        yaml.load("x: 1\n---\nx: 2\n")


def test_load_all_requires_text():
    with pytest.raises(TypeError, match="only read a string"):
        list(yaml.load_all(None))
