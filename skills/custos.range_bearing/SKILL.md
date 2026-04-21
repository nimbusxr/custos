---
group: custos
name: range_bearing
description: Range and bearing lines and circles for measurement
script_paths:
  - custos.range_bearing/measure_rab.lua
  - custos.range_bearing/create_range_circle.lua
tags:
  - range
  - bearing
  - measurement
  - distance
examples:
  - "draw a range ring around the OP"
  - "measure the distance and bearing"
  - "create a range circle at 500 meters"
  - "how far and what direction from Alpha to Bravo"
  - "put a 1km ring around the checkpoint"
---

# Range & Bearing

Measurement tools for range, bearing, and distance visualization.

- `measure_rab` — Measure range and bearing between two points or map items
- `create_range_circle` — Create a visible range circle on the map
