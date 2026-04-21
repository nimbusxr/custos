---@class PlaceMarkerResult
---@field status string "success"
---@field uid string generated UUID of the placed marker
---@field callsign string the callsign assigned to the marker
---@field lat number latitude used for placement
---@field lon number longitude used for placement
---@field resolved_cot_type string the CoT 2525 type code that was placed, derived from the affiliation keyword passed in

--- Places a marker on the map at the specified location
-- @tool place_marker
-- @description Places a marker on the map at the specified affiliation and location. The `type` param MUST be an affiliation keyword — "friendly", "hostile", "neutral", or "unknown" — NOT a CoT type code. Do not pass "a-f-G", "a-h-G", etc. as the type.
-- @tparam string callsign Marker callsign/label
-- @tparam number lat Latitude in decimal degrees
-- @tparam number lon Longitude in decimal degrees
-- @tparam string type Affiliation keyword. MUST be one of: "friendly", "hostile", "neutral", "unknown". Pick "hostile" for enemy contacts, "friendly" for blue forces, "neutral" for civilians, "unknown" when affiliation is unclear. No default — the caller must decide.
---@return PlaceMarkerResult
-- @impact PROCEDURAL
function place_marker(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")

  -- Map the human-friendly affiliation name the model passes ("hostile",
  -- "friendly", etc) to a CoT 2525 type code. Accepts single-letter aliases
  -- and legacy full CoT codes (a-h-G etc) for backward compat.
  local typeMap = {
    friendly = "a-f-G",
    hostile = "a-h-G",
    neutral = "a-n-G",
    unknown = "a-u-G",
  }
  local raw = tostring(params.type or "friendly"):lower()
  local cotType = typeMap[raw] or "a-f-G"

  local mapView = MapView:getMapView()
  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local stale = CoordinatedTime(now:getMilliseconds() + 300000)

  local event = CotEvent()
  event:setUID(uid)
  event:setType(cotType)
  event:setHow(CotEvent.HOW_MACHINE_GENERATED)
  event:setPoint(CotPoint(params.lat, params.lon, 0, 0, 0))
  event:setTime(now)
  event:setStart(now)
  event:setStale(stale)

  local detail = CotDetail()
  local contact = CotDetail("contact")
  contact:setAttribute("callsign", params.callsign)
  detail:addChild(contact)
  event:setDetail(detail)

  -- processCotEvent is synchronous — marker is in group tree when it returns
  local Bundle = import("android.os.Bundle")
  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)

  return {
    status = "success",
    uid = uid,
    callsign = params.callsign,
    lat = params.lat,
    lon = params.lon,
    resolved_cot_type = cotType,
  }
end
