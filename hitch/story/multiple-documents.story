Multiple documents:
  docs: howto/multiple-documents
  based on: strictyaml
  description: |
    Use `load_all()` to iterate over all documents in a YAML string. The same
    schema is applied to each document. `dirty_load_all()` additionally accepts
    `allow_flow_style=True`, like `dirty_load()`.

    Parsing and validation happen as the iterator advances. An empty or
    comment-only stream contains no documents; an explicit empty document is
    validated as an empty string. Document markers inside scalar text are not
    separators. Scalar documents are decoded as YAML scalars, so their data
    excludes quotes, comments and document markers.

    Validation errors and line accessors refer to the original stream, including
    earlier documents. Each returned object can be revalidated or serialized
    independently. After editing a document, line accessors refer to its updated
    serialized contents rather than stale original locations.
  given:
    setup: |
      from strictyaml import load_all, dirty_load_all, Map, Int, Str, YAMLValidationError
  variations:
    Read and validate every document:
      steps:
      - Run: |
          schema = Map({"count": Int()})
          documents = list(load_all("count: 1\n---\ncount: 2\n", schema))
          assert [document.data for document in documents] == [{"count": 1}, {"count": 2}]

    Explicit empty documents and scalar marker lines:
      steps:
      - Run: |
          source = "---\n--- >\n  first\n  second\n--- |\n  ---\n"
          assert [document.data for document in load_all(source, Str())] == ["", "first second\n", "---\n"]
          assert list(load_all("# no documents\n")) == []

    Global error locations:
      steps:
      - Run: |
          documents = load_all("count: 1\n---\n# second\ncount: wrong\n", Map({"count": Int()}), label="batch.yaml")
          assert next(documents).data == {"count": 1}
          try:
              next(documents)
          except YAMLValidationError as error:
              assert error.problem_mark.name == "batch.yaml"
              assert error.problem_mark.line == 3
              assert "count: wrong" in str(error)
          else:
              raise AssertionError("The second document must be validated")

    Flow style is opt in:
      steps:
      - Run: |
          documents = dirty_load_all("[a, b]\n---\n{x: y}\n", allow_flow_style=True)
          assert [document.data for document in documents] == [["a", "b"], {"x": "y"}]
