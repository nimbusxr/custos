---
group: custos
name: tactical_picture
description: Query the tactical picture — nearby units, self position, item details, and distances
script_paths:
  - custos.tactical_picture/get_picture.lua
  - custos.tactical_picture/get_self_position.lua
  - custos.tactical_picture/find_nearby.lua
  - custos.tactical_picture/get_item_detail.lua
  - custos.tactical_picture/measure_distance.lua
  - custos.tactical_picture/tactical_summary.lua
  - custos.tactical_picture/find_by_type.lua
tags:
  - tactical
  - picture
  - situational awareness
  - blue force
  - tracking
  - position
  - location
  - self
  - distance
  - bearing
  - range
  - detail
  - summary
  - filter
examples:
  - "what's near me"
  - "give me the tactical picture"
  - "where am I"
  - "how far to the checkpoint"
  - "show me all hostile markers"
  - "what's at that position"
---

# Tactical Picture

Provides situational awareness tools for the ATAK map.

- `get_tactical_picture` — Summary of nearby friendly/hostile/unknown units and POIs
- `get_self_position` — Operator's current GPS coordinates
- `find_nearby` — Items within a radius, sorted by distance with bearing
- `get_item_detail` — Deep drill-down on a single item (metadata, speed, team, remarks)
- `measure_distance` — Distance and bearing between two points or items
- `tactical_summary` — Counts by affiliation, dimension, and team without individual items
- `find_by_type` — Filter items by CoT affiliation, dimension, or type prefix
