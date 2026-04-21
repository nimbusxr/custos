---
group: custos
name: helpers
description: Shared utility functions for bearing, color, CoT, coordinate, and item resolution operations
script_paths:
  - custos.helpers/calc_bearing.lua
  - custos.helpers/compass_dir.lua
  - custos.helpers/format_mgrs.lua
  - custos.helpers/format_dms.lua
  - custos.helpers/parse_color.lua
  - custos.helpers/parse_cot_type.lua
  - custos.helpers/build_cot_event.lua
  - custos.helpers/dispatch_cot_event.lua
  - custos.helpers/resolve_item.lua
tags: [helpers, utilities, shared]
examples:
  - "calculate bearing between two points"
  - "what compass direction is 45 degrees"
  - "convert coordinates to MGRS"
  - "format coordinates as DMS"
  - "parse hex color to ARGB"
  - "build a CoT event"
  - "find a map item by callsign"
---
