--- Build a Cursor on Target (CoT) event object
-- @tool build_cot_event
-- @description Build a CoT event with uid, type, position, callsign, remarks, and color
-- @tparam number lat Latitude
-- @tparam number lon Longitude
-- @tparam string type CoT type string (default: a-f-G)
-- @tparam string callsign Display callsign
-- @tparam string uid UID (auto-generated if omitted)
-- @tparam string how How field (default: machine generated)
-- @tparam number stale_ms Stale time in milliseconds (default: 300000)
-- @tparam number alt Altitude (default: 0)
-- @tparam string remarks Remarks text
-- @tparam number color ARGB color integer
-- @impact PROCEDURAL
function build_cot_event(params)
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")

  local uid = params.uid or UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local staleMs = params.stale_ms or 300000
  local stale = CoordinatedTime(now:getMilliseconds() + staleMs)

  local event = CotEvent()
  event:setUID(uid)
  event:setType(params.type or "a-f-G")
  event:setHow(params.how or CotEvent.HOW_MACHINE_GENERATED)
  event:setPoint(CotPoint(params.lat, params.lon, params.alt or 0, 0, 0))
  event:setTime(now)
  event:setStart(now)
  event:setStale(stale)

  local detail = CotDetail()
  if params.callsign then
    local contact = CotDetail("contact")
    contact:setAttribute("callsign", params.callsign)
    detail:addChild(contact)
  end
  if params.remarks then
    local remarksDetail = CotDetail("remarks")
    remarksDetail:setInnerText(params.remarks)
    detail:addChild(remarksDetail)
  end
  if params.color then
    local colorDetail = CotDetail("color")
    colorDetail:setAttribute("argb", tostring(params.color))
    detail:addChild(colorDetail)
  end
  event:setDetail(detail)

  return { event = event, uid = uid }
end
