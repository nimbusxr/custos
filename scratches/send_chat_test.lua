-- send_chat_test.lua
-- Existence check: send_chat must be a callable function

assert(type(send_chat) == "function", "Expected send_chat to be function, got " .. type(send_chat))
console.log("[send_chat] function exists")
return "PASS (existence only — CRITICAL)"
