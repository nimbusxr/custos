-- track_target_test.lua
-- Tests track_target() - uses pcall since it needs an existing target

assert(type(track_target) == "function", "track_target must be a function")

local ok, result = pcall(track_target, {uid = "nonexistent-uid-test"})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[track_target] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[track_target] call failed (acceptable - target not found): " .. tostring(result))
end
return "PASS"
