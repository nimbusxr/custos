---@class ContactDetail
---@field uid string TAK contact UID
---@field callsign string contact callsign
---@field lat number|nil last known latitude, nil if no position on map
---@field lon number|nil last known longitude, nil if no position on map
---@field alt number|nil last known altitude (m HAE), nil if no position
---@field team string|nil ATAK team color, nil if not set
---@field role string|nil ATAK role type, nil if not set
---@field type string|nil full CoT type from the map item, nil if not on map

--- Get detailed information about a specific contact
-- @tool get_contact_detail
-- @description Get detailed info on a contact including position, role, team, connectors, and last update time. On error returns { status="error", message=... } instead of ContactDetail.
-- @tparam string identifier Contact callsign or UID
---@return ContactDetail
-- @impact READ_ONLY
function get_contact_detail(params)
  if not params.identifier then
    return { status = "error", message = "identifier required" }
  end

  local Contacts = import("com.atakmap.android.contact.Contacts")
  local instance = Contacts:getInstance()

  -- Try by UID first
  local contact = instance:getContactByUuid(params.identifier)
  if not contact then
    -- Search by name
    local all = instance:getAllContacts()
    local iter = all:iterator()
    local query = params.identifier:lower()
    while iter:hasNext() do
      local c = iter:next()
      local ok, name = pcall(function()
        return c:getName()
      end)
      if ok and name and name:lower():find(query, 1, true) then
        contact = c
        break
      end
    end
  end

  if not contact then
    return { status = "error", message = "Contact not found: " .. params.identifier }
  end

  local detail = {
    uid = contact:getUID(),
    callsign = contact:getName(),
  }

  -- Get position from the map item if available
  local resolveResult = tools.call("resolve_item", { identifier = contact:getUID() })
  local item = resolveResult.status ~= "error" and resolveResult.item or nil
  if item then
    local ok, pt = pcall(function()
      return item:getPoint()
    end)
    if ok and pt then
      detail.lat = pt:getLatitude()
      detail.lon = pt:getLongitude()
      detail.alt = pt:getAltitude()
    end
    detail.team = item:getMetaString("team", nil)
    detail.role = item:getMetaString("atakRoleType", nil)
    detail.type = item:getType()
  end

  return detail
end
