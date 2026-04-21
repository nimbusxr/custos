---@class SaluteReport
---@field format string always "SALUTE"
---@field size string estimated size (from params or "unknown")
---@field activity string observed activity (from params or "observed")
---@field location string MGRS grid string of the contact
---@field unit string "<callsign> (<affiliation> <dimension>)"
---@field time string coordinated DTG string
---@field equipment string observed equipment (from params or "unknown")
---@field lat number contact latitude
---@field lon number contact longitude
---@field cot_type string full CoT type of the contact

--- Generate a SALUTE report for a contact
-- @tool generate_salute
-- @description Generate a Size, Activity, Location, Unit, Time, Equipment (SALUTE) report for a specific contact or position. On error returns { status="error", message=... } instead of SaluteReport.
-- @tparam string identifier Contact callsign or UID to report on
-- @tparam string activity Observed activity (e.g., "patrolling", "stationary", "moving east")
-- @tparam string size Estimated size (e.g., "squad", "platoon", "single vehicle")
-- @tparam string equipment Observed equipment (e.g., "small arms", "RPG", "technical")
---@return SaluteReport
-- @impact READ_ONLY
function generate_salute(params)
  if not params.identifier then
    return { status = "error", message = "identifier required — provide callsign or UID" }
  end

  local CoordinatedTime = import("com.atakmap.coremap.maps.time.CoordinatedTime")

  local resolved = tools.call("resolve_item", { identifier = params.identifier })
  if resolved.status == "error" then
    return { status = "error", message = "Contact not found: " .. params.identifier }
  end
  local item = resolved.item

  local ok, pt = pcall(function()
    return item:getPoint()
  end)
  if not ok or not pt then
    return { status = "error", message = "Contact has no position" }
  end

  local ok2, title = pcall(function()
    return item:getTitle()
  end)
  local callsign = (ok2 and title) or params.identifier
  local itemType = item:getType() or ""
  local info = tools.call("parse_cot_type", { cot_type = itemType })
  local mgrs = tools.call("format_mgrs", { lat = pt:getLatitude(), lon = pt:getLongitude() }).mgrs
  local dtg = tostring(CoordinatedTime())

  return {
    format = "SALUTE",
    size = params.size or "unknown",
    activity = params.activity or "observed",
    location = mgrs,
    unit = callsign .. " (" .. (info.affiliation or "unknown") .. " " .. (info.dimension or "") .. ")",
    time = dtg,
    equipment = params.equipment or "unknown",
    lat = pt:getLatitude(),
    lon = pt:getLongitude(),
    cot_type = itemType,
  }
end
