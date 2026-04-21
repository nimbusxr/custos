---@class DdCoord
---@field lat number decimal degrees latitude
---@field lon number decimal degrees longitude

---@class UtmCoord
---@field zone string UTM zone descriptor (e.g. "33T")
---@field easting number UTM easting in meters
---@field northing number UTM northing in meters

---@class CoordConversions
---@field dd DdCoord decimal degrees (pass-through)
---@field dms string degrees-minutes-seconds formatted string
---@field mgrs string MGRS grid string
---@field utm UtmCoord UTM zone + easting/northing

--- Convert coordinates between formats
-- @tool convert_coords
-- @description Convert coordinates between DD (decimal degrees), DMS, UTM, and MGRS formats. On error returns { status="error", message=... } instead of CoordConversions.
-- @tparam number lat Latitude in decimal degrees
-- @tparam number lon Longitude in decimal degrees
---@return CoordConversions
-- @impact READ_ONLY
function convert_coords(params)
  if not params.lat or not params.lon then
    return { status = "error", message = "lat and lon required" }
  end
  local MGRSPoint = import("com.atakmap.coremap.maps.coords.MGRSPoint")
  local UTMPoint = import("com.atakmap.coremap.maps.coords.UTMPoint")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local pt = GeoPoint(params.lat, params.lon)
  local mgrs = MGRSPoint(params.lat, params.lon)
  local utm = UTMPoint:fromGeoPoint(pt)

  return {
    dd = { lat = params.lat, lon = params.lon },
    dms = tools.call("format_dms", { lat = params.lat, lon = params.lon }).dms,
    mgrs = mgrs:toString(),
    utm = {
      zone = utm:getZoneDescriptor(),
      easting = utm:getEasting(),
      northing = utm:getNorthing(),
    },
  }
end
