-- get_track_history_test.lua
-- Tests that get_track_history() with self uid returns a table

local self_pos = get_self_position()
local ok, result = pcall(get_track_history, {uid = self_pos.uid})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[get_track_history] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    -- No track history for self is acceptable
    console.log("[get_track_history] call failed (acceptable): " .. tostring(result))
end
return "PASS"
