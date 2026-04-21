-- forget_test.lua
-- Tests that forget() removes a previously remembered fact

-- First remember something
local saved = remember({
  category = "test",
  key = "forget_test_key",
  value = "forget_test_val",
})
assert(type(saved) == "table", "Expected table from remember")
assert(saved.status == "saved", "Expected status=saved, got " .. tostring(saved.status))

-- Then forget it
local result = forget({
  category = "test",
  key = "forget_test_key",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "deleted", "Expected status=deleted, got " .. tostring(result.status))
console.log("[forget] deleted category=" .. tostring(result.category) .. " key=" .. tostring(result.key))

return "PASS"
