-- send_notification_test.lua
-- Tests that send_notification() shows a notification

local result = send_notification({
  title = "TEST",
  message = "test notification",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[send_notification] title=" .. tostring(result.title) .. " message=" .. tostring(result.message))
return "PASS"
