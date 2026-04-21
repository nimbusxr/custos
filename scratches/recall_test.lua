-- recall_test.lua
-- Tests that recall() with query="test" returns facts table and count

local result = recall({query = "test"})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.facts) == "table", "Expected facts to be table, got " .. type(result.facts))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[recall] count=" .. result.count)
return "PASS"
