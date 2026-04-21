-- danger_close_check_test.lua
-- Tests that danger_close_check() returns danger_close as boolean

local self_pos = get_self_position()
local ok, result = pcall(danger_close_check, {lat = self_pos.lat, lon = self_pos.lon})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.danger_close) == "boolean", "Expected danger_close to be boolean, got " .. type(result.danger_close))
console.log("[danger_close_check] danger_close=" .. tostring(result.danger_close))
return "PASS"
