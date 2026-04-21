---
group: custos
name: layers
description: Control map layer visibility and manage imagery sources
script_paths:
  - custos.layers/list_layers.lua
  - custos.layers/toggle_layer.lua
tags:
  - layers
  - overlays
  - imagery
  - wms
  - visibility
examples:
  - "toggle the satellite layer"
  - "show me the topo map"
  - "hide the imagery overlay"
  - "list available map layers"
  - "turn on the street map layer"
---

# Layers

Map layer visibility and management.

- `list_layers` — List all map overlay layers with name, type, and visibility status
- `toggle_layer` — Toggle a map layer's visibility on or off
