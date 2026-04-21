-- list_contacts_test.lua
-- Tests that list_contacts() returns contacts table and count

local result = list_contacts({})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(type(result.contacts) == "table", "Expected contacts to be table, got " .. type(result.contacts))
assert(type(result.count) == "number", "Expected count to be number, got " .. type(result.count))
console.log("[list_contacts] count=" .. result.count)
return "PASS"
