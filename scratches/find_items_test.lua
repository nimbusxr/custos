-- find_items_test.lua
-- Tests that find_items({query=""}) returns count and items

local result = find_items({query = ""})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
assert(type(result.items) == "table", "Expected items to be table, got " .. type(result.items))
console.log("[find_items] count=" .. result.count .. " items_len=" .. #result.items)
return "PASS"
