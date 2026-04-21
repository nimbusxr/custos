--- Place a GRG grid on the map
-- @tool build_grg
-- @description Place a Gridded Reference Graphic (GRG) grid on the map centered on a location
-- @tparam number lat Center latitude in decimal degrees
-- @tparam number lon Center longitude in decimal degrees
-- @tparam integer rows Number of grid rows (default: 10)
-- @tparam integer cols Number of grid columns (default: 10)
-- @tparam number spacing Grid cell spacing in meters (default: 100)
-- @impact PROCEDURAL
function build_grg(params)
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local GridLines = import("com.atakmap.android.gridlines.GridLinesMapComponent")
  local MapView = import("com.atakmap.android.maps.MapView")
  local PreferenceManager = import("android.preference.PreferenceManager")
  local Color = import("android.graphics.Color")

  local rows = params.rows or 10
  local cols = params.cols or 10
  local spacing = params.spacing or 100

  -- Open the GRG Builder toolbar
  local Intent = import("android.content.Intent")
  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local intent = Intent("com.atakmap.android.grg.GRG_BUILDER")
  AtakBroadcast:getInstance():sendBroadcast(intent)

  local grid = GridLines:getCustomGrid()
  if not grid then
    return { status = "error", message = "CustomGrid not available" }
  end

  -- Write spacing to SharedPreferences
  local prefs = PreferenceManager:getDefaultSharedPreferences(MapView:getMapView():getContext())
  prefs:edit():putFloat("grg_grid_spacing", spacing):apply()

  local center = GeoPoint(params.lat, params.lon)
  local placed = runOnUiThread(function()
    -- Clear existing grid before placing new one (avoids GL vertex buffer crash)
    grid:setVisible(false)
    grid:setSpacing(spacing)
    grid:setColor(Color.WHITE)
    local p = grid:place(center, cols, rows)
    grid:setVisible(true)
    return p
  end)

  if not placed then
    return { status = "error", message = "Failed to place grid" }
  end

  return {
    status = "success",
    center = { lat = params.lat, lon = params.lon },
    rows = rows,
    cols = cols,
    spacing = spacing,
  }
end
