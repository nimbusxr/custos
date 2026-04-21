--- Send a GeoChat message to a TAK contact or group
-- @tool send_chat
-- @description Send a text chat message to a specific TAK contact or the all-chat group. Omit the 'to' parameter to broadcast to everyone.
-- @tparam string message The chat message text
-- @tparam string to Recipient callsign or UID. Omit for all-chat broadcast.
-- @impact STRATEGIC
function send_chat(params)
  if not params.message then
    return { status = "error", message = "message text required" }
  end

  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local Intent = import("android.content.Intent")
  local MapView = import("com.atakmap.android.maps.MapView")

  local selfMarker = MapView:getMapView():getSelfMarker()
  local selfUid = selfMarker and selfMarker:getUID() or "unknown"
  local selfCallsign = selfMarker and selfMarker:getTitle() or "CUSTOS"

  local intent = Intent("com.atakmap.android.chat.SEND_MESSAGE")
  intent:putExtra("message", params.message)
  intent:putExtra("senderUid", selfUid)
  intent:putExtra("senderCallsign", selfCallsign)
  if params.to then
    intent:putExtra("destination", params.to)
  end

  runOnUiThread(function()
    AtakBroadcast:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "sent",
    message = params.message,
    to = params.to or "all",
  }
end
