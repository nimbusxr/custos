-- remember_test.lua
-- Tests that remember() saves a fact and forget() cleans it up

local result = remember({
  category = "test",
  key = "test_key",
  value = "test_val",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "saved", "Expected status=saved, got " .. tostring(result.status))
console.log("[remember] saved category=" .. tostring(result.category) .. " key=" .. tostring(result.key))

-- Cleanup
local cleanup = forget({ category = "test", key = "test_key" })
assert(type(cleanup) == "table", "Cleanup must return a table")
assert(cleanup.status == "deleted", "Expected cleanup status=deleted, got " .. tostring(cleanup.status))
console.log("[remember] cleaned up")

return "PASS"
