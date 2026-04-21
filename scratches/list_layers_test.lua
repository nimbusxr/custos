-- list_layers_test.lua
-- Tests that list_layers() returns layers table and count

local result = list_layers()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.layers) == "table", "Expected layers to be table, got " .. type(result.layers))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[list_layers] count=" .. result.count)
return "PASS"
