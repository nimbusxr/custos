-- list_agents_test.lua
-- Tests that list_agents() returns agents table and count

local result = list_agents()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.agents, "Expected agents to be present, got nil")
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[list_agents] count=" .. result.count)
return "PASS"
