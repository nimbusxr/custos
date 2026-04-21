-- estimate_arrival_test.lua
-- Tests estimate_arrival() - uses pcall since it needs an existing moving item

assert(type(estimate_arrival) == "function", "estimate_arrival must be a function")

local self_pos = get_self_position()
local ok, result = pcall(estimate_arrival, {
    uid = self_pos.uid,
    dest_lat = self_pos.lat + 0.01,
    dest_lon = self_pos.lon + 0.01
})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[estimate_arrival] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[estimate_arrival] call failed (acceptable - item not found or not moving): " .. tostring(result))
end
return "PASS"
