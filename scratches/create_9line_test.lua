-- create_9line_test.lua
-- Tests that create_9line() creates a 9-line MEDEVAC request marker

local pos = get_self_position()

local ok, result = pcall(create_9line, {
  lat = pos.lat,
  lon = pos.lon,
  callsign = "TEST_CAS",
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[create_9line] uid=" .. result.uid .. " callsign=" .. tostring(result.callsign))
return "PASS"
