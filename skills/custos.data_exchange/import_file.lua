--- Import a KML, GPX, or GeoJSON file into the map
-- @tool import_file
-- @description Import a geospatial data file (KML, GPX, GeoJSON) into ATAK. The file must exist on the device filesystem.
-- @tparam string file_path Absolute path to the file on device (e.g. /sdcard/atak/import/data.kml)
-- @impact PROCEDURAL
function import_file(params)
  local Intent = import("android.content.Intent")
  local File = import("java.io.File")
  local MapView = import("com.atakmap.android.maps.MapView")

  local filePath = params.file_path
  if not filePath or filePath == "" then
    return { status = "error", message = "file_path is required" }
  end

  local file = File(filePath)
  if not file:exists() then
    return { status = "error", message = "File not found: " .. filePath }
  end

  -- Determine MIME type from extension
  local ext = filePath:lower():match("%.(%w+)$") or ""
  local mimeMap = {
    kml = "application/vnd.google-earth.kml+xml",
    kmz = "application/vnd.google-earth.kmz",
    gpx = "application/gpx+xml",
    geojson = "application/geo+json",
    json = "application/geo+json",
  }
  local mimeType = mimeMap[ext] or "application/octet-stream"

  -- Broadcast ATAK import intent
  local intent = Intent()
  intent:setAction("com.atakmap.android.importexport.IMPORT")
  intent:putExtra("filepath", filePath)
  intent:putExtra("importInPlace", true)

  runOnUiThread(function()
    local iom = import("com.atakmap.android.ipc.AtakBroadcast")
    iom:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "success",
    file_path = filePath,
    file_type = ext,
    mime_type = mimeType,
    message = "Import initiated for " .. filePath,
  }
end
