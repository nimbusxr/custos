-- send_package_test.lua
-- Existence check: send_package must be a callable function

assert(type(send_package) == "function", "Expected send_package to be function, got " .. type(send_package))
console.log("[send_package] function exists")
return "PASS (existence only — CRITICAL)"
