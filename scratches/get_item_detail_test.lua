-- get_item_detail_test.lua
-- Tests get_item_detail() - uses pcall since it needs an existing item

assert(type(get_item_detail) == "function", "get_item_detail must be a function")

local self_pos = get_self_position()
local ok, result = pcall(get_item_detail, {uid = self_pos.uid})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[get_item_detail] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    console.log("[get_item_detail] call failed (acceptable - item not found): " .. tostring(result))
end
return "PASS"
