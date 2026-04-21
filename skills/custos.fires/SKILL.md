---
group: custos
name: fires
description: Call for fire, hostile tracking, danger close calculations, and munitions data
script_paths:
  - custos.fires/hostile_list.lua
  - custos.fires/danger_close_check.lua
tags:
  - fires
  - cff
  - hostile
  - danger-close
  - munitions
examples:
  - "danger close check for my position"
  - "list hostile targets for fires"
  - "am I within danger close range"
  - "show me all enemy markers with range and bearing"
  - "check if friendlies are too close to the target"
---

# Fires

Fire support tools for tracking hostiles and computing danger close.

- `hostile_list` — List all hostile markers with distance and bearing from self
- `danger_close_check` — Check for friendly forces within danger close range of a target
