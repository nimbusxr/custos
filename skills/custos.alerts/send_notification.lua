--- Send an ATAK notification to the operator
-- @tool send_notification
-- @description Send a visible notification with a title and message. Shows an Android toast on screen.
-- @tparam string title Notification title
-- @tparam string message Notification body text
-- @impact PROCEDURAL
function send_notification(params)
  local Toast = import("android.widget.Toast")
  local MapView = import("com.atakmap.android.maps.MapView")

  local title = params.title or "CUST/OS Alert"
  local message = params.message or ""
  local display = title .. "\n" .. message

  runOnUiThread(function()
    Toast:makeText(MapView:getMapView():getContext(), display, Toast.LENGTH_LONG):show()
  end)

  return {
    status = "success",
    title = title,
    message = message,
  }
end
