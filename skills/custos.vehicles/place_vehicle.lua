--- Place a vehicle marker on the map
-- @tool place_vehicle
-- @description Place a vehicle marker at the specified location with vehicle type metadata and heading. Creates a CoT event with the appropriate ground vehicle type code.
-- @tparam number lat Latitude
-- @tparam number lon Longitude
-- @tparam string callsign Vehicle callsign/label
-- @tparam string vehicle_type Vehicle type: HMMWV, MRAP, STRYKER, BRADLEY, ABRAMS, TRUCK, APC, AMBULANCE, or other (default: HMMWV)
-- @tparam number heading_deg Vehicle heading in degrees (0=north) (default: 0)
-- @impact PROCEDURAL
function place_vehicle(params)
  local CotEvent = import("com.atakmap.coremap.cot.event.CotEvent")
  local CotPoint = import("com.atakmap.coremap.cot.event.CotPoint")
  local CotDetail = import("com.atakmap.coremap.cot.event.CotDetail")
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")
  local UUID = import("java.util.UUID")
  local Bundle = import("android.os.Bundle")

  local lat = params.lat
  local lon = params.lon
  local callsign = params.callsign or "Vehicle"
  local vehicleType = (params.vehicle_type or "HMMWV"):upper()
  local heading = params.heading_deg or 0

  -- Map vehicle types to CoT type codes
  -- a-f-G-E-V = friendly ground equipment vehicle
  local typeMap = {
    HMMWV = "a-f-G-E-V-W", -- wheeled
    MRAP = "a-f-G-E-V-W", -- wheeled armored
    STRYKER = "a-f-G-E-V-W", -- wheeled armored
    BRADLEY = "a-f-G-E-V-A", -- armored fighting vehicle
    ABRAMS = "a-f-G-E-V-A-T", -- tank
    TRUCK = "a-f-G-E-V-W", -- wheeled
    APC = "a-f-G-E-V-A", -- armored personnel carrier
    AMBULANCE = "a-f-G-E-V-m", -- medical vehicle
  }
  local cotType = typeMap[vehicleType] or "a-f-G-E-V"

  local uid = UUID:randomUUID():toString()
  local now = CoordinatedTime()
  local stale = CoordinatedTime(now:getMilliseconds() + 600000) -- 10 minute stale

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

  -- Add track element for heading
  local track = CotDetail("track")
  track:setAttribute("course", tostring(heading))
  track:setAttribute("speed", "0")
  detail:addChild(track)

  local remarks = CotDetail("remarks")
  remarks:setInnerText("Vehicle: " .. vehicleType)
  detail:addChild(remarks)

  event:setDetail(detail)

  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)

  return {
    status = "success",
    uid = uid,
    callsign = callsign,
    vehicle_type = vehicleType,
    lat = lat,
    lon = lon,
    heading_deg = heading,
    cot_type = cotType,
  }
end
