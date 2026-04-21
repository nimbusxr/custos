-- create_bullseye_test.lua
-- Tests that create_bullseye() creates a bullseye reference point

local pos = get_self_position()

local result = create_bullseye({
  lat = pos.lat,
  lon = pos.lon,
  name = "TEST_BE",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
assert(type(result.uid) == "string", "Expected uid to be string, got " .. type(result.uid))
console.log("[create_bullseye] uid=" .. result.uid)
return "PASS"
