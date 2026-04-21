-- play_tone_test.lua
-- Tests that play_tone() plays a confirmation tone

local result = play_tone({
  type = "confirmation",
  duration_ms = 500,
})
assert(type(result) == "table", "Expected table, got " .. type(result))
assert(result.status == "success", "Expected status=success, got " .. tostring(result.status))
console.log("[play_tone] type=" .. tostring(result.type) .. " duration=" .. tostring(result.duration_ms))
return "PASS"
