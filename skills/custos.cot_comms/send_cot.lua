--- Send a CoT event to the TAK network
-- @tool send_cot
-- @description Broadcast a Cursor on Target event to all connected TAK users. Use for sharing markers, positions, and alerts across the network.
-- @tparam string type CoT type code (e.g., a-f-G for friendly ground, a-h-G for hostile ground)
-- @tparam number lat Latitude
-- @tparam number lon Longitude
-- @tparam string callsign Display name for the CoT event
-- @tparam string remarks Remarks/notes to attach
-- @impact STRATEGIC
function send_cot(params)
  if not params.type or not params.lat or not params.lon or not params.callsign then
    return { status = "error", message = "type, lat, lon, callsign required" }
  end

  local AtakBroadcast = import("com.atakmap.android.ipc.AtakBroadcast")
  local Intent = import("android.content.Intent")

  local cotResult = tools.call("build_cot_event", {
    lat = params.lat,
    lon = params.lon,
    callsign = params.callsign,
    type = params.type,
    remarks = params.remarks,
  })
  local event = cotResult.event
  local uid = cotResult.uid

  -- Dispatch to local map
  tools.call("dispatch_cot_event", { event = event })

  -- Rebroadcast to network via COT_REBROADCAST intent
  local intent = Intent("com.atakmap.android.maps.COT_REBROADCAST")
  intent:putExtra("cotEvent", event:toString())
  runOnUiThread(function()
    AtakBroadcast:getInstance():sendBroadcast(intent)
  end)

  return {
    status = "sent",
    uid = uid,
    callsign = params.callsign,
    type = params.type,
  }
end
