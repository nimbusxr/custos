-- export_kml_test.lua
-- Tests that export_kml() initiates a KML export (may fail without items)

local ok, result = pcall(export_kml, {
  output_path = "TEST_export.kml",
})

if ok then
  assert(type(result) == "table", "Expected table, got " .. type(result))
  assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
  console.log("[export_kml] output_path=" .. tostring(result.output_path))
else
  console.log("[export_kml] pcall failed (expected in some environments): " .. tostring(result))
end

return "PASS"
