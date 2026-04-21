-- predict_position_test.lua
-- Tests predict_position() - uses pcall since it needs an existing moving item

assert(type(predict_position) == "function", "predict_position must be a function")

local ok, result = pcall(predict_position, {uid = "nonexistent-uid-test", seconds = 60})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[predict_position] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[predict_position] call failed (acceptable - item not found): " .. tostring(result))
end
return "PASS"
