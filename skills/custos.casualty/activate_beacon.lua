--- Activate an emergency beacon alert
-- @tool activate_beacon
-- @description Activate an ATAK emergency beacon. Broadcasts an emergency alert to all connected users. This is a CRITICAL action.
-- @tparam string emergency_type Emergency type: 911, hostile_fire, geofence_breach (default: 911)
-- @impact STRATEGIC
function activate_beacon(params)
  local Intent = import("android.content.Intent")
  local MapView = import("com.atakmap.android.maps.MapView")

  local emergencyType = params.emergency_type or "911"

  -- Map emergency type to ATAK EmergencyType enum values
  local typeMap = {
    ["911"] = "911",
    hostile_fire = "Ring The Bell",
    geofence_breach = "Geo-fence Breached",
  }
  local atakType = typeMap[emergencyType] or "911"

  local context = MapView:getMapView():getContext()

  local intent = Intent()
  intent:setAction("com.atakmap.android.emergency.ALERT")
  intent:putExtra("type", atakType)
  intent:putExtra("activate", true)

  runOnUiThread(function()
    local iom = import("com.atakmap.android.ipc.AtakBroadcast")
    iom:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "success",
    emergency_type = emergencyType,
    atak_type = atakType,
    warning = "Emergency beacon activated — all connected users will be alerted",
  }
end
