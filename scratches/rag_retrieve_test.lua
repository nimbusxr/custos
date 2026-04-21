-- rag_retrieve_test.lua
-- Tests that rag_retrieve() with query="test" returns results table

local result = rag_retrieve({query = "test"})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.results) == "table", "Expected results to be table, got " .. type(result.results))
console.log("[rag_retrieve] results_len=" .. #result.results)
return "PASS"
