---@class SelfPosition
---@field lat number latitude in decimal degrees
---@field lon number longitude in decimal degrees
---@field alt number altitude in meters HAE
---@field callsign string self-marker title
---@field uid string self-marker UID

--- Get the operator's current position
-- @tool get_self_position
-- @description Get the operator's current position from ATAK self-marker. On error returns { status="error", message=... } instead of SelfPosition.
---@return SelfPosition
-- @impact READ_ONLY
function get_self_position()
  local MapView = import("com.atakmap.android.maps.MapView")

  local mapView = MapView:getMapView()
  local selfMarker = mapView:getSelfMarker()

  if not selfMarker then
    return { status = "error", message = "Self marker not available" }
  end

  local point = selfMarker:getPoint()
  return {
    lat = point:getLatitude(),
    lon = point:getLongitude(),
    alt = point:getAltitude(),
    callsign = selfMarker:getTitle(),
    uid = selfMarker:getUID(),
  }
end
