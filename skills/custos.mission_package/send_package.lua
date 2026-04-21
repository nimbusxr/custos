--- Send a mission package to a TAK contact or group
-- @tool send_package
-- @description Send an existing mission package to a specific contact or broadcast to all connected users
-- @tparam string package_name Name of the mission package to send
-- @tparam string to Recipient callsign or UID. Omit to send to all contacts.
-- @impact STRATEGIC
function send_package(params)
  if not params.package_name then
    return { status = "error", message = "package_name required" }
  end

  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local Intent = import("android.content.Intent")

  local intent = Intent("com.atakmap.android.missionpackage.SEND")
  intent:putExtra("name", params.package_name)
  if params.to then
    intent:putExtra("destination", params.to)
  end

  runOnUiThread(function()
    AtakBroadcast:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "sending",
    package_name = params.package_name,
    to = params.to or "all",
  }
end
