-- activate_beacon_test.lua
-- Existence check: activate_beacon must be a callable function

assert(type(activate_beacon) == "function", "Expected activate_beacon to be function, got " .. type(activate_beacon))
console.log("[activate_beacon] function exists")
return "PASS (existence only — CRITICAL)"
