--- Export map items to a KML file
-- @tool export_kml
-- @description Export map items to a KML file. Broadcasts an ATAK export intent to generate the file.
-- @tparam string output_path Output filename (placed under /sdcard/atak/export/) (default: export.kml)
-- @impact PROCEDURAL
function export_kml(params)
  local Intent = import("android.content.Intent")
  local File = import("java.io.File")
  local MapView = import("com.atakmap.android.maps.MapView")

  local filename = params.output_path or "export.kml"
  -- Ensure .kml extension
  if not filename:find("%.kml$") then
    filename = filename .. ".kml"
  end

  local exportDir = File("/sdcard/atak/export")
  if not exportDir:exists() then
    exportDir:mkdirs()
  end

  local outputFile = File(exportDir, filename)
  local outputPath = outputFile:getAbsolutePath()

  -- Use ATAK's export intent
  local intent = Intent()
  intent:setAction("com.atakmap.android.importexport.EXPORT")
  intent:putExtra("exportPath", outputPath)
  intent:putExtra("exportType", "KML")

  runOnUiThread(function()
    local iom = import("com.atakmap.android.ipc.AtakBroadcast")
    iom:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "success",
    output_path = outputPath,
    message = "KML export initiated to " .. outputPath,
  }
end
