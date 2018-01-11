---
title: What is wrong with node anchors and references?
---

An example of a snippet of YAML that uses node anchors and references is described on the wikipedia page:

´´´yaml
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
´´´

While the intent of the feature is obvious (it lets you deduplicate code), the effect is to make the markup
more or less unreadable to non-programmers.

The example above could be refactored to be clearly as follows:

´´´yaml
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
´´´


While much more repetitive, the intent of the above is *so much* clearer and easier for non-programmers
to work with, that it more than compensates for the increased repetition.

While it makes little sense to refactor the above snippet to deduplicate repetititve data it may make
sense to refactor the *structure* as it grows larger (and more repetitive). However, there are a number of
ways this could be done without using YAML's nodes and anchors (e.g. splitting the file into two files -
step definitions and step sequences), depending on the nature and quantity of the repetitiveness.
