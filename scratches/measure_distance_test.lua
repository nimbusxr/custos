-- measure_distance_test.lua
-- Tests that measure_distance() returns distance_m and bearing_deg

local self_pos = get_self_position()
local result = measure_distance({
    from_lat = self_pos.lat,
    from_lon = self_pos.lon,
    to_lat = self_pos.lat + 0.001,
    to_lon = self_pos.lon + 0.001
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.distance_m) == "number", "Expected distance_m to be number, got " .. type(result.distance_m))
assert(type(result.bearing_deg) == "number", "Expected bearing_deg to be number, got " .. type(result.bearing_deg))
console.log("[measure_distance] distance_m=" .. result.distance_m .. " bearing_deg=" .. result.bearing_deg)
return "PASS"
