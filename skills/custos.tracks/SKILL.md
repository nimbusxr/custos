---
group: custos
name: tracks
description: Query historical movement tracks and breadcrumbs
script_paths:
  - custos.tracks/get_track_history.lua
tags:
  - tracks
  - breadcrumbs
  - history
  - movement
examples:
  - "show track history for Alpha"
  - "where has that vehicle been"
  - "pull up breadcrumbs for the patrol"
  - "what's the movement trail on that contact"
---

# Tracks

Historical movement track and breadcrumb query tools.

- `get_track_history` — Get breadcrumb track history for a contact with positions, timestamps, and speed
