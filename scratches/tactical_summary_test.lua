-- tactical_summary_test.lua
-- Tests that tactical_summary() returns scope, total, by_affiliation

local result = tactical_summary({})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.scope) == "string", "Expected scope to be string, got " .. type(result.scope))
assert(type(result.total) == "number", "Expected total to be number, got " .. type(result.total))
assert(type(result.by_affiliation) == "table", "Expected by_affiliation to be table, got " .. type(result.by_affiliation))
console.log("[tactical_summary] scope=" .. result.scope .. " total=" .. result.total)
return "PASS"
