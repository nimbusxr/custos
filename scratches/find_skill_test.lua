-- find_skill_test.lua
-- Tests that find_skill() with query="map" returns results table

local result = find_skill({query = "map"})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.results) == "table", "Expected results to be table, got " .. type(result.results))
console.log("[find_skill] results_len=" .. #result.results)
return "PASS"
