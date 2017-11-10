Validator repr:
  based on: strictyaml
  description: |
    When repr(x) is called on validators it should print an
    executable representation of the object.
  given:
    setup: |
      from ensure import Ensure
      import strictyaml as sy

  variations:
    Int:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.Map({"a": sy.Int()}))).equals("""Map({'a': Int()})""")

    Optional:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.Map({sy.Optional("a"): sy.Int()}))).equals("""Map({Optional("a"): Int()})""")

    Sequence:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.Seq(sy.Str()))).equals("""Seq(Str())""")

    Empty:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.FixedSeq([sy.EmptyNone(), sy.EmptyDict(), sy.EmptyList()]))).equals(
                """FixedSeq([EmptyNone(), EmptyDict(), EmptyList()])"""
            )

    UniqueSeq Decimal:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.UniqueSeq(sy.Decimal()))).equals("""UniqueSeq(Decimal())""")

    MapPattern Bool Enum:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.MapPattern(sy.Bool(), sy.Enum(["x", "y"])))).equals("MapPattern(Bool(), Enum(['x', 'y']))")

    Seq Datetime Any Or:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.Seq(sy.Datetime() | sy.Any()))).equals("""Seq(Datetime() | Any())""")

    Comma Separated Float:
      steps:
      - Run:
          code: |
            Ensure(repr(sy.Map({"x": sy.CommaSeparated(sy.Float())}))).equals("Map({'x': CommaSeparated(Float())})")

