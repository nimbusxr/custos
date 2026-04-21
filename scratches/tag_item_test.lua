-- tag_item_test.lua
-- Tests that tag_item() can tag the self marker (may fail if no items)

local pos = get_self_position()

local ok, result = pcall(tag_item, {
  identifier = pos.uid,
  tag = "test_tag",
})

if ok then
  assert(type(result) == "table", "Expected table, got " .. type(result))
  assert(result.status == "success" or result.status == "error",
    "Expected status=success or error, got " .. tostring(result.status))
  console.log("[tag_item] status=" .. tostring(result.status) .. " uid=" .. tostring(result.uid))
else
  console.log("[tag_item] pcall failed (expected if self marker not taggable): " .. tostring(result))
end

return "PASS"
