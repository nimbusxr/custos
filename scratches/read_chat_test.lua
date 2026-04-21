-- read_chat_test.lua
-- Tests that read_chat() returns a table (messages or status)

local result = read_chat({})
assert(type(result) == "table", "Expected table, got " .. type(result))
console.log("[read_chat] result is table with keys")
for k, v in pairs(result) do
    console.log("  " .. tostring(k) .. " = " .. type(v))
end
return "PASS"
