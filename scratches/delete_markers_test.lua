-- delete_markers_test.lua
-- Calls delete_markers with a query that should match nothing

local result = delete_markers({query = "TEST_NONEXISTENT_xyz_99999"})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.deleted == 0, "Expected deleted==0, got " .. tostring(result.deleted))
console.log("[delete_markers] deleted=" .. result.deleted)
return "PASS (safe call — CRITICAL)"
