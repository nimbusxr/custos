--- Create a spot report marker
-- @tool create_spot_report
-- @description Create a spot report (SPOTREP) marker at the specified location with military categorization. Returns formatted SALUTE report text.
-- @tparam number lat Report location latitude
-- @tparam number lon Report location longitude
-- @tparam string type Report type: ied, contact, obstacle, sniper, mortar, other (default: contact)
-- @tparam string description Description of what was observed
-- @tparam string size Size/strength estimate (e.g., squad, platoon, single vehicle) (default: unknown)
-- @tparam string activity Observed activity (e.g., moving_north, digging, stationary, patrolling) (default: stationary)
-- @tparam string time_observed Time of observation (free text, or "now" for current time) (default: now)
-- @impact PROCEDURAL
function create_spot_report(params)
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")
  local Bundle = import("android.os.Bundle")
  local MGRSPoint = import("com.atakmap.coremap.maps.coords.MGRSPoint")
  local GeoPoint = import("com.atakmap.coremap.maps.coords.GeoPoint")

  local lat = params.lat
  local lon = params.lon
  local reportType = params.type or "contact"
  local description = params.description or ""
  local size = params.size or "unknown"
  local activity = params.activity or "stationary"
  local timeObserved = params.time_observed or "now"

  -- Map report types to CoT types
  local typeMap = {
    ied = "a-h-G", -- hostile ground
    contact = "a-h-G", -- hostile ground
    obstacle = "b-m-p-c", -- control point
    sniper = "a-h-G-F-S", -- hostile ground SOF sniper
    mortar = "a-h-G-F", -- hostile ground fires
    other = "a-u-G", -- unknown ground
  }
  local cotType = typeMap[reportType] or "a-u-G"

  -- Map to callsign prefix
  local nameMap = {
    ied = "IED",
    contact = "CONTACT",
    obstacle = "OBSTACLE",
    sniper = "SNIPER",
    mortar = "MORTAR",
    other = "SPOT",
  }
  local prefix = nameMap[reportType] or "SPOT"

  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local stale = CoordinatedTime(now:getMilliseconds() + 3600000) -- 1 hour

  -- Format MGRS
  local mgrs = MGRSPoint(lat, lon):toString()

  -- Format time
  local timeStr = timeObserved
  if timeObserved == "now" then
    local Calendar = import("java.util.Calendar")
    local cal = Calendar:getInstance()
    timeStr = string.format(
      "%02d%02d%02dZ",
      cal:get(Calendar.DAY_OF_MONTH),
      cal:get(Calendar.HOUR_OF_DAY),
      cal:get(Calendar.MINUTE)
    )
  end

  -- Build SALUTE report
  local saluteLines = {
    "SIZE: " .. size,
    "ACTIVITY: " .. activity,
    "LOCATION: " .. mgrs,
    "UNIT/UNIFORM: " .. (description ~= "" and description or "N/A"),
    "TIME: " .. timeStr,
    "EQUIPMENT: N/A",
  }
  local saluteText = table.concat(saluteLines, "\n")

  local callsign = prefix .. "-" .. uid:sub(1, 4):upper()

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
  local remarks = CotDetail("remarks")
  remarks:setInnerText(saluteText)
  detail:addChild(remarks)
  event:setDetail(detail)

  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)

  return {
    status = "success",
    uid = uid,
    callsign = callsign,
    type = reportType,
    cot_type = cotType,
    lat = lat,
    lon = lon,
    mgrs = mgrs,
    salute_report = saluteText,
  }
end
