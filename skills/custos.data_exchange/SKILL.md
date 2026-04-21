---
group: custos
name: data_exchange
description: Import and export map data in KML, GPX, and GeoJSON formats
script_paths:
  - custos.data_exchange/export_kml.lua
  - custos.data_exchange/import_file.lua
tags:
  - import
  - export
  - kml
  - gpx
  - geojson
  - data
examples:
  - "export the markers as KML"
  - "import this GPX file"
  - "save the route as GeoJSON"
  - "export everything on the map to a file"
---

# Data Exchange

Import and export map data in standard geospatial formats.

- `export_kml` — Export map items to a KML file
- `import_file` — Import a KML, GPX, or GeoJSON file into the map
