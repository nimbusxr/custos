--- Generate a 9-line MEDEVAC request and place a CASEVAC marker
-- @tool create_9line
-- @description Generate a formatted 9-line MEDEVAC request. Places a CASEVAC marker at the pickup location and returns the full 9-line text.
-- @tparam number lat Pickup site latitude
-- @tparam number lon Pickup site longitude
-- @tparam string callsign Requesting unit callsign
-- @tparam string frequency Radio frequency for contact (default: none)
-- @tparam integer num_patients Total number of patients (default: 1)
-- @tparam string urgency Urgency: urgent, priority, or routine (default: urgent)
-- @tparam string special_equipment Special equipment needed (none, hoist, extraction, ventilator) (default: none)
-- @tparam integer num_litter Number of litter patients (default: 0)
-- @tparam integer num_ambulatory Number of ambulatory patients (default: 0)
-- @tparam string security Security at pickup: no_enemy, possible_enemy, enemy_in_area, enemy_escort (default: friendly)
-- @tparam string marking Marking method: panels, smoke, ir_strobe, none (default: panels)
-- @tparam string nationality Patient nationality: us_military, us_civilian, non_us_military, non_us_civilian, epw (default: us_military)
-- @impact PROCEDURAL
function create_9line(params)
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
  local callsign = params.callsign or "UNKNOWN"
  local frequency = params.frequency or "none"
  local numPatients = params.num_patients or 1
  local urgency = params.urgency or "urgent"
  local specialEquip = params.special_equipment or "none"
  local numLitter = params.num_litter or 0
  local numAmbulatory = params.num_ambulatory or 0
  local security = params.security or "friendly"
  local marking = params.marking or "panels"
  local nationality = params.nationality or "us_military"

  -- If litter+ambulatory not specified, default all to litter for urgent
  if numLitter == 0 and numAmbulatory == 0 then
    if urgency == "urgent" or urgency == "priority" then
      numLitter = numPatients
    else
      numAmbulatory = numPatients
    end
  end

  -- Format MGRS for Line 1
  local mgrs = MGRSPoint(lat, lon):toString()

  -- Urgency codes
  local urgencyMap = {
    urgent = "A - URGENT",
    priority = "B - PRIORITY",
    routine = "C - ROUTINE",
  }
  local urgencyLine = urgencyMap[urgency] or "A - URGENT"

  -- Security codes
  local securityMap = {
    no_enemy = "N - NO ENEMY",
    possible_enemy = "P - POSSIBLE ENEMY",
    enemy_in_area = "E - ENEMY IN AREA",
    enemy_escort = "X - ENEMY ESCORT REQUIRED",
    friendly = "N - NO ENEMY",
  }
  local securityLine = securityMap[security] or "N - NO ENEMY"

  -- Marking codes
  local markingMap = {
    panels = "A - PANELS",
    smoke = "B - SMOKE",
    ir_strobe = "C - IR STROBE",
    none = "E - NONE",
  }
  local markingLine = markingMap[marking] or "A - PANELS"

  -- Nationality codes
  local nationalityMap = {
    us_military = "A - US MILITARY",
    us_civilian = "B - US CIVILIAN",
    non_us_military = "C - NON-US MILITARY",
    non_us_civilian = "D - NON-US CIVILIAN",
    epw = "E - EPW",
  }
  local nationalityLine = nationalityMap[nationality] or "A - US MILITARY"

  -- Build 9-line text
  local lines = {
    "LINE 1: " .. mgrs,
    "LINE 2: " .. frequency .. " / " .. callsign,
    "LINE 3: " .. urgencyLine .. " - " .. numPatients .. " patient(s)",
    "LINE 4: " .. specialEquip:upper(),
    "LINE 5: " .. numLitter .. " LITTER / " .. numAmbulatory .. " AMBULATORY",
    "LINE 6: " .. securityLine,
    "LINE 7: " .. markingLine,
    "LINE 8: " .. nationalityLine,
    "LINE 9: N/A",
  }
  local nineLineText = table.concat(lines, "\n")

  -- Place CASEVAC marker
  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local stale = CoordinatedTime(now:getMilliseconds() + 3600000) -- 1 hour stale

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
  contact:setAttribute("callsign", "MEDEVAC-" .. callsign)
  detail:addChild(contact)
  local remarks = CotDetail("remarks")
  remarks:setInnerText(nineLineText)
  detail:addChild(remarks)
  event:setDetail(detail)

  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)

  return {
    status = "success",
    uid = uid,
    nine_line = nineLineText,
    mgrs = mgrs,
    callsign = callsign,
    urgency = urgency,
    num_patients = numPatients,
    lat = lat,
    lon = lon,
  }
end
