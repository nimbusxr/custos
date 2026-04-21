---
group: custos
name: geocoding
description: Convert between street addresses and coordinates
script_paths:
  - custos.geocoding/geocode.lua
tags:
  - geocoding
  - address
  - location
  - search
examples:
  - "what's the address at these coordinates"
  - "geocode 1600 Pennsylvania Ave"
  - "find the coordinates for this location"
  - "convert this address to lat lon"
  - "where is 123 Main Street on the map"
---

# Geocoding

Address-to-coordinate conversion.

- `geocode` — Convert a street address to lat/lon coordinates using ATAK's GeocodeManager
