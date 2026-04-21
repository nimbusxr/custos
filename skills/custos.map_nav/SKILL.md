---
group: custos
name: map_nav
description: Pan and zoom the map to locations, markers, or coordinates
script_paths:
  - custos.map_nav/focus_map.lua
  - custos.map_nav/zoom_map.lua
  - custos.markers/find_items.lua
  - custos.tactical_picture/get_self_position.lua
tags:
  - map
  - navigation
  - focus
  - pan
  - zoom
  - location
examples:
  - "pan to 38.9 -77.0"
  - "zoom in on the objective"
  - "center the map on my position"
  - "show me the area around waypoint Alpha"
  - "fly to the rally point"
---

# Map Navigation

Pan and zoom the ATAK map.

- To pan to the operator's position: call `get_self_position`, then `focus_map` with the result.
- To pan to a marker: call `find_items` to search, then `focus_map` with the item's coordinates.
- To zoom: call `zoom_map` with a scale value (smaller = more zoomed in). Defaults to street level if no scale is provided.
