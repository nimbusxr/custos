--- Create a route between two or more points
-- @tool create_route
-- @description Create a route on the map with named waypoints. Provide at least start and end points. Intermediate waypoints can be added as a JSON array.
-- @tparam string name Route name/callsign
-- @tparam number start_lat Start latitude
-- @tparam number start_lon Start longitude
-- @tparam number end_lat End latitude
-- @tparam number end_lon End longitude
-- @tparam string waypoints JSON array of intermediate waypoints [{lat,lon,name}]
-- @tparam string color Route color hex (ARGB) (default: #FF00FF00)
-- @impact PROCEDURAL
function create_route(params)
  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local Intent = import("android.content.Intent")
  local MapView = import("com.atakmap.android.maps.MapView")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")
  local UUID = import("java.util.UUID")

  if not params.name or not params.start_lat or not params.start_lon or not params.end_lat or not params.end_lon then
    return { status = "error", message = "name, start_lat, start_lon, end_lat, end_lon required" }
  end

  -- Build ordered list of route points
  local points = {}
  table.insert(points, {
    lat = tonumber(params.start_lat),
    lon = tonumber(params.start_lon),
    name = "SP",
  })

  -- Parse intermediate waypoints if provided
  if params.waypoints then
    local ok, wps = pcall(function()
      local JSONArray = import("org.json.JSONArray")
      local arr = JSONArray(params.waypoints)
      local list = {}
      for i = 0, arr:length() - 1 do
        local wp = arr:getJSONObject(i)
        table.insert(list, {
          lat = wp:getDouble("lat"),
          lon = wp:getDouble("lon"),
          name = wp:optString("name", "WP" .. (i + 1)),
        })
      end
      return list
    end)
    if ok and wps then
      for _, wp in ipairs(wps) do
        table.insert(points, wp)
      end
    end
  end

  table.insert(points, {
    lat = tonumber(params.end_lat),
    lon = tonumber(params.end_lon),
    name = "RP",
  })

  -- Place waypoint markers for each point and collect UIDs
  local uids = {}
  for i, pt in ipairs(points) do
    local cotResult = tools.call("build_cot_event", {
      lat = pt.lat,
      lon = pt.lon,
      callsign = params.name .. " " .. pt.name,
      type = "b-m-p-w", -- waypoint type
    })
    local event = cotResult.event
    local uid = cotResult.uid
    tools.call("dispatch_cot_event", { event = event })
    table.insert(uids, uid)
  end

  -- Calculate total distance along the route
  local totalDist = 0
  for i = 2, #points do
    local prev = GeoPoint(points[i - 1].lat, points[i - 1].lon)
    local curr = GeoPoint(points[i].lat, points[i].lon)
    totalDist = totalDist + prev:distanceTo(curr)
  end

  return {
    status = "success",
    name = params.name,
    point_count = #points,
    total_distance_m = math.floor(totalDist),
    points = points,
    waypoint_uids = uids,
  }
end
