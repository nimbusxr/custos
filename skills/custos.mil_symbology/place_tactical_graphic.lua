--- Place a MIL-STD-2525 tactical marker on the map
-- @tool place_tactical_graphic
-- @description Place a tactical marker using a MIL-STD-2525 SIDC. Maps the SIDC affiliation to a CoT type and creates the marker with the full SIDC in metadata.
-- @tparam string sidc The SIDC string (15 characters)
-- @tparam number lat Marker latitude
-- @tparam number lon Marker longitude
-- @tparam string callsign Marker callsign/label (default: Tactical)
-- @impact PROCEDURAL
function place_tactical_graphic(params)
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")
  local Bundle = import("android.os.Bundle")

  local sidc = params.sidc
  local lat = params.lat
  local lon = params.lon
  local callsign = params.callsign or "Tactical"

  if not sidc or sidc == "" then
    return { status = "error", message = "sidc is required" }
  end
  if not lat or not lon then
    return { status = "error", message = "lat and lon are required" }
  end

  -- Pad SIDC
  while #sidc < 15 do
    sidc = sidc .. "-"
  end

  -- Map SIDC affiliation (position 2) to CoT affiliation
  local affChar = sidc:sub(2, 2)
  local cotAff = "u" -- default unknown
  if affChar == "F" or affChar == "A" or affChar == "D" or affChar == "M" then
    cotAff = "f" -- friendly
  elseif affChar == "H" or affChar == "S" or affChar == "J" or affChar == "K" then
    cotAff = "h" -- hostile
  elseif affChar == "N" or affChar == "L" then
    cotAff = "n" -- neutral
  end

  -- Map SIDC dimension (position 3) to CoT dimension
  local dimChar = sidc:sub(3, 3)
  local cotDim = "G" -- default ground
  local dimMap = { A = "A", P = "P", S = "S", U = "U", G = "G", F = "G", X = "G" }
  cotDim = dimMap[dimChar] or "G"

  local cotType = "a-" .. cotAff .. "-" .. cotDim

  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local stale = CoordinatedTime(now:getMilliseconds() + 600000)

  local event = CotEvent()
  event:setUID(uid)
  event:setType(cotType)
  event:setHow(CotEvent.HOW_MACHINE_GENERATED)
  event:setPoint(CotPoint(lat, lon, 0, 0, 0))
  event:setTime(now)
  event:setStart(now)
  event:setStale(stale)

  local detail = CotDetail()

  local contact = CotDetail("contact")
  contact:setAttribute("callsign", callsign)
  detail:addChild(contact)

  -- Store the full SIDC in metadata for symbology rendering
  local sid = CotDetail("sid")
  sid:setAttribute("s2525", sidc)
  detail:addChild(sid)

  local remarks = CotDetail("remarks")
  remarks:setInnerText("SIDC: " .. sidc)
  detail:addChild(remarks)

  event:setDetail(detail)

  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)

  return {
    status = "success",
    uid = uid,
    callsign = callsign,
    sidc = sidc,
    cot_type = cotType,
    lat = lat,
    lon = lon,
  }
end
