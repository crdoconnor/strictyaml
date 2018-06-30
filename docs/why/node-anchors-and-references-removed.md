---
title: What is wrong with node anchors and references?
---

An example of a snippet of YAML that uses node anchors and references is described on the [YAML wikipedia page](https://en.wikipedia.org/wiki/YAML#Advanced_components):

```yaml
# sequencer protocols for Laser eye surgery
---
- step:  &id001                  # defines anchor label &id001
    instrument:      Lasik 2000
    pulseEnergy:     5.4
    pulseDuration:   12
    repetition:      1000
    spotSize:        1mm

- step: &id002
    instrument:      Lasik 2000
    pulseEnergy:     5.0
    pulseDuration:   10
    repetition:      500
    spotSize:        2mm
- step: *id001                   # refers to the first step (with anchor &id001)
- step: *id002                   # refers to the second step
- step: 
    <<: *id001
    spotSize: 2mm                # redefines just this key, refers rest from &id001
- step: *id002
```

While the intent of the feature is obvious (it lets you deduplicate code), the effect is to make the markup
more or less unreadable to non-programmers.

The example above could be refactored to be clearly as follows:

```yaml
# sequencer protocols for Laser eye surgery
---
- step:
    instrument:      Lasik 2000
    pulseEnergy:     5.4
    pulseDuration:   12
    repetition:      1000
    spotSize:        1mm
- step:
    instrument:      Lasik 2000
    pulseEnergy:     5.0
    pulseDuration:   10
    repetition:      500
    spotSize:        2mm
- step:
    instrument:      Lasik 2000
    pulseEnergy:     5.4
    pulseDuration:   12
    repetition:      1000
    spotSize:        1mm
- step:
    instrument:      Lasik 2000
    pulseEnergy:     5.0
    pulseDuration:   10
    repetition:      500
    spotSize:        2mm
- step:
    instrument:      Lasik 2000
    pulseEnergy:     5.4
    pulseDuration:   12
    repetition:      1000
    spotSize:        2mm
- step:
    instrument:      Lasik 2000
    pulseEnergy:     5.0
    pulseDuration:   10
    repetition:      500
    spotSize:        2mm
```

The intent of this document is a lot clearer than the version above - *especially* for
non-programmers. However, it comes at a cost of increased repetition.

Between the node/anchor version and this I would prefer this.

However, it is still repetitive and ideally it should be non-repetitive and still
clear. This can be done by refactoring the *structure* of the document and changing
the way the application interprets it.

For example, instead of representing using the schema above, a schema that separates
step definitions from actual steps could be used. For example:

```yaml
step definitions:
  large:
    instrument:      Lasik 2000
    pulseEnergy:     5.4
    pulseDuration:   12
    repetition:      1000
    spotSize:        1mm
  medium:
    instrument:      Lasik 2000
    pulseEnergy:     5.0
    pulseDuration:   10
    repetition:      500
    spotSize:        2mm
steps:
- step: large
- step: medium
- step: large
- step: medium
- step:
    from: large
    except:
      spotSize: 2mm
- step: large
```

The above document has an entirely different and slightly complex schema but it
fundamentally represents the same data as the node/anchor version above, in a clearer
manner, without duplication.
