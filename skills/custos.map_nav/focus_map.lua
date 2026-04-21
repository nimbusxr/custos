--- Pan the map to center on a location
-- @tool focus_map
-- @description Pan the map to center on a location without changing zoom level
-- @tparam number lat Latitude in decimal degrees
-- @tparam number lon Longitude in decimal degrees
-- @impact READ_ONLY
function focus_map(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local mapView = MapView:getMapView()
  local point = GeoPoint(params.lat, params.lon)

  runOnUiThread(function()
    mapView:getMapController():panTo(point, true)
  end)

  return { status = "success", lat = params.lat, lon = params.lon }
end
