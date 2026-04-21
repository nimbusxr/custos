---
group: custos
name: routes
description: Plan, create, and navigate routes with waypoints and elevation analysis
script_paths:
  - custos.routes/create_route.lua
  - custos.routes/list_routes.lua
  - custos.routes/get_elevation_profile.lua
tags:
  - routes
  - navigation
  - waypoints
  - planning
  - elevation
examples:
  - "plan a route from here to the objective"
  - "create a patrol route with waypoints"
  - "what's the elevation profile of this route"
  - "list saved routes"
  - "build a route from CP1 through the rally point to the OBJ"
---

# Routes

Plan, create, and analyze routes on the ATAK map.

- `create_route` — Create a route with named waypoints between start and end points
- `list_routes` — List all route polylines currently on the map
- `get_elevation_profile` — Sample elevation along a line for route planning and terrain analysis
