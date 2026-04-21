-- send_cot_test.lua
-- Existence check: send_cot must be a callable function

assert(type(send_cot) == "function", "Expected send_cot to be function, got " .. type(send_cot))
console.log("[send_cot] function exists")
return "PASS (existence only — CRITICAL)"
