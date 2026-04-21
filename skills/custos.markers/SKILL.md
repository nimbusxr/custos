---
group: custos
name: markers
description: Place, find, and delete map markers
script_paths:
  - custos.markers/place_marker.lua
  - custos.markers/find_items.lua
  - custos.markers/delete_markers.lua
  - custos.tactical_picture/get_self_position.lua
  - custos.helpers/calc_destination.lua
tags:
  - markers
  - map
  - navigation
  - position
examples:
  - "place a marker at 38.9 -77.0"
  - "drop a hostile marker"
  - "place a hostile marker 100m north of me"
  - "mark a waypoint 500m at bearing 270 from that contact"
  - "find all friendly markers"
  - "delete the marker called Alpha"
  - "mark this position"
---

# Markers

Tools for placing, finding, deleting, and querying markers and map items on the ATAK map.
Use `place_marker` to create new markers, `find_items` to search for
existing map items by callsign, `delete_markers` to remove markers by
name or within a geographic area, and `get_self_position` to get the
operator's current location.

When the operator asks for a marker relative to a known point (e.g. "100m
north of me", "500m at bearing 270 from Bravo"), call `get_self_position`
(or resolve the reference item) first, then `calc_destination` to project
the new lat/lon, then `place_marker`. Do not compute the offset yourself —
arithmetic on coordinates drifts on small on-device models.
