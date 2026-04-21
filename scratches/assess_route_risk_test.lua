-- assess_route_risk_test.lua
-- Tests that assess_route_risk() returns risk_level

local self_pos = get_self_position()
local result = assess_route_risk({
    start_lat = self_pos.lat,
    start_lon = self_pos.lon,
    end_lat = self_pos.lat + 0.01,
    end_lon = self_pos.lon + 0.01
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.risk_level) == "string", "Expected risk_level to be string, got " .. type(result.risk_level))
console.log("[assess_route_risk] risk_level=" .. result.risk_level)
return "PASS"
