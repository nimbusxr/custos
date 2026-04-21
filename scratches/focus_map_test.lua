-- focus_map_test.lua
-- Tests that focus_map() pans the map to a location

local pos = get_self_position()
assert(type(pos) == "table", "get_self_position must return a table")
assert(type(pos.lat) == "number", "Expected lat to be number")
assert(type(pos.lon) == "number", "Expected lon to be number")

local result = focus_map({ lat = pos.lat, lon = pos.lon })
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[focus_map] panned to lat=" .. pos.lat .. " lon=" .. pos.lon)
return "PASS"
