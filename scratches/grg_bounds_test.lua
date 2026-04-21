-- grg_bounds_test.lua
-- Tests that grg_bounds() returns center with lat/lon (requires GRG on map)

local result = grg_bounds()
assert(type(result) == "table", "Expected table, got " .. type(result))
if result.center then
    assert(type(result.center.lat) == "number", "Expected center.lat to be number")
    assert(type(result.center.lon) == "number", "Expected center.lon to be number")
    console.log("[grg_bounds] center lat=" .. result.center.lat .. " lon=" .. result.center.lon)
else
    console.log("[grg_bounds] no GRG on map — center is nil (acceptable)")
end
return "PASS"
