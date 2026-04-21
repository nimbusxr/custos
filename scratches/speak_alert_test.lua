-- speak_alert_test.lua
-- Tests that speak_alert() speaks a message via TTS

local result = speak_alert({
  message = "test alert",
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[speak_alert] message=" .. tostring(result.message))
return "PASS"
