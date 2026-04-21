-- manage_automation_test.lua
-- Tests that manage_automation() with action=list returns a table

local result = manage_automation({ action = "list" })
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.automations, "Expected automations to be present, got nil")
console.log("[manage_automation] count=" .. tostring(result.count))
return "PASS"
