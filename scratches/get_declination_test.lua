-- get_declination_test.lua
-- Tests that get_declination() returns declination_deg as number

local result = get_declination({lat = 41.63, lon = -93.85})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.declination_deg) == "number", "Expected declination_deg to be number, got " .. type(result.declination_deg))
console.log("[get_declination] declination_deg=" .. result.declination_deg)
return "PASS"
