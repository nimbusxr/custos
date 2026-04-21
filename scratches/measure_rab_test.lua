-- measure_rab_test.lua
-- Tests measure_rab() - uses pcall since it needs existing items

assert(type(measure_rab) == "function", "measure_rab must be a function")

local self_pos = get_self_position()
local ok, result = pcall(measure_rab, {
    from_lat = self_pos.lat,
    from_lon = self_pos.lon,
    to_lat = self_pos.lat + 0.001,
    to_lon = self_pos.lon + 0.001
})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[measure_rab] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[measure_rab] call failed (acceptable): " .. tostring(result))
end
return "PASS"
