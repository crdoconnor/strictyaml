Validator repr:
  based on: strictyaml
  description: |
    When repr(x) is called on validators it should print an
    executable representation of the object.
  given:
    setup: |
      import strictyaml as sy

  variations:
    Int:
      steps:
      - Run:
          code: |
            assert repr(sy.Map({"a": sy.Int()})) == """Map({'a': Int()})"""

    Optional:
      steps:
      - Run:
          code: |
            assert repr(sy.Map({sy.Optional("a"): sy.Int()})) == """Map({Optional("a"): Int()})"""

    Sequence:
      steps:
      - Run:
          code: |
            assert repr(sy.Seq(sy.Str())) == """Seq(Str())"""

    Empty:
      steps:
      - Run:
          code: |
            assert repr(sy.FixedSeq([sy.EmptyNone(), sy.EmptyDict(), sy.EmptyList()])) == """FixedSeq([EmptyNone(), EmptyDict(), EmptyList()])"""

    UniqueSeq Decimal:
      steps:
      - Run:
          code: |
            assert repr(sy.UniqueSeq(sy.Decimal())) == """UniqueSeq(Decimal())"""

    MapPattern Bool Enum:
      steps:
      - Run:
          code: |
            assert repr(sy.MapPattern(sy.Bool(), sy.Enum(["x", "y"]))) == "MapPattern(Bool(), Enum(['x', 'y']))"

    Seq Datetime Any Or:
      steps:
      - Run:
          code: |
            assert repr(sy.Seq(sy.Datetime() | sy.Any())) == """Seq(Datetime() | Any())"""

    Comma Separated Float:
      steps:
      - Run:
          code: |
            assert repr(sy.Map({"x": sy.CommaSeparated(sy.Float())})) == "Map({'x': CommaSeparated(Float())})"

