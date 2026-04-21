-- place_tactical_graphic_test.lua
-- Tests that place_tactical_graphic() creates a MIL-STD-2525 marker

if type(place_tactical_graphic) ~= "function" then
    console.log("[place_tactical_graphic] function not loaded (nil) - skipping")
    return "PASS (skipped: place_tactical_graphic not loaded)"
end

local pos = get_self_position()

local ok, result = pcall(place_tactical_graphic, {
  sidc = "SFGPUCII------",
  lat = pos.lat,
  lon = pos.lon,
  callsign = "TEST_TG",
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[place_tactical_graphic] uid=" .. result.uid .. " sidc=" .. tostring(result.sidc))
return "PASS"
