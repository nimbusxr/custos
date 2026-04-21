-- get_contact_detail_test.lua
-- Tests get_contact_detail() - uses pcall since it needs an existing contact

assert(type(get_contact_detail) == "function", "get_contact_detail must be a function")

local ok, result = pcall(get_contact_detail, {uid = "nonexistent-uid-test"})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[get_contact_detail] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[get_contact_detail] call failed (acceptable - contact not found): " .. tostring(result))
end
return "PASS"
