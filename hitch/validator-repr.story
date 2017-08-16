Validator repr:
  based on: strictyaml
  description: |
    When repr(x) is called on validators it should print an
    executable representation of the object.
  preconditions:
    setup: import strictyaml as sy

Validator repr int:
  based on: Validator repr
  preconditions:
    code: |
      repr(sy.Map({"a": sy.Int()}))
  scenario:
    - Should be equal to: |
        """Map({"a": Int()})"""

Validator repr optional:
  based on: Validator repr
  preconditions:
    code: |
      repr(sy.Map({sy.Optional("a"): sy.Int()}))
  scenario:
    - Should be equal to: |
        """Map({Optional("a"): Int()})"""

Validator repr seq:
  based on: Validator repr
  preconditions:
    code: repr(sy.Seq(sy.Str()))
  scenario:
    - Should be equal to: str("Seq(Str())")
        
Validator repr empty:
  based on: Validator repr
  preconditions:
    code: repr(sy.FixedSeq([sy.EmptyNone(), sy.EmptyDict(), sy.EmptyList()]))
  scenario:
    - Should be equal to: str("FixedSeq([EmptyNone(), EmptyDict(), EmptyList()])")

Validator repr uniqueseq decimal:
  based on: Validator repr
  preconditions:
    code: repr(sy.UniqueSeq(sy.Decimal()))
  scenario:
    - Should be equal to: str("UniqueSeq(Decimal())")
    
Validator repr mappattern bool enum:
  based on: Validator repr
  preconditions:
    code: repr(sy.MapPattern(sy.Bool(), sy.Enum(["x", "y"])))
  scenario:
    - Should be equal to: str("MapPattern(Bool(), Enum(['x', 'y']))")

Validator repr seq datetime any or:
  based on: Validator repr
  preconditions:
    code: repr(sy.Seq(sy.Datetime() | sy.Any()))
  scenario:
    - Should be equal to: str("Seq(Datetime() | Any())")

Validator repr comma separated float:
  based on: Validator repr
  preconditions:
    code: |
      repr(sy.Map({"x": sy.CommaSeparated(sy.Float())}))
  scenario:
    - Should be equal to: |
        str('Map({"x": CommaSeparated(Float())})')
