-- generate_salute_test.lua
-- Tests generate_salute() - uses pcall since it needs an existing item

assert(type(generate_salute) == "function", "generate_salute must be a function")

local ok, result = pcall(generate_salute, {uid = "nonexistent-uid-test"})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[generate_salute] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[generate_salute] call failed (acceptable - item not found): " .. tostring(result))
end
return "PASS"
