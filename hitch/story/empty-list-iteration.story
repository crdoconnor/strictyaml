Iterating over empty lists:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import YAML, EmptyList, Map, Seq, Str, as_document, load
      from ensure import Ensure
  variations:
    Direct YAML value:
      steps:
      - Run: |
          Ensure(list(YAML([]))).equals([])

    Loaded document:
      steps:
      - Run: |
          document = load("", EmptyList() | Seq(Str()))
          Ensure(list(document)).equals([])
          Ensure(len(document)).equals(0)
          Ensure(document.data).equals([])
          Ensure(document.as_yaml()).equals("...\n")

    Loaded mapping value:
      steps:
      - Run: |
          document = load("items:", Map({"items": EmptyList() | Seq(Str())}))
          Ensure([item.data for item in document["items"]]).equals([])
          Ensure(document.as_yaml()).equals("items:\n")

    Serialized mapping value:
      steps:
      - Run: |
          document = as_document({"items": []}, Map({"items": EmptyList() | Seq(Str())}))
          Ensure(list(document["items"])).equals([])

    Nonempty sequence:
      steps:
      - Run: |
          document = load("- one\n- two", EmptyList() | Seq(Str()))
          Ensure([item.data for item in document]).equals(["one", "two"])

    Scalar remains noniterable:
      steps:
      - Run:
          code: |
            iter(load("text", Str()))
          raises:
            type: builtins.TypeError
            message: YAML(text) is a scalar value, cannot iterate.
