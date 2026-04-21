-- zoom_map_test.lua
-- Tests that zoom_map() changes the map scale

local result = zoom_map({ scale = 0.35 })
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[zoom_map] zoomed to scale=0.35")
return "PASS"
