---
group: custos
name: bullseye
description: Range/bearing from reference points — standard targeting protocol
script_paths:
  - custos.bullseye/create_bullseye.lua
  - custos.bullseye/bearing_from_bullseye.lua
tags:
  - bullseye
  - targeting
  - range
  - bearing
examples:
  - "what's the bullseye to that target"
  - "give me bearing and range from reference point Alpha"
  - "create a bullseye at the intersection"
  - "set up a reference point for targeting"
---

# Bullseye

Standard targeting protocol: create reference points and compute range/bearing from them.

- `create_bullseye` — Create a bullseye reference point marker
- `bearing_from_bullseye` — Get range and bearing from a bullseye to a target
