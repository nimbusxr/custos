--- Create a geofence from a circle
-- @tool create_geofence
-- @description Create a circular geofence that triggers alerts when contacts enter or exit the area. The geofence is drawn as a circle on the map with monitoring enabled.
-- @tparam number lat Center latitude
-- @tparam number lon Center longitude
-- @tparam number radius_m Radius in meters
-- @tparam string name Geofence name
-- @tparam string trigger Trigger on: entry, exit, or both (default: entry)
-- @impact PROCEDURAL
function create_geofence(params)
  if not params.lat or not params.lon or not params.radius_m or not params.name then
    return { status = "error", message = "lat, lon, radius_m, name required" }
  end

  local DrawingCircle = import("com.atakmap.android.drawing.mapItems.DrawingCircle")
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local GeoPointMetaData = import("com.atakmap.coremap.maps.coords.GeoPointMetaData")
  local UUID = import("java.util.UUID")
  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local Intent = import("android.content.Intent")

  local uid = UUID:randomUUID():toString()
  local center = GeoPoint(params.lat, params.lon)
  local trigger = params.trigger or "entry"

  -- Create circle shape and attach geofence monitoring on the UI thread
  runOnUiThread(function()
    local mapView = MapView:getMapView()
    local circle = DrawingCircle(mapView, uid)
    circle:setCenterPoint(GeoPointMetaData:wrap(center))
    circle:setRadius(params.radius_m)
    circle:setTitle(params.name)
    circle:setMetaString("callsign", params.name)
    circle:setMetaBoolean("geofence", true)
    circle:setMetaString("geofenceTrigger", trigger)
    mapView:getRootGroup():addItem(circle)

    -- Attach geofence monitoring behavior via intent
    local intent = Intent("com.atakmap.android.geofence.MONITOR")
    intent:putExtra("uid", uid)
    intent:putExtra("trigger", trigger)
    AtakBroadcast:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "created",
    uid = uid,
    name = params.name,
    center = { lat = params.lat, lon = params.lon },
    radius_m = params.radius_m,
    trigger = trigger,
  }
end
