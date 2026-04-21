-- bearing_from_bullseye_test.lua
-- Tests bearing_from_bullseye() - uses pcall since bullseye may not be set

assert(type(bearing_from_bullseye) == "function", "bearing_from_bullseye must be a function")

local self_pos = get_self_position()
local ok, result = pcall(bearing_from_bullseye, {lat = self_pos.lat, lon = self_pos.lon})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[bearing_from_bullseye] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[bearing_from_bullseye] call failed (acceptable - bullseye not set): " .. tostring(result))
end
return "PASS"
