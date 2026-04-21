---
group: custos
name: casualty
description: Generate 9-line MEDEVAC requests, casualty cards, HLZ marking, and emergency beacons
script_paths:
  - custos.casualty/create_9line.lua
  - custos.casualty/mark_hlz.lua
  - custos.casualty/activate_beacon.lua
tags:
  - medevac
  - casualty
  - 9line
  - hlz
  - emergency
examples:
  - "create a 9-line MEDEVAC"
  - "set up a casualty card"
  - "mark an HLZ near my position"
  - "activate the emergency beacon"
  - "I have a casualty"
---

# Casualty

Medical evacuation and casualty management tools.

- `create_9line` — Generate a formatted 9-line MEDEVAC request and place a CASEVAC marker
- `mark_hlz` — Mark a Helicopter Landing Zone with metadata
- `activate_beacon` — Activate an emergency beacon alert (CRITICAL impact)
