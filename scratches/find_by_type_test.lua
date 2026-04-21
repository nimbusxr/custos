-- find_by_type_test.lua
-- Tests that find_by_type() with no filter returns expected structure

local ok, result = pcall(find_by_type, {})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.filter) == "string" or type(result.filter) == "nil", "Expected filter to be string or nil, got " .. type(result.filter))
-- items may be nil if no items matched (empty result is valid)
if result.items then
    assert(type(result.items) == "table", "Expected items to be table, got " .. type(result.items))
end
console.log("[find_by_type] filter=" .. tostring(result.filter) .. " count=" .. tostring(result.count))
return "PASS"
