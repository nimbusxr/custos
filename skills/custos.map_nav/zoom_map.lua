--- Zoom the map to a scale level
-- @tool zoom_map
-- @description Zoom the map to a scale level. Smaller value = more zoomed in.
-- @tparam number scale Ground sample distance in meters/pixel. 0.05=building, 0.35=street, 2=neighborhood, 20=city, 200=region, 2000=continent (default: 0.35)
-- @tparam number lat Latitude to center on while zooming
-- @tparam number lon Longitude to center on while zooming
-- @impact READ_ONLY
function zoom_map(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local mapView = MapView:getMapView()

  -- Convert GSD (meters/pixel) to ATAK map scale
  local scale = params.scale or 0.35
  local mapScale = mapView:mapResolutionAsMapScale(scale)

  runOnUiThread(function()
    local controller = mapView:getMapController()
    if params.lat and params.lon then
      local point = GeoPoint(params.lat, params.lon)
      controller:panZoomTo(point, mapScale, true)
    else
      controller:zoomTo(mapScale, true)
    end
  end)

  return { status = "success", scale = scale, mapScale = mapScale }
end
