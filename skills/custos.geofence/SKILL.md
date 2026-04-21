---
group: custos
name: geofence
description: Create and monitor geofences for perimeter security and proximity alerts
script_paths:
  - custos.geofence/create_geofence.lua
  - custos.geofence/list_geofences.lua
tags:
  - geofence
  - perimeter
  - security
  - alerts
  - proximity
  - monitoring
examples:
  - "create a geofence around the base"
  - "set up a perimeter alert"
  - "list active geofences"
  - "alert me if anyone enters this area"
  - "set a 500 meter proximity fence on the HLZ"
---

# Geofence

Create and manage geofences for perimeter security and proximity alerting.

- `create_geofence` — Create a circular geofence that triggers alerts on entry or exit
- `list_geofences` — List all active geofences with their status and dimensions
