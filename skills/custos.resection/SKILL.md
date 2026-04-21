---
group: custos
name: resection
description: Estimate position from bearings to known landmarks — GPS-denied navigation
script_paths:
  - custos.resection/estimate_position.lua
tags:
  - resection
  - gps-denied
  - navigation
  - bearing
examples:
  - "estimate my position from these bearings"
  - "do a resection with landmarks"
  - "GPS is down, triangulate my location"
  - "I have bearings to three known points, where am I"
---

# Resection

GPS-denied position estimation from bearings to known landmarks.

- `estimate_position` — Estimate position by intersecting bearing lines from known landmarks
