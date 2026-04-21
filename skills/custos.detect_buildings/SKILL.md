---
group: custos
name: detect_buildings
description: Detect buildings in a map area using on-device vision
script_paths:
  - custos.detect_buildings/detect.lua
  - custos.grg_builder/grg_bounds.lua
tags:
  - detection
  - buildings
  - vision
  - ai
  - imagery
examples:
  - "detect buildings in this area"
  - "find structures near the objective"
  - "run building detection on the current view"
  - "how many buildings are in the GRG"
---

# Building Detection

Detects buildings using the on-device vision model. Places BLD-N markers
at detected locations.

When detecting within a GRG, call `grg_bounds` first to get the exact
bounds, then pass north/south/east/west to `detect_buildings`. Do NOT
compute bounds yourself — always call `grg_bounds` for GRG-scoped detection.
