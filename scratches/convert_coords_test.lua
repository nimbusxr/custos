-- convert_coords_test.lua
-- Tests that convert_coords() returns dd, dms, mgrs, utm for known coordinates

local ok, result = pcall(convert_coords, {lat = 41.63, lon = -93.85})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.dd) == "table" or type(result.dd) == "string", "Expected dd, got " .. type(result.dd))
assert(type(result.dms) == "table" or type(result.dms) == "string", "Expected dms, got " .. type(result.dms))
assert(type(result.mgrs) == "table" or type(result.mgrs) == "string", "Expected mgrs, got " .. type(result.mgrs))
assert(type(result.utm) == "table" or type(result.utm) == "string", "Expected utm, got " .. type(result.utm))
console.log("[convert_coords] dd=" .. tostring(result.dd) .. " mgrs=" .. tostring(result.mgrs))
return "PASS"
