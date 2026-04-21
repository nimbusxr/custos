--- Mark a Helicopter Landing Zone on the map
-- @tool mark_hlz
-- @description Mark a Helicopter Landing Zone (HLZ) at the specified location with marking method metadata.
-- @tparam number lat HLZ latitude
-- @tparam number lon HLZ longitude
-- @tparam string name HLZ name/callsign (default: HLZ)
-- @tparam string marking_method Marking method: panels, smoke, ir_strobe, none (default: panels)
-- @impact PROCEDURAL
function mark_hlz(params)
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")
  local Bundle = import("android.os.Bundle")

  local lat = params.lat
  local lon = params.lon
  local name = params.name or "HLZ"
  local markingMethod = params.marking_method or "panels"

  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local stale = CoordinatedTime(now:getMilliseconds() + 3600000)

  local event = CotEvent()
  event:setUID(uid)
  event:setType("b-r-f-h-c")
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
  remarks:setInnerText("HLZ " .. name .. " | Marking: " .. markingMethod:upper())
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
    marking_method = markingMethod,
  }
end
