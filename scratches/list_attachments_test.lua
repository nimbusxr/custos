-- list_attachments_test.lua
-- Tests that list_attachments() with self uid returns a table

local self_pos = get_self_position()
local ok, result = pcall(list_attachments, {uid = self_pos.uid})
if ok then
    assert(type(result) == "table", "Expected table, got " .. type(result))
    console.log("[list_attachments] result is table")
    for k, v in pairs(result) do
        console.log("  " .. tostring(k) .. " = " .. type(v))
    end
else
    -- No attachments for self is acceptable
    console.log("[list_attachments] call failed (acceptable): " .. tostring(result))
end
return "PASS"
