-- hostile_list_test.lua
-- Tests that hostile_list() returns count and hostiles table

local result = hostile_list({})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
assert(type(result.hostiles) == "table", "Expected hostiles to be table, got " .. type(result.hostiles))
console.log("[hostile_list] count=" .. result.count)
return "PASS"
