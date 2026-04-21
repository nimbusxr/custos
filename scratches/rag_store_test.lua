-- rag_store_test.lua
-- Tests that rag_store() stores text in the vector store

local ok, result = pcall(rag_store, {
  id = "test_id",
  text = "test text",
  namespace = "test",
})
if not ok then
    console.error("SCRIPT BUG: " .. tostring(result))
    return "FAIL (script bug: " .. tostring(result) .. ")"
end
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "stored", "Expected status=stored, got " .. tostring(result.status))
console.log("[rag_store] stored id=" .. tostring(result.id) .. " namespace=" .. tostring(result.namespace))
return "PASS"
