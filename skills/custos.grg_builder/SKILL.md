---
group: custos
name: grg_builder
description: Place Gridded Reference Graphics (GRGs) on the map
script_paths:
  - custos.grg_builder/build_grg.lua
  - custos.grg_builder/grg_bounds.lua
tags:
  - grg
  - grid
  - reference
  - area
  - operations
examples:
  - "build a GRG over the objective area"
  - "create a gridded reference graphic"
  - "place a GRG grid"
  - "lay down a reference grid for the compound"
  - "make a GRG centered on this position"
---

# GRG Builder

Places a Gridded Reference Graphic (GRG) on the ATAK map. GRGs divide
a geographic area into a labeled grid for coordinating operations.

Uses ATAK's built-in `CustomGrid` via `GridLinesMapComponent` — no
external plugin required for grid placement.

## Rules
- ALWAYS call `build_grg` to change spacing, size, or position — never assume a previous call is still active. Each call replaces the current grid.
- When the operator asks to adjust an existing GRG (change spacing, resize, move), re-call `build_grg` with the updated parameters.
