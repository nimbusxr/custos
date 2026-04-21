---
group: custos
name: mil_symbology
description: MIL-STD-2525 symbol lookup, placement, and SIDC decoding
script_paths:
  - custos.mil_symbology/decode_sidc.lua
  - custos.mil_symbology/place_tactical_graphic.lua
tags:
  - symbology
  - milstd
  - "2525"
  - sidc
  - tactical-graphics
examples:
  - "place a hostile infantry symbol"
  - "decode this SIDC"
  - "what's the symbol for a friendly armor unit"
  - "put a 2525 marker for enemy mech infantry at this grid"
  - "show me what SHGPUCII------- means"
---

# MIL-STD-2525 Symbology

Military symbol identification code (SIDC) decoding and tactical graphic placement.

- `decode_sidc` — Decode a 15 or 20 character SIDC into human-readable fields
- `place_tactical_graphic` — Place a MIL-STD-2525 tactical marker on the map
