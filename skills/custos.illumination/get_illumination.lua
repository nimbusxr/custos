---@class IlluminationLocation
---@field lat number latitude used for the calculation
---@field lon number longitude used for the calculation

---@class SunState
---@field azimuth_deg number current sun azimuth (0=N, clockwise)
---@field elevation_deg number current sun elevation above horizon

---@class MoonState
---@field phase string named phase (e.g. "Waxing Gibbous")
---@field illumination_pct integer percent of lunar disk illuminated
---@field days_in_cycle number days since last new moon (0–29.5)

---@class IlluminationResult
---@field location IlluminationLocation queried position
---@field sun SunState|nil sun position, nil if SunPosition API unavailable
---@field sunrise_utc string|nil HH:MM UTC, nil if sun never rises/sets that day
---@field sunset_utc string|nil HH:MM UTC, nil if sun never rises/sets that day
---@field daylight_hours number|nil hours of daylight, nil if polar day/night
---@field moon MoonState current moon phase and illumination

--- Get illumination data for a location
-- @tool get_illumination
-- @description Get sun and moon position, rise/set times, moon phase, and illumination percentage. Defaults to self position if lat/lon not provided. On error (no GPS and no lat/lon) returns { status="error", message=... } instead of IlluminationResult.
-- @tparam number lat Latitude (defaults to self position)
-- @tparam number lon Longitude (defaults to self position)
---@return IlluminationResult
-- @impact READ_ONLY
function get_illumination(params)
  local MapView = import("com.atakmap.android.maps.MapView")
  local Calendar = import("java.util.Calendar")
  local Math = import("java.lang.Math")

  -- Resolve position
  local lat = params.lat
  local lon = params.lon
  if not lat or not lon then
    local mapView = MapView:getMapView()
    local selfMarker = mapView:getSelfMarker()
    if selfMarker then
      local pt = selfMarker:getPoint()
      lat = pt:getLatitude()
      lon = pt:getLongitude()
    else
      return { status = "error", message = "Provide lat/lon or wait for GPS fix" }
    end
  end

  local result = {
    location = { lat = lat, lon = lon },
  }

  -- Try ATAK's illumination calculator
  local ok, err = pcall(function()
    local SunPosition = import("com.atakmap.math.SunPosition")
    local cal = Calendar:getInstance()
    local now = cal:getTime()

    local sunPos = SunPosition:compute(now, lat, lon)
    if sunPos then
      result.sun = {
        azimuth_deg = math.floor(sunPos:getAzimuth() * 10) / 10,
        elevation_deg = math.floor(sunPos:getElevation() * 10) / 10,
      }
    end
  end)

  -- Compute approximate sunrise/sunset using standard solar algorithm
  pcall(function()
    local cal = Calendar:getInstance()
    local dayOfYear = cal:get(Calendar.DAY_OF_YEAR)
    local rad = math.pi / 180

    -- Solar declination approximation
    local decl = -23.44 * Math:cos(rad * 360 / 365 * (dayOfYear + 10))
    local latRad = lat * rad
    local declRad = decl * rad

    -- Hour angle at sunrise/sunset (when sun is at -0.833 degrees)
    local cosH = (Math:sin(-0.833 * rad) - Math:sin(latRad) * Math:sin(declRad))
      / (Math:cos(latRad) * Math:cos(declRad))

    if cosH >= -1 and cosH <= 1 then
      local H = Math:acos(cosH) / rad
      -- Convert to hours (15 degrees per hour)
      local solarNoon = 12 - lon / 15
      local sunriseHour = solarNoon - H / 15
      local sunsetHour = solarNoon + H / 15

      local function formatTime(hours)
        local h = math.floor(hours) % 24
        local m = math.floor((hours - math.floor(hours)) * 60)
        return string.format("%02d:%02d", h, m)
      end

      result.sunrise_utc = formatTime(sunriseHour)
      result.sunset_utc = formatTime(sunsetHour)
      result.daylight_hours = math.floor((sunsetHour - sunriseHour) * 10) / 10
    end
  end)

  -- Approximate moon phase (simplified calculation)
  pcall(function()
    local cal = Calendar:getInstance()
    local year = cal:get(Calendar.YEAR)
    local month = cal:get(Calendar.MONTH) + 1
    local day = cal:get(Calendar.DAY_OF_MONTH)

    -- Simplified moon phase: days since known new moon (Jan 6, 2000)
    local jd = 367 * year
      - math.floor(7 * (year + math.floor((month + 9) / 12)) / 4)
      + math.floor(275 * month / 9)
      + day
      + 1721013.5
    local daysSinceNew = (jd - 2451550.1) % 29.530588853

    local phase = daysSinceNew / 29.530588853
    local illumination = math.floor((1 - Math:cos(phase * 2 * math.pi)) / 2 * 100)

    local phaseName
    if daysSinceNew < 1.85 then
      phaseName = "New Moon"
    elseif daysSinceNew < 7.38 then
      phaseName = "Waxing Crescent"
    elseif daysSinceNew < 9.23 then
      phaseName = "First Quarter"
    elseif daysSinceNew < 14.77 then
      phaseName = "Waxing Gibbous"
    elseif daysSinceNew < 16.61 then
      phaseName = "Full Moon"
    elseif daysSinceNew < 22.15 then
      phaseName = "Waning Gibbous"
    elseif daysSinceNew < 23.99 then
      phaseName = "Last Quarter"
    else
      phaseName = "Waning Crescent"
    end

    result.moon = {
      phase = phaseName,
      illumination_pct = illumination,
      days_in_cycle = math.floor(daysSinceNew * 10) / 10,
    }
  end)

  return result
end
