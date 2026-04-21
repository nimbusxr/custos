---
group: custos
name: terrain
description: Elevation queries, line-of-sight, viewshed, and slope analysis
script_paths:
  - custos.terrain/get_elevation.lua
  - custos.terrain/line_of_sight.lua
  - custos.terrain/elevation_profile.lua
tags:
  - terrain
  - elevation
  - line-of-sight
  - viewshed
  - slope
  - analysis
examples:
  - "what's the elevation at this point"
  - "can I see the target from this position"
  - "check line of sight between OP and objective"
  - "is there terrain blocking our view of the bridge"
---

# Terrain

Terrain analysis tools for elevation queries, line-of-sight checks, and elevation profiling.

- `get_elevation` — Get terrain elevation at a single point
- `line_of_sight` — Check if terrain obstructs line of sight between two positions
- `elevation_profile` — Sample elevation along a line with gain/loss statistics
