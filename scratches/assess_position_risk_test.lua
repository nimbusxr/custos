-- assess_position_risk_test.lua
-- Tests that assess_position_risk() returns risk_level

local self_pos = get_self_position()
local result = assess_position_risk({lat = self_pos.lat, lon = self_pos.lon})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.risk_level) == "string", "Expected risk_level to be string, got " .. type(result.risk_level))
console.log("[assess_position_risk] risk_level=" .. result.risk_level)
return "PASS"
