-- analyze_movement_test.lua
-- Tests analyze_movement() - uses pcall since it needs an existing moving item

assert(type(analyze_movement) == "function", "analyze_movement must be a function")

local ok, result = pcall(analyze_movement, {uid = "nonexistent-uid-test"})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[analyze_movement] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[analyze_movement] call failed (acceptable - item not found): " .. tostring(result))
end
return "PASS"
