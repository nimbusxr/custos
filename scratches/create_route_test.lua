-- create_route_test.lua
-- Tests that create_route() creates a route to a nearby offset point

local pos = get_self_position()

-- Offset ~200m north for the end point
local offset = 0.002
local ok, result = pcall(create_route, {
  name = "TEST_ROUTE",
  start_lat = pos.lat,
  start_lon = pos.lon,
  end_lat = pos.lat + offset,
  end_lon = pos.lon + offset,
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[create_route] points=" .. tostring(result.point_count) .. " distance=" .. tostring(result.total_distance_m) .. "m")
return "PASS"
