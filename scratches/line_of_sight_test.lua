-- line_of_sight_test.lua
-- Tests that line_of_sight() returns clear (boolean) and distance_m (number)

local self_pos = get_self_position()
local result = line_of_sight({
    observer_lat = self_pos.lat,
    observer_lon = self_pos.lon,
    observer_height_m = 2,
    target_lat = self_pos.lat + 0.002,
    target_lon = self_pos.lon + 0.002
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.clear) == "boolean", "Expected clear to be boolean, got " .. type(result.clear))
assert(type(result.distance_m) == "number", "Expected distance_m to be number, got " .. type(result.distance_m))
console.log("[line_of_sight] clear=" .. tostring(result.clear) .. " distance_m=" .. result.distance_m)
return "PASS"
