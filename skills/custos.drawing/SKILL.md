---
group: custos
name: drawing
description: Draw shapes on the map — polygons, rectangles, circles, and polylines
script_paths:
  - custos.drawing/draw_polygon.lua
  - custos.drawing/draw_rectangle.lua
  - custos.drawing/draw_circle.lua
tags:
  - drawing
  - shapes
  - polygon
  - sector
  - circle
  - rectangle
  - map
examples:
  - "draw a circle around the objective"
  - "create a polygon for the AO"
  - "draw a rectangle over the compound"
  - "outline the landing zone with a shape"
  - "sketch a polyline along the route"
---

# Drawing

Tools for programmatically drawing shapes on the ATAK map. All shapes are added as
native ATAK drawing items (DrawingShape, DrawingRectangle, DrawingCircle) that appear
in the map overlay and can be edited by the operator.

## ATAK Drawing API Reference

Key classes (use these exact FQCNs with `import()`):
- `com.atakmap.android.drawing.mapItems.DrawingShape` — closed polygon
- `com.atakmap.android.drawing.mapItems.DrawingRectangle` — axis-aligned rectangle
- `com.atakmap.android.drawing.mapItems.DrawingCircle` — circle with radius
- `com.atakmap.android.maps.MapView` — get map view instance
- `com.atakmap.android.maps.MapGroup` — container for map items
- `com.atakmap.coremap.maps.coords.GeoPoint` — lat/lon/alt coordinate
- `com.atakmap.coremap.maps.coords.GeoPointMetaData` — GeoPoint wrapper with metadata

Colors are Android ARGB integers. Use `android.graphics.Color` methods:
- `Color:argb(alpha, red, green, blue)` — 0-255 per channel
- `Color:RED`, `Color:BLUE`, `Color:GREEN`, etc. — constants (fully opaque)

All shapes must run on the UI thread: wrap map operations in `runOnUiThread(function() ... end)`.
