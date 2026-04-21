--- Get magnetic declination at a location
-- @tool get_declination
-- @description Get the magnetic declination (variation between true north and magnetic north) at a given location
-- @tparam number lat Latitude
-- @tparam number lon Longitude
-- @impact READ_ONLY
function get_declination(params)
  if not params.lat or not params.lon then
    return { status = "error", message = "lat and lon required" }
  end
  local GeomagneticField = import("com.atakmap.coremap.maps.conversion.GeomagneticField")
  local field = GeomagneticField(params.lat, params.lon, 0, import("java.lang.System"):currentTimeMillis())
  return {
    declination_deg = field:getDeclination(),
    inclination_deg = field:getInclination(),
    field_strength_nt = field:getFieldStrength(),
  }
end
