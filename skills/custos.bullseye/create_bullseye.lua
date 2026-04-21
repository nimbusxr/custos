--- Create a bullseye reference point
-- @tool create_bullseye
-- @description Create a bullseye reference point marker at the specified location. Used as a common reference for range/bearing calls.
-- @tparam number lat Bullseye latitude
-- @tparam number lon Bullseye longitude
-- @tparam string name Bullseye name/label
-- @impact PROCEDURAL
function create_bullseye(params)
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")
  local Bundle = import("android.os.Bundle")

  local lat = params.lat
  local lon = params.lon
  local name = params.name or "BULLSEYE"

  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  -- Bullseye reference points are long-lived
  local stale = CoordinatedTime(now:getMilliseconds() + 86400000) -- 24 hours

  -- b-m-p-c = battle management, mission, point, control
  local event = CotEvent()
  event:setUID(uid)
  event:setType("b-m-p-c")
  event:setHow(CotEvent.HOW_MACHINE_GENERATED)
  event:setPoint(CotPoint(lat, lon, 0, 0, 0))
  event:setTime(now)
  event:setStart(now)
  event:setStale(stale)

  local detail = CotDetail()
  local contact = CotDetail("contact")
  contact:setAttribute("callsign", name)
  detail:addChild(contact)
  local remarks = CotDetail("remarks")
  remarks:setInnerText("Bullseye reference point: " .. name)
  detail:addChild(remarks)
  event:setDetail(detail)

  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)

  return {
    status = "success",
    uid = uid,
    name = name,
    lat = lat,
    lon = lon,
  }
end
