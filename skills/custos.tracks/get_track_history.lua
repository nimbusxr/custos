---@class TrackCrumb
---@field lat number breadcrumb latitude
---@field lon number breadcrumb longitude
---@field alt number|nil altitude (m HAE), nil if not recorded
---@field timestamp integer|nil epoch millis, nil if not recorded
---@field speed_mps number|nil instantaneous speed (m/s), nil if not recorded
---@field bearing_deg number|nil instantaneous bearing (deg, 0=N), nil if not recorded

---@class TrackHistoryResult
---@field status string "success" on success
---@field uid string contact UID
---@field callsign string contact callsign
---@field track_points TrackCrumb[] ordered newest-first
---@field count integer number of track points returned

--- Get track history breadcrumbs for a contact
-- @tool get_track_history
-- @description Get historical movement track (breadcrumbs) for a contact. Returns a list of positions with timestamps and speed/bearing data. On error returns { status="error", message=... } instead of TrackHistoryResult.
-- @tparam string identifier Callsign or UID of the contact
-- @tparam integer max_points Maximum number of track points to return (default: 50)
---@return TrackHistoryResult
-- @impact READ_ONLY
function get_track_history(params)
  local MapView = import("com.atakmap.android.maps.MapView")

  local identifier = params.identifier
  local maxPoints = params.max_points or 50

  if not identifier or identifier == "" then
    return { status = "error", message = "identifier is required" }
  end

  local mapView = MapView:getMapView()
  local rootGroup = mapView:getRootGroup()

  -- Resolve target to get UID
  local targetUid = nil
  local targetCallsign = nil
  local ok, found = pcall(function()
    return rootGroup:deepFindUID(identifier)
  end)
  if ok and found then
    targetUid = found:getUID()
    local ok2, title = pcall(function()
      return found:getTitle()
    end)
    targetCallsign = ok2 and title or identifier
  else
    local query = identifier:lower()
    local allItems = rootGroup:getItemsRecursive()
    local iter = allItems:iterator()
    while iter:hasNext() do
      local item = iter:next()
      local s, title = pcall(function()
        return item:getTitle()
      end)
      if s and title and title:lower():find(query, 1, true) then
        targetUid = item:getUID()
        targetCallsign = title
        break
      end
    end
  end

  if not targetUid then
    return { status = "error", message = "Contact not found: " .. identifier }
  end

  -- Query CrumbDatabase for track history
  local points = {}
  local ok3, err = pcall(function()
    local CrumbDatabase = import("com.atakmap.android.track.crumb.CrumbDatabase")
    local db = CrumbDatabase:instance()
    if not db then
      return
    end

    local crumbs = db:getCrumbs(targetUid, maxPoints, true) -- true = descending (newest first)
    if not crumbs then
      return
    end

    local iter = crumbs:iterator()
    while iter:hasNext() do
      local crumb = iter:next()
      local entry = {}

      pcall(function()
        local pt = crumb:getPoint()
        entry.lat = pt:getLatitude()
        entry.lon = pt:getLongitude()
        entry.alt = pt:getAltitude()
      end)

      pcall(function()
        entry.timestamp = crumb:getTimestamp()
      end)

      pcall(function()
        local s = crumb:getSpeed()
        if s >= 0 then
          entry.speed_mps = math.floor(s * 10) / 10
        end
      end)

      pcall(function()
        local b = crumb:getBearing()
        if b >= 0 then
          entry.bearing_deg = math.floor(b * 10) / 10
        end
      end)

      if entry.lat and entry.lon then
        table.insert(points, entry)
      end
    end
  end)

  return {
    status = "success",
    uid = targetUid,
    callsign = targetCallsign,
    track_points = points,
    count = #points,
  }
end
