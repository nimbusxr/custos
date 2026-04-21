-- get_picture_test.lua
-- Tests that get_tactical_picture() returns expected structure

local result = get_tactical_picture({})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.self_position) == "table", "Expected self_position to be table, got " .. type(result.self_position))
assert(type(result.total) == "number", "Expected total to be number, got " .. type(result.total))
assert(type(result.friendly) == "table", "Expected friendly to be table, got " .. type(result.friendly))
assert(type(result.hostile) == "table", "Expected hostile to be table, got " .. type(result.hostile))
console.log("[get_tactical_picture] total=" .. result.total .. " friendly=" .. #result.friendly .. " hostile=" .. #result.hostile)
return "PASS"
