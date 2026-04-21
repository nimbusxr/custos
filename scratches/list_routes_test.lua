-- list_routes_test.lua
-- Tests that list_routes() returns routes table and count

local result = list_routes()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.routes) == "table", "Expected routes to be table, got " .. type(result.routes))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[list_routes] count=" .. result.count)
return "PASS"
