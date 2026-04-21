-- get_illumination_test.lua
-- Tests that get_illumination() returns location and optional sun/moon data

local result = get_illumination({})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.location, "Expected location to be present")
console.log("[get_illumination] location lat=" .. tostring(result.location.lat))
-- sun/moon may be nil if ATAK's SunPosition class is unavailable in this context
if result.sun then
    console.log("[get_illumination] sun azimuth=" .. tostring(result.sun.azimuth_deg))
end
if result.moon then
    console.log("[get_illumination] moon phase=" .. tostring(result.moon.phase))
end
return "PASS"
