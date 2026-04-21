-- create_geofence_test.lua
-- Tests that create_geofence() creates a geofence with 500m radius

local pos = get_self_position()

local ok, result = pcall(create_geofence, {
  lat = pos.lat,
  lon = pos.lon,
  radius_m = 500,
  name = "TEST_GF",
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "created", "Expected status=created, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[create_geofence] uid=" .. result.uid)
return "PASS"
