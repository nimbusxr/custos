-- get_network_status_test.lua
-- Tests that get_network_status() returns network_available as boolean

local result = get_network_status()
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.network_available) == "boolean", "Expected network_available to be boolean, got " .. type(result.network_available))
console.log("[get_network_status] network_available=" .. tostring(result.network_available))
return "PASS"
