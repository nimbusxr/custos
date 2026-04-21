-- search_by_tag_test.lua
-- Tests that search_by_tag() with tag="test" returns items and count

local result = search_by_tag({tag = "test"})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.items) == "table", "Expected items to be table, got " .. type(result.items))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[search_by_tag] count=" .. result.count)
return "PASS"
