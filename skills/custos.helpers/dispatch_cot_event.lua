--- Dispatch a CoT event to ATAK for processing
-- @tool dispatch_cot_event
-- @description Send a pre-built CoT event into ATAK's CoT processing pipeline
-- @tparam userdata event A CotEvent object (from build_cot_event)
-- @impact PROCEDURAL
function dispatch_cot_event(params)
  local CotMapComponent = import("com.atakmap.android.cot.CotMapComponent")
  local Bundle = import("android.os.Bundle")
  local event = params.event
  runOnUiThread(function()
    CotMapComponent:getInstance():processCotEvent(event, Bundle())
  end)
  return { status = "dispatched" }
end
